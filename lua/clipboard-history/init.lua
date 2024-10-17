local M = {}

_G.clipboard_history = _G.clipboard_history or {
	items = {},
	config = {
		max_history = 30,
	},
}

local function add_to_history(item)
	table.insert(_G.clipboard_history.items, 1, item)
	if #_G.clipboard_history.items > _G.clipboard_history.config.max_history then
		table.remove(_G.clipboard_history.items)
	end
end

local function capture_clipboard()
	local current = vim.fn.getreg('"')
	if current and current ~= "" then
		current = current:gsub("\n$", "")
		if current ~= "" and current ~= _G.clipboard_history.items[1] then
			add_to_history(current)
		end
	end
end

local function save_history_to_file()
	local history_file = vim.fn.stdpath("data") .. "/clipboard_history.json"
	local file = io.open(history_file, "w")
	if file then
		file:write(vim.fn.json_encode(_G.clipboard_history))
		file:close()
	end
end

local function load_history_from_file()
	local history_file = vim.fn.stdpath("data") .. "/clipboard_history.json"
	local file = io.open(history_file, "r")
	if file then
		local content = file:read("*all")
		file:close()
		if content and content ~= "" then
			_G.clipboard_history = vim.fn.json_decode(content)
		end
	end
end

function M.setup(opts)
	opts = opts or {}
	_G.clipboard_history.config.max_history = opts.max_history or _G.clipboard_history.config.max_history

	load_history_from_file()

	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = capture_clipboard,
	})

	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = save_history_to_file,
	})
end

function M.get_history()
	return _G.clipboard_history.items
end

function M.clear_history()
	_G.clipboard_history.items = {}
	print("Clipboard history cleared")
end

M.setup({})

return M
