---Translator proxy: rewrites prompts through an external LLM API before they reach the opencode TUI.
---
---Prompts are tokenized: context placeholders (e.g. `@this`) and agent names are replaced with
---collision-guarded sentinels (`@@N@@`), the sentineled text is sent to the provider, and the
---sentinels are restored in the provider's output. If the provider drops a sentinel the
---translation is treated as failed and retried. When retries are exhausted the configured
---error policy decides whether to send the original prompt, ask the user, or abort.
---
---@class opencode.translator.Opts
---@field enabled? boolean Whether the translator is active.
---@field mode? "silent" | "confirm" How to deliver the translation.
---@field retries? integer Additional attempts after the first (retries=2 -> up to 3 total calls).
---@field retry_delay_ms? integer Linear backoff between retries.
---@field on_error? "passthrough" | "ask" | "abort" What to do when translation fails after retries.
---@field system_prompt_path? string Optional .md file override; read lazily per call.
---@field log_path? string|false Log file path; false disables logging.
---@field provider? opencode.translator.Provider

---@class opencode.translator.Provider
---@field url? string
---@field api_key? string
---@field model? string
---@field temperature? number
---@field timeout? integer
---@field translate? fun(text: string): Promise<string> Provider seam override.
---@field system_prompt? string Injected system prompt.

local M = {}

local TITLE = "opencode translator"

---Default system prompt shipped with the translator.
local DEFAULT_SYSTEM_PROMPT = [[
ASD-STE100
---
You are a prompt translator for the opencode TUI, an AI coding agent that runs in a terminal.

The developer has typed a prompt in Neovim for programming. Rewrite it to be clearer, more specific, and more actionable for a coding agent, while preserving the developer's intent exactly.
The developer expects the prompts to resemble language written for RFC, IEEE standards.

Rules:
- Preserve the user's intent. Do not add, drop, or change tasks.
- Do not invent file names, symbols, commands, or details that are not in the prompt.
- Keep the original language of the prompt.
- The prompt may contain special markers of the form @@N@@. These are placeholders that will be replaced with real context (buffer contents, selections, agent names) after you return your translation. You MUST keep every @@N@@ marker exactly as-is: do not remove, rename, merge, or add markers.
- If the prompt is already clear and complete, return it with only minimal rewording, or unchanged.
- Reply with the translated prompt only. No explanations, no commentary, no markdown code fences.
- Use ASD-STE100 syntax standard, Simplified Technical English.
]]

local defaults = {
	enabled = false,
	mode = "silent",
	retries = 1,
	retry_delay_ms = 1000,
	on_error = "passthrough",
	system_prompt_path = nil,
	log_path = vim.fn.stdpath("state") .. "/opencode-translator.log",
	provider = {
		url = "https://openrouter.ai/api/v1/chat/completions",
		api_key = nil, -- resolved at call time: provider.api_key, else vim.env.OPENROUTER_API_KEY
		model = "meta-llama/llama-3.1-8b-instruct",
		temperature = 0.2,
		timeout = 30,
	},
}

---Current options. Replaced wholesale by `M.setup`, never mutated in place.
---@type opencode.translator.Opts
M.opts = vim.deepcopy(defaults)

---Append a timestamped line to the log file. Best-effort: never throws and never
---affects the promise flow, so every call site is safe to add without pcall itself.
---@param ... any
local function log(...)
	if not M.opts.log_path or M.opts.log_path == "" then
		return
	end
	local args = { ... }
	pcall(function()
		local file = io.open(M.opts.log_path, "a")
		if not file then
			return
		end
		file:write(os.date("%Y-%m-%d %H:%M:%S") .. " " .. table.concat(args, " ") .. "\n")
		file:close()
	end)
end

---Replace options with a fresh deep-merge of defaults and `opts`, so no state leaks between calls.
---@param opts? opencode.translator.Opts
function M.setup(opts)
	M.opts = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
end

