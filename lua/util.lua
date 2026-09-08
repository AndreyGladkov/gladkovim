local M = {}

--- Format a buffer with one specific LSP client.
---
--- No-op (no error) when that client isn't attached yet, e.g. right after
--- opening a file before LSP has finished attaching. Prevents the
--- "[LSP] Format request failed, no matching language servers." notification.
---
---@param bufnr integer
---@param client_name string
---@param timeout_ms integer
---@return boolean formatted whether a format request was actually sent
function M.format_with_client(bufnr, client_name, timeout_ms)
	if #vim.lsp.get_clients({ bufnr = bufnr, name = client_name }) == 0 then
		return false
	end

	vim.lsp.buf.format({
		bufnr = bufnr,
		timeout_ms = timeout_ms,
		filter = function(client)
			return client.name == client_name
		end,
	})
	return true
end

return M
