---Side-window composer for building prompts before sending them to opencode.
---
---WHY this exists: the translator proxy rewrites prompts through an external
---LLM. Composing in a scratch side window (instead of the TUI's prompt line)
---lets the user assemble a prompt from multiple refs (`<leader>ap` / `<leader>ao`
---append `@this` snippets) and then translate + review it in place before the
---final send. The window mechanics mirror `translator.preview`: botright
---vsplit, markdown scratch buffer with bufhidden=hide, buffer-local `<CR>` and
---`q` keymaps, and a single-active-entry guarantee where a new `open()` cancels
---the previous composer. The hidden buffer survives window replacement and is
---re-shown via `M.focus()`; explicit buffer deletion still settles the entry.
---
---Phase machine on `<CR>`:
---  compose -> translate the buffer content via the mode-free M.translate
---             (confirm mode: replace the buffer with the translation and enter
---             review; silent mode: send immediately).
---  review  -> send the (edited) buffer content.
---
---`open()` resolves with the FINAL SENT plaintext after a successful send, so
---callers can e.g. echo it. Always submits: the composer is a complete prompt
---flow, unlike the patch's trailing-space skip.
local M = {}

local Promise = require("opencode.promise")

---The single active composer, or nil. At most one exists at a time; a new
---`open()` cancels and closes the previous one first.
---@class opencode.translator.composer.Active
---@field buf integer
---@field win integer
---@field server opencode.server.Server
---@field ctx opencode.context.Context Translate-phase context, captured at open.
---@field phase "compose" | "translating" | "review" | "sending"
---@field done boolean Settled at most once.
---@field resolve fun(value: string) Resolve `open()` with the sent text.
---@field reject fun(reason: any) Reject `open()` (cancel / error).

---@type opencode.translator.composer.Active?
local active = nil

---Width of the side window: ~90 columns, capped at columns-60, min 40.
---@return integer
local function compose_width()
	local width = 90
	local cols = vim.o.columns
	if cols > 0 then
		width = math.min(width, math.max(40, cols - 60))
	end
	return math.max(40, width)
end

---Split `text` on "\n" for `nvim_buf_set_lines`. A multi-line string is NEVER
---passed as a single list item (nvim_buf_set_lines rejects it). A trailing
---"\n" keeps a trailing empty line; empty text yields one empty line.
---@param text string
---@return string[]
local function split_lines(text)
	local lines = {}
	for line in (text .. "\n"):gmatch("(.-)\n") do
		lines[#lines + 1] = line
	end
	return lines
end

---Current buffer content joined with "\n".
---@param buf integer
---@return string
local function buffer_text(buf)
	return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
end

---Create the composer side window and display `buf` in it: a botright vsplit
---at `compose_width()` columns with wrapping on. Shared by `open()` (new
---composer) and `focus()` (re-showing a hidden composer).
---@param buf integer
---@return integer The new window handle.
local function show_composer_window(buf)
	vim.cmd(string.format("botright %d vsplit", compose_width()))
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)
	vim.wo[win].wrap = true
	return win
end

---Close the composer window and wipe the buffer. Destructive, so wrapped in
---pcall: the buffer may already be gone (the wipe guard settled the entry).
---@param entry opencode.translator.composer.Active
local function cleanup(entry)
	pcall(vim.api.nvim_win_close, entry.win, true)
	pcall(vim.api.nvim_buf_delete, entry.buf, { force = true })
end

---Send `text`: render with a FRESH context captured at accept time, append,
---submit, clear, then settle `open()` with the rendered plaintext (the final
---sent text). The fresh context is contract-pinned: refs are re-rendered at
---accept time, not at open time.
---@param entry opencode.translator.composer.Active
---@param text string
---@return Promise<any>
local function finish(entry, text)
	local server = entry.server
	local context = require("opencode.context").new(server)
	local plaintext = context:render(text).output:plaintext()
	return server
		:tui_append_prompt(plaintext)
		:next(function()
			return server:tui_execute_command("prompt.submit")
		end)
		:next(function()
			context:clear()
			if not entry.done then
				entry.done = true
				if active == entry then
					active = nil
				end
				cleanup(entry)
				entry.resolve(plaintext)
			end
		end)
		:catch(function(err)
			if not entry.done then
				entry.done = true
				if active == entry then
					active = nil
				end
				cleanup(entry)
				entry.reject(err)
			end
		end)
end

---Bind the phase-machine keys. `r` and every editing key stay free: the user
---edits the composer content directly.
---@param entry opencode.translator.composer.Active
local function setup_keymaps(entry)
	-- COMPOSE <CR>: translate the buffer content via the mode-free M.translate
	-- (required at call time: per-scenario setup() must be visible). Confirm
	-- mode replaces the buffer with the translation and enters REVIEW; silent
	-- mode sends immediately.
	-- REVIEW <CR>: send (fresh-context render -> append -> submit).
	vim.keymap.set("n", "<CR>", function()
		if entry.done then
			return
		end
		if entry.phase == "compose" then
			entry.phase = "translating"
			local text = buffer_text(entry.buf)
			require("opencode.translator")
				.translate(text, entry.ctx)
				:next(function(translated)
					if entry.done then
						return
					end
					if require("opencode.translator").opts.mode == "confirm" then
						entry.phase = "review"
						vim.api.nvim_buf_set_lines(entry.buf, 0, -1, false, split_lines(translated))
					else
						finish(entry, translated)
					end
				end)
				:catch(function(err)
					if not entry.done then
						entry.done = true
						if active == entry then
							active = nil
						end
						cleanup(entry)
						entry.reject(err)
					end
				end)
		elseif entry.phase == "review" then
			entry.phase = "sending"
			finish(entry, buffer_text(entry.buf))
		end
	end, { buffer = entry.buf, nowait = true })

	vim.keymap.set("n", "q", function()
		if entry.done then
			return
		end
		entry.done = true
		if active == entry then
			active = nil
		end
		cleanup(entry)
		entry.reject("cancelled")
	end, { buffer = entry.buf, nowait = true })
end

---Reject the composer if the user explicitly deletes or wipes the buffer
---(`:bd` / `:bw`). Window replacement no longer fires this: the buffer is
---`bufhidden=hide` and is re-shown via `M.focus()`. The done flag plus the
---active-identity check stop `cleanup`'s `nvim_buf_delete` from recursing into
---this callback.
---@param entry opencode.translator.composer.Active
local function setup_wipe_guard(entry)
	local group = vim.api.nvim_create_augroup("OpencodeTranslatorComposeBuf" .. entry.buf, { clear = true })
	vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
		group = group,
		buffer = entry.buf,
		once = true,
		callback = function()
			if entry.done then
				return
			end
			entry.done = true
			if active == entry then
				active = nil
			end
			entry.reject("cancelled")
		end,
	})
