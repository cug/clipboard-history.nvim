local M = {}

local api = vim.api
local buf, win

local function create_window()
	buf = api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local opts = {
		style = "minimal",
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		border = "rounded",
	}

	win = api.nvim_open_win(buf, true, opts)
	vim.bo[buf].modifiable = false
end

local function update_view(history)
	vim.bo[buf].modifiable = true
	local lines = {}
	local width = api.nvim_win_get_width(win) - 4 -- Subtract 4 for padding

	local function wrap_text(text, max_width)
		local wrapped = {}
		for line in text:gmatch("[^\n]+") do
			while #line > max_width do
				local segment = line:sub(1, max_width)
				table.insert(wrapped, segment)
				line = line:sub(max_width + 1)
			end
			table.insert(wrapped, line)
		end
		return wrapped
	end

	for i, item in ipairs(history) do
		local wrapped = wrap_text(item, width - 3) -- Subtract 3 for the number prefix
		local preview = string.format("%d. %s", i, wrapped[1])
		table.insert(lines, preview)
		if #wrapped > 1 then
			if #wrapped > 2 then
				table.insert(lines, string.format("   %s", wrapped[2]:sub(1, width - 6) .. "..."))
			else
				table.insert(lines, string.format("   %s", wrapped[2]))
			end
		end
		table.insert(lines, "") -- Add an empty line between entries
	end

	api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
end

local function close_window()
	api.nvim_win_close(win, true)
end

local function select_item(history)
	local cursor_pos = api.nvim_win_get_cursor(win)
	local index = cursor_pos[1]
	if index and history[index] then
		close_window()
		vim.schedule(function()
			local text = history[index]
			local line, col = unpack(vim.api.nvim_win_get_cursor(0))
			local current_line = vim.api.nvim_get_current_line()
			local new_line = current_line:sub(1, col) .. text .. current_line:sub(col + 1)
			vim.api.nvim_set_current_line(new_line)
			vim.api.nvim_win_set_cursor(0, { line, col + #text })
		end)
	else
		print("Invalid selection")
	end
end

function M.show_history()
	local history = _G.clipboard_history.items
	if #history == 0 then
		print("Clipboard history is empty")
		return
	end

	create_window()
	update_view(history)

	vim.keymap.set("n", "q", close_window, { buffer = buf })
	vim.keymap.set("n", "<CR>", function()
		select_item(history)
	end, { buffer = buf })
end

return M
