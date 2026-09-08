return {
	{
		"yetone/avante.nvim",
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		-- ⚠️ must add this setting! ! !
		build = vim.fn.has("win32") ~= 0
				and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
			or "make",
		event = "VeryLazy",
		version = false, -- Never set this value to "*"! Never!
		opts = function()
			-- Gateway endpoints are per-machine and come from the environment.
			-- A provider registered with endpoint = nil fails at request time
			-- with no useful message, so unconfigured providers are dropped and
			-- the default falls back to whatever is actually reachable.
			local hh_endpoint = vim.env.AVANTE_HH_ENDPOINT
			local pyn_endpoint = vim.env.AVANTE_PYN_ENDPOINT

			local providers = {
				-- Local OpenAI-compatible server (LM Studio, llama.cpp, ...)
				openai = {
					endpoint = "http://localhost:1234/v1",
					model = "qwen3.8:27b",
					api_key_name = "", -- empty = local server, no key needed
					temperature = 0.2,
					reasoning_effort = "low",
				},
				-- Local Ollama, tuned for long reasoning chains
				ollamaReasoning = {
					__inherited_from = "openai",
					endpoint = "http://127.0.0.1:11434",
					model = "qwen3.8:27b",
					reasoning_effort = "xhigh",
					extra_request_body = {
						options = {
							temperature = 0.7,
							top_p = 0.8,
							-- Capped well below the model's native context so the
							-- KV cache still fits in VRAM.
							num_ctx = 32768,
						},
					},
				},
				openrouter = {
					__inherited_from = "openai",
					endpoint = "https://openrouter.ai/api/v1",
					model = "qwen/qwen3-235b-a22b:free",
				},
			}

			if pyn_endpoint then
				providers.deepseekLocal = {
					__inherited_from = "openai",
					endpoint = pyn_endpoint,
					model = "deepseek-v4-flash-0731",
					api_key_name = "AVANTE_PYN_API_KEY",
				}
			end

			if hh_endpoint then
				providers.deepseek = {
					__inherited_from = "openai",
					endpoint = hh_endpoint,
					model = "deepseek-chat",
					api_key_name = "AVANTE_API_KEY",
				}
				providers.deepseekPro = {
					__inherited_from = "openai",
					endpoint = hh_endpoint,
					model = "deepseek-v4-pro",
					api_key_name = "AVANTE_API_KEY",
				}
			end

			local provider = "deepseekLocal"
			if not providers[provider] then
				provider = providers.deepseek and "deepseek" or "openai"
				vim.schedule(function()
					vim.notify(
						("avante: AVANTE_PYN_ENDPOINT is not set, falling back to %q"):format(provider),
						vim.log.levels.WARN
					)
				end)
			end

			return {
				provider = provider,
				providers = providers,
			}
		end,
	},
}
