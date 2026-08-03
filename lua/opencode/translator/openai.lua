---OpenAI-compatible chat completions provider for the translator (e.g. OpenRouter).
---
---@class opencode.translator.OpenAIProvider
---@field url string
---@field api_key string
---@field model string
---@field temperature number
---@field timeout integer
---@field system_prompt string

local M = {}

---Build the curl argv for a chat completion request. Pure: no network access.
---@param text string The sentineled prompt.
---@param provider opencode.translator.OpenAIProvider
---@return string[]
function M.build_cmd(text, provider)
	local body = vim.fn.json_encode({
		model = provider.model,
		temperature = provider.temperature,
		messages = {
			{ role = "system", content = provider.system_prompt },
			{ role = "user", content = text },
		},
	})
	return {
		"curl",
		"-sS",
		"--fail-with-body",
		"--max-time",
		tostring(provider.timeout),
		"--connect-timeout",
		"10",
		"-w",
		"\n%{http_code}",
		"-X",
		"POST",
		"-H",
		"Content-Type: application/json",
		"-H",
		"Accept: application/json",
		"-H",
		"Authorization: Bearer " .. provider.api_key,
		"-d",
		body,
		provider.url,
	}
end

---Split curl stdout into (body, http_code). `code` is "" when no trailer is present.
---@param stdout string
---@return string body, string code
function M.parse_response(stdout)
	local body, code = stdout:match("^(.*)\n(%d+)$")
	if not body then
		return stdout, ""
	end
	return body, code
end

---Call the provider and resolve with `choices[1].message.content`.
---The argv build is protected so `json_encode` errors on invalid UTF-8 become a rejection.
---The callback processing is scheduled via `vim.schedule`: `vim.system` invokes its callback
---in a fast event context, where calling `vim.fn` (e.g. `json_decode`) is forbidden (E5560).
---Mirrors the plugin's server/init.lua pattern of scheduling response processing.
---@param text string The sentineled prompt.
---@param provider opencode.translator.OpenAIProvider
---@return Promise<string>
function M.translate(text, provider)
	local Promise = require("opencode.promise")
	local ok, cmd = pcall(M.build_cmd, text, provider)
	if not ok then
		return Promise.reject("translator: failed to build request: " .. tostring(cmd))
	end
	return Promise.new(function(resolve, reject)
		vim.system(cmd, { text = true }, function(obj)
			vim.schedule(function()
				local body, code = M.parse_response(obj.stdout or "")
				if obj.code ~= 0 or not code:match("^2%d%d$") then
					local detail = body ~= "" and body or (obj.stderr or "")
					return reject(
						"translator: provider request failed (exit "
							.. obj.code
							.. ", HTTP "
							.. (code ~= "" and code or "?")
							.. "): "
							.. detail:gsub("\n", " ")
					)
				end
				local ok, decoded = pcall(vim.fn.json_decode, body)
				local content = ok
						and type(decoded) == "table"
						and type(decoded.choices) == "table"
						and type(decoded.choices[1]) == "table"
						and type(decoded.choices[1].message) == "table"
						and decoded.choices[1].message.content
					or nil
				if type(content) == "string" and #content > 0 then
					return resolve(content)
				end
				local detail = body ~= "" and body or (obj.stderr or "")
				return reject(
					"translator: unexpected provider response (exit "
						.. obj.code
						.. ", HTTP "
						.. (code ~= "" and code or "?")
						.. "): "
						.. detail:gsub("\n", " ")
				)
			end)
		end)
	end)
end

return M
