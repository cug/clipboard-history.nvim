if vim.g.loaded_clipboard_history then
	return
end
vim.g.loaded_clipboard_history = true

vim.api.nvim_create_user_command("ClipboardHistory", function()
	require("clipboard-history.ui").show_history()
end, {})
