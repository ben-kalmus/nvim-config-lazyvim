---Persistent side-window preview for translator confirm mode.
---
---WHY this exists: confirm delivery used to go through `opencode.ui.ask`,
---which renders with snacks.input. That input is single-line: when the
---translated prompt contains newlines, snacks.input passes the whole
---multi-line string as one list item to `nvim_buf_set_lines`
---(snacks/input.lua:235), which errors with `'replacement string' item
---contains newlines`. A translated prompt is usually multi-line, so confirm
---mode crashed on the happy path.
---
---User workflow: instead of a transient single-line input, confirm mode now
---opens a persistent, editable side buffer holding the translated prompt. It
---stays open until you accept (`<CR>` resolves with the buffer content — edit
---it first if needed) or cancel (`q`). Because it is a normal buffer, you can
---iterate on a chat over time: keep the preview open, tweak the wording,
---accept when it reads right. Closing the window cancels the preview.
local M = {}

local Promise = require("opencode.promise")

---A preview that is still open (not yet accepted, cancelled, or wiped).
---@class opencode.translator.preview.Active
---@field buf integer
---@field win integer
---@field done boolean Settled at most once.
---@field resolve fun(value: string) Resolve `show()` with the accepted text.
---@field reject fun(reason: any) Reject `show()` (cancel / closed window).

---The single active preview, or nil. Only one preview exists at a time;
---a new `show()` cancels and closes the previous one first.
---@type opencode.translator.preview.Active?
local active = nil

---Width of the side window: ~90 columns, capped at columns-60, min 40.
---@return integer
local function preview_width()
	local width = 90
	local cols = vim.o.columns
	if cols > 0 then
		width = math.min(width, math.max(40, cols - 60))
	end
	return math.max(40, width)
end

---Split `text` on "\n" for `nvim_buf_set_lines`. A multi-line string is NEVER
---passed as a single list item (that is the exact crash this module replaces).
---A trailing "\n" keeps a trailing empty line; empty text yields one empty line.
---@param text string
---@return string[]
local function split_lines(text)
	local lines = {}
	for line in (text .. "\n"):gmatch("(.-)\n") do
		lines[#lines + 1] = line
	end
	return lines
end

---Close the preview window and wipe the buffer. Destructive, so wrapped in
---pcall: the buffer may already be gone (the wipe guard settled the entry).
---@param entry opencode.translator.preview.Active
local function cleanup(entry)
	pcall(vim.api.nvim_win_close, entry.win, true)
	pcall(vim.api.nvim_buf_delete, entry.buf, { force = true })
end

---Bind accept/cancel keys. `r` and every other editing key stay free: the
---user edits the translation in this buffer before accepting.
---@param entry opencode.translator.preview.Active
local function setup_keymaps(entry)
	vim.keymap.set("n", "<CR>", function()
		if entry.done then
			return
		end
		entry.done = true
		if active == entry then
			active = nil
		end
		local accepted = table.concat(vim.api.nvim_buf_get_lines(entry.buf, 0, -1, false), "\n")
		cleanup(entry)
		entry.resolve(accepted)
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

---Reject the preview if the user closes the window (bufhidden=wipe) or wipes
---the buffer. The done flag plus the active-identity check stop `cleanup`'s
---`nvim_buf_delete` from recursing into this callback.
---@param entry opencode.translator.preview.Active
local function setup_wipe_guard(entry)
	local group = vim.api.nvim_create_augroup("OpencodeTranslatorPreviewBuf" .. entry.buf, { clear = true })
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

---Open a persistent side-window preview of the translated prompt.
---
---Resolves with the ACCEPTED content: the buffer lines joined with "\n"
---(the user may edit the buffer before pressing `<CR>`). Rejects with
---"cancelled" on `q`, or when the window is closed / the buffer is wiped.
---Calling `show()` while another preview is active cancels and closes the old
---one first, so at most one preview exists at any time.
---
---`raw` (the original, untranslated prompt) is part of the revert-path
---contract; the preview displays `text` only.
---@param text string Multi-line translated prompt to preview.
---@param raw string Original (untranslated) prompt.
---@return Promise<string>
function M.show(text, raw)
	if active then
		local previous = active
		active = nil
		previous.done = true
		previous.reject("cancelled")
		cleanup(previous)
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].modifiable = true
	vim.bo[buf].filetype = "markdown"
	vim.api.nvim_buf_set_name(buf, "opencode-translator-preview")

	local lines = split_lines(text)
	if #lines == 0 then
		lines = { "" }
	end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	vim.cmd(string.format("botright %d vsplit", preview_width()))
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)
	vim.wo[win].wrap = true

	local promise, resolve, reject = Promise.with_resolvers()
	local entry = {
		buf = buf,
		win = win,
		done = false,
		resolve = resolve,
		reject = reject,
	}
	active = entry
	setup_keymaps(entry)
	setup_wipe_guard(entry)

	return promise
end

return M
