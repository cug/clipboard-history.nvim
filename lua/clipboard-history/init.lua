local M = {}

local config = {
	max_history = 30,
}

local history = {}

local function add_to_history(item)
	table.insert(history, 1, item)
	if #history > config.max_history then
		table.remove(history)
	end
end

local function capture_clipboard()
	local current = vim.fn.getreg('"')
	if current and current ~= "" then
		-- Remove trailing newline
		current = current:gsub("\n$", "")
		if current ~= "" and current ~= history[1] then
			add_to_history(current)
		end
	end
end

function M.setup(opts)
	opts = opts or {}
	config.max_history = opts.max_history or config.max_history

	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = capture_clipboard,
	})
end

function M.get_history()
	return history
end

M.setup({})

return M
