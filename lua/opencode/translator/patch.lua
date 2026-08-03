---Monkey-patches `opencode.api.prompt` so every prompt flows through the translator proxy.
---
---The patched function mirrors the installed `api/prompt.lua` exactly, with two changes:
---1. After input resolution, `require("opencode.translator").process(raw, context)` is inserted.
---   The module is looked up at call time so wrapping `process` on the module after `apply()`
---   still takes effect.
---2. The submit decision is hoisted: it is computed from the RAW text before translation.
---   When the raw prompt ends with a trailing space, the translator is SKIPPED
---   entirely (resolve -> render -> append, never submit — the original
---   `api/prompt.lua` behavior); otherwise the prompt flows through
---   `translator.process` and submits normally.
---
---`apply()` is identity-based and self-healing: it compares the current `prompt` field against
---the module-local `patched` function instead of a boolean flag, so a re-required
---`opencode.api.prompt` (plugin reload, in-session update) is detected and re-patched
---against the fresh original.

local M = {}

---Stale reference to the original field once patched; never nilled (harmless closure).
---@type function
local original = nil

---The patched prompt. Module-local so `apply()` can compare identity against the current
---`opencode.api.prompt` field and detect reloads.
---@param prompt string
---@param context opencode.context.Context
---@return Promise<any>
local function patched(prompt, context)
	local Promise = require("opencode.promise")
	local input = prompt:match("%.%.%.$") and require("opencode.ui.ask").ask(prompt:gsub("%.%.%.$", ""), context)
		or Promise.resolve(prompt)
	return input
		:next(function(raw)
			-- Trailing-space prompts SKIP the translator entirely: resolve ->
			-- render -> append, never submit (the original api/prompt.lua
			-- behavior). The submit decision is computed from the RAW text, so
			-- the translator can never turn a non-submitting prompt into one
			-- that submits (or fire preview in confirm mode).
			if raw:match(" $") then
				local plaintext = context:render(raw).output:plaintext()
				return Promise.resolve({ skip_translate = true, text = plaintext })
			end
			return require("opencode.translator").process(raw, context):next(function(translated)
				local plaintext = context:render(translated).output:plaintext()
				return Promise.resolve({ skip_translate = false, text = plaintext })
			end)
		end)
		:next(function(step)
			return context.server:tui_append_prompt(step.text):next(function()
				if not step.skip_translate then
					return context.server:tui_execute_command("prompt.submit")
				end
			end)
		end)
		:next(function()
			context:clear()
		end)
		:catch(function(err)
			context:resume()
			return Promise.reject(err)
		end)
end

---Wrap `opencode.api.prompt`. Idempotent and self-healing: when the field is already the
---patched function this is a no-op; when the api module was re-required since the last
---apply, the fresh original is captured and the patch is re-applied.
function M.apply()
	local api_prompt = require("opencode.api.prompt")
	if api_prompt.prompt == patched then
		return
	end
	original = api_prompt.prompt
	-- Intentional patch seam: re-assigning the `prompt` field of the api module.
	---@diagnostic disable-next-line: duplicate-set-field
	api_prompt.prompt = patched
end

---Restore the original `opencode.api.prompt`. `original` is never nilled, so repeated
---revert calls are harmless.
function M.revert()
	if original == nil then
		return
	end
	require("opencode.api.prompt").prompt = original
end

return M
