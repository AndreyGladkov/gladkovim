return {
  {
    "yetone/avante.nvim",
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build = vim.fn.has "win32" ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    opts = function()
      local hh_endpoint = vim.env.AVANTE_HH_ENDPOINT
      local pyn_endpoint = vim.env.AVANTE_PYN_ENDPOINT

      return {
      provider = "deepseekLocal",
      providers = {
        openai = {
            endpoint = "http://localhost:1234/v1", -- Для встроенного 'openai' оставляем /v1
            model = "qwen3.8:27b",
            api_key_name = "", -- Оставляем пустым, ключ не нужен
            temperature = 0.2, -- Ваша целевая температура
            reasoning_effort = "low",
        },
        ollamaReasoning = {
          __inherited_from = "openai",
          endpoint = "http://127.0.0.1:11434",
          model = "qwen3.8:27b",
          -- Передача параметров для отключения размышлений:
          extra_request_body = {
             -- Для глубоких размышлений Qwen3.8 разработчики рекомендуют повышенную температуру

             -- Нативное управление логикой Qwen3.8:
             reasoning_effort = "xhigh", -- Включает максимальную глубину мысли (дефолт для 3.8)

             -- Контекст (у Qwen3.8 нативный контекст 262к, но для локального KV-кэша
             -- лучше ограничить его в зависимости от вашей VRAM)
              options = {
               temperature = 0.7,        -- Позволяет модели строить сложные логические цепочки
               top_p = 0.8,              -- Стандартное отсечение для этого режима
               num_ctx = 32768,
              }
          },
        },
        deepseek = {
          __inherited_from = "openai",
          endpoint = hh_endpoint,
          model = "deepseek-chat",
          api_key_name = "AVANTE_API_KEY",
        },
        deepseekLocal = {
          __inherited_from = "openai",
          endpoint = pyn_endpoint,
          api_key_name = "AVANTE_PYN_API_KEY",
          model = "deepseek-v4-flash-0731",
        },
        deepseekPro = {
          __inherited_from = "openai",
          endpoint = hh_endpoint,
          model = "deepseek-v4-pro",
          api_key_name = "AVANTE_API_KEY",
        },
        openrouter = {
          __inherited_from = "openai",
          endpoint = "https://openrouter.ai/api/v1",
          model = "qwen/qwen3-235b-a22b:free",
        },
      },
      }
    end
  }
}