end

---Open the composer side window.
---
---Resolves with the FINAL SENT TEXT after a successful `<CR>` send. Rejects
---with "cancelled" on `q`, when the buffer is explicitly deleted or wiped
---(`:bd` / `:bw`), or when a new `open()` cancels this one. Closing the window
---only hides the buffer (bufhidden=hide); it is re-shown via `M.focus()`.
---Calling `open()` while another composer is active cancels and closes the old
---one first, so at most one composer exists at any time.
---
---The server is obtained via `opencode.server.discovery.get()` (a Promise), so
---tests can stub discovery and never touch a real opencode process.
---@return Promise<string>
function M.open()
	if active then
		local previous = active
		active = nil
		previous.done = true
		previous.reject("cancelled")
		cleanup(previous)
	end

	return require("opencode.server.discovery").get():next(function(server)
		if not server then
			return Promise.reject("opencode translator: no opencode server")
		end
		local buf = vim.api.nvim_create_buf(false, true)
		vim.bo[buf].bufhidden = "hide"
		vim.bo[buf].buftype = "nofile"
		vim.bo[buf].modifiable = true
		vim.bo[buf].filetype = "markdown"
		vim.api.nvim_buf_set_name(buf, "opencode-translator-compose")
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })

		local win = show_composer_window(buf)

		local promise, resolve, reject = Promise.with_resolvers()
		local entry = {
			buf = buf,
			win = win,
			server = server,
			ctx = require("opencode.context").new(server),
			phase = "compose",
			done = false,
			resolve = resolve,
			reject = reject,
		}
		active = entry
		setup_keymaps(entry)
		setup_wipe_guard(entry)
		return promise
	end)
end

---Re-show the active composer: focus its window when one still displays the
---buffer, otherwise recreate the side window and display the hidden buffer in
---it (the buffer survives window replacement thanks to bufhidden=hide).
---Non-destructive: the entry is never cancelled or rejected here; explicit
---buffer deletion already settled it via the wipe guard.
---@return boolean True when an active composer exists and was (re)shown.
function M.focus()
	if not active then
		return false
	end
	if not vim.api.nvim_buf_is_valid(active.buf) then
		return false
	end
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == active.buf then
			active.win = win
			vim.api.nvim_set_current_win(win)
			return true
		end
	end
	active.win = show_composer_window(active.buf)
	return true
end

---Append `text` at the composer buffer end; multi-line text is split into
---separate buffer lines.
---@param text any
---@return boolean False when no composer is open; true when appended.
function M.add_ref(text)
	if not active then
		return false
	end
	local insert = {}
	for line in (tostring(text) .. "\n"):gmatch("(.-)\n") do
		insert[#insert + 1] = line
	end
	-- Drop split_lines' trailing empty line so single-line refs keep their
	-- exact prior behavior (no trailing blank line added).
	if insert[#insert] == "" then
		insert[#insert] = nil
	end
	local line_count = vim.api.nvim_buf_line_count(active.buf)
	vim.api.nvim_buf_set_lines(active.buf, line_count, line_count, false, insert)
	return true
end

---@return boolean Whether a composer window is currently open.
function M.is_open()
	return active ~= nil
end

return M