---Longest-first placeholder matching, mirroring the plugin's `Context:render`.
---@param raw string
---@param context? opencode.context.Context
---@return { pos: integer, ph: string }[] Occurrences in order of first appearance.
local function tokenize(raw, context)
	local contexts = require("opencode.config").opts.contexts or {}
	local placeholders = {}
	for key in pairs(contexts) do
		placeholders[key] = true
	end
	for _, agent in ipairs((context and context.server and context.server.subagents) or {}) do
		placeholders["@" .. agent.name] = true
	end

	local keys = vim.tbl_keys(placeholders)
	table.sort(keys, function(a, b)
		return #a > #b
	end)

	local occurrences = {}
	local i = 1
	while i <= #raw do
		local next_pos, next_ph = #raw + 1, nil
		for _, ph in ipairs(keys) do
			local pos = raw:find(ph, i, true)
			if pos and pos < next_pos then
				next_pos, next_ph = pos, ph
			end
		end
		if not next_ph then
			break
		end
		occurrences[#occurrences + 1] = { pos = next_pos, ph = next_ph }
		i = next_pos + #next_ph
	end
	return occurrences
end

---Replace tokens with sentinels, right-to-left so earlier positions stay valid.
---Each marker base is `@@N@@`, mutated with `_` until it collides with nothing in the text.
---@param raw string
---@param occurrences { pos: integer, ph: string }[]
---@return string, table<integer, string>
local function sentinelize(raw, occurrences)
	local sentinels = {}
	local sentineled = raw
	for k = #occurrences, 1, -1 do
		local occ = occurrences[k]
		local sentinel = "@@" .. k .. "@@"
		while sentineled:find(sentinel, 1, true) do
			sentinel = sentinel .. "_"
		end
		sentinels[k] = sentinel
		sentineled = sentineled:sub(1, occ.pos - 1) .. sentinel .. sentineled:sub(occ.pos + #occ.ph)
	end
	return sentineled, sentinels
end

---Restore sentinels in the provider output. Rejects when any sentinel was dropped or altered.
---@param output string
---@param sentinels table<integer, string>
---@param occurrences { pos: integer, ph: string }[]
---@return string?, string? Restored text, or nil + reason when a marker is missing.
local function restore(output, sentinels, occurrences)
	local out = output
	for k = 1, #occurrences do
		local sentinel = sentinels[k]
		if not out:find(sentinel, 1, true) then
			return nil, "translator: model dropped marker " .. sentinel .. " in output"
		end
		out = out:gsub(vim.pesc(sentinel), occurrences[k].ph)
	end
	return out
end

---The system prompt used for this call: the `system_prompt_path` override when readable,
---otherwise the embedded default. Read lazily per call so edits apply without reloading.
---@return string
local function load_system_prompt()
	local path = M.opts.system_prompt_path
	if path then
		local file = io.open(path, "r")
		if file then
			local content = file:read("*a")
			file:close()
			if content and #content > 0 then
				return content
			end
		end
		vim.notify("translator: could not read " .. path .. ", using embedded system prompt", vim.log.levels.WARN, {
			title = TITLE,
		})
	end
	return DEFAULT_SYSTEM_PROMPT
end

---Invoke the provider seam: a `provider.translate` override, or the real HTTP provider.
---The seam is the offline contract and receives only the sentineled text. The real
---provider additionally gets a manifest listing every sentinel verbatim (and a retry
---hint on attempts after the first), hardening against models that restructure the
---sentence and drop or alter a `@@N@@` marker.
---The api key is resolved at call time so mid-session environment changes take effect:
---`provider.api_key` first, falling back to `vim.env.OPENROUTER_API_KEY`.
---@param sentinel_text string
---@param sentinels table<integer, string>
---@param attempt_no integer
---@return Promise<string>
local function invoke_provider(sentinel_text, sentinels, attempt_no)
	local Promise = require("opencode.promise")
	local provider = M.opts.provider or {}
	if type(provider.translate) == "function" then
		return provider.translate(sentinel_text)
	end
	local key = provider.api_key
	if not key or key == "" then
		key = vim.env.OPENROUTER_API_KEY
	end
	if not key or key == "" then
		return Promise.reject(
			"translator: no api_key set; set provider.api_key or the OPENROUTER_API_KEY environment variable"
		)
	end
	local system_prompt = load_system_prompt()
	if #sentinels > 0 then
		system_prompt = system_prompt
			.. "\n\nPlaceholder tokens that MUST appear verbatim in your output: "
			.. table.concat(sentinels, ", ")
			.. "."
			.. "\nEvery placeholder token must appear in your output exactly as written, unmodified. Do not drop, rename, merge, or reorder them."
		if attempt_no > 1 then
			system_prompt = system_prompt
				.. "\nA previous attempt failed because a placeholder token was missing or altered. This attempt MUST contain every placeholder token listed above, verbatim."
		end
	end
	return require("opencode.translator.openai").translate(
		sentinel_text,
		vim.tbl_extend("force", provider, {
			api_key = key,
			system_prompt = system_prompt,
		})
	)
end

---Run the provider once, then restore sentinels; retry linearly up to `M.opts.retries` extra times.
---@param sentineled string
---@param sentinels table<integer, string>
---@param occurrences { pos: integer, ph: string }[]
---@param attempt_no integer
---@return Promise<string>
local function attempt(sentineled, sentinels, occurrences, attempt_no)
	local Promise = require("opencode.promise")
	return invoke_provider(sentineled, sentinels, attempt_no)
		:next(function(output)
			local restored, reason = restore(output, sentinels, occurrences)
			if restored then
				log("attempt " .. attempt_no .. " ok output_len=" .. #output)
				return Promise.resolve(restored)
			end
			log("attempt " .. attempt_no .. " FAIL " .. reason .. " output=[" .. output .. "]")
			return Promise.reject(reason)
		end)
		:catch(function(err)
			if attempt_no < (M.opts.retries or 0) + 1 then
				return Promise.new(function(resolve)
					vim.defer_fn(function()
						resolve(attempt(sentineled, sentinels, occurrences, attempt_no + 1))
					end, M.opts.retry_delay_ms or 0)
				end)
			end
			return Promise.reject(err)
		end)
end

---Error policy after retries are exhausted.
---@param raw string The original prompt, for passthrough / "Send original".
---@param err any
---@param retry_once fun(): Promise<string> Re-runs the translate+restore path and applies mode.
---@return Promise<string>
local function policy(raw, err, retry_once)
	local Promise = require("opencode.promise")
	log("policy " .. M.opts.on_error .. " err=" .. tostring(err))
	if M.opts.on_error == "abort" then
		vim.notify("Translation failed: " .. tostring(err), vim.log.levels.ERROR, { title = TITLE })
		return Promise.reject(err)
	end
	if M.opts.on_error == "ask" then
		return Promise.new(function(resolve, reject)
			vim.ui.select({ "Send original", "Retry", "Cancel" }, {
				prompt = "opencode translator: translation failed: " .. tostring(err),
			}, function(choice)
				if choice == "Send original" then
					resolve(raw)
				elseif choice == "Retry" then
					resolve(retry_once())
				else
					reject("cancelled")
				end
			end)
		end)
	end
	-- passthrough (default): send the original prompt.
	vim.notify("Translation failed, sending original: " .. tostring(err), vim.log.levels.WARN, { title = TITLE })
	return Promise.resolve(raw)
end

---Translate `raw` per the current options.
---@param raw string
---@param context opencode.context.Context
---@return Promise<string>
function M.process(raw, context)
	local Promise = require("opencode.promise")
	if not M.opts.enabled then
		return Promise.resolve(raw)
	end

	vim.notify("Translating prompt…", vim.log.levels.INFO, { title = TITLE })

	local occurrences = tokenize(raw, context)
	local sentineled, sentinels = sentinelize(raw, occurrences)

	log("start mode=" .. M.opts.mode .. " retries=" .. tostring(M.opts.retries) .. " sentinels=" .. #sentinels)
	if #sentinels > 0 then
		log("sentinels", table.concat(sentinels, " "))
	end

	local function invoke()
		return attempt(sentineled, sentinels, occurrences, 1)
	end

	---Apply the delivery mode; the confirm result is never re-translated.
	---Confirm mode opens a persistent side-window preview (translator.preview)
	---with the translated prompt; the user accepts or cancels there.
	---@param text string
	---@return Promise<string> | string
	local function apply_mode(text)
		if M.opts.mode == "confirm" then
			return require("opencode.translator.preview").show(text, raw)
		end
		return text
	end

	-- Retry via the ask policy re-runs the whole path (translate + mode + policy).
	local full_path
	full_path = function()
		return invoke()
			:catch(function(err)
				log("aborted err=" .. tostring(err))
				return policy(raw, err, full_path)
			end)
			:next(apply_mode)
			:next(function(text)
				log("done resolved_len=" .. #text)
				return Promise.resolve(text)
			end)
	end

	return full_path()
end

---Flip the enabled flag; returns the new value.
---@return boolean
function M.toggle()
	M.opts.enabled = not M.opts.enabled
	vim.notify(
		"opencode translator " .. (M.opts.enabled and "enabled" or "disabled"),
		vim.log.levels.INFO,
		{ title = TITLE }
	)
	return M.opts.enabled
end

return M
