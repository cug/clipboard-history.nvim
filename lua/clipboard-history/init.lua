local M = {}

local default_config = {
	max_history = 100,
}

local config = {}

local history = {}

local function add_to_history(text)
	for i, item in ipairs(history) do
		if item == text then
			table.remove(history, i)
			break
		end
	end

	table.insert(history, 1, text)

	while #history > config.max_history do
		table.remove(history)
	end
end

local function capture_clipboard()
	local current = vim.fn.getreg('"')
	if current and current ~= "" and current ~= history[1] then
		add_to_history(current)
	end
end

M.setup = function(opts)
	config = vim.tbl_deep_extend("force", default_config, opts or {})

	vim.api.nvim_create_autocmd({ "TextYankPost" }, {
		callback = function()
			capture_clipboard()
		end,
	})

	vim.notify("Clipboard History plugin initialized", vim.log.levels.INFO)
end

M.get_history = function()
	return history
end

return M
