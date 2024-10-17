if vim.g.loaded_clipboard_history then
	return
end
vim.g.loaded_clipboard_history = true

local max_history = vim.g.clipboard_history_max_history

require("clipboard-history").setup({
	max_history = max_history,
})

vim.api.nvim_create_user_command("ClipboardHistory", function()
	require("clipboard-history.ui").show_history()
end, {})

vim.api.nvim_create_user_command("ClipboardClear", function()
	require("clipboard-history").clear_history()
end, {})
