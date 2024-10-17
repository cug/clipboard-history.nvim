-- test_nvim_config/init.lua
vim.opt.runtimepath:append("../clipboard-history.nvim")

require("clipboard-history").setup()

-- Optional: add any other settings you want for testing
