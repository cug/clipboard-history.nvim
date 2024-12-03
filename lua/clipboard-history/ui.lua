local api = vim.api
local M = {}

local buf, win

local function create_window()
	buf = api.nvim_create_buf(false, true)
	local width = api.nvim_get_option("columns")
	local height = api.nvim_get_option("lines")

	local win_height = math.ceil(height * 0.8 - 4)
	local win_width = math.ceil(width * 0.8)

	local row = math.ceil((height - win_height) / 2 - 1)
	local col = math.ceil((width - win_width) / 2)

	local opts = {
		style = "minimal",
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
	}

	win = api.nvim_open_win(buf, true, opts)
	api.nvim_win_set_option(win, "cursorline", true)
end

local function close_window()
	api.nvim_win_close(win, true)
end

local function update_view(history)
	vim.bo[buf].modifiable = true
	local lines = {}
	local width = api.nvim_win_get_width(win) - 4 -- Subtract 4 for padding

	for i, item in ipairs(history) do
		local escaped_item = item:gsub("\n", "\\n")
		local wrapped = {}
		for j = 1, #escaped_item, width - 5 do
			table.insert(wrapped, escaped_item:sub(j, j + width - 6))
		end

		local preview = string.format("%d. %s", i, wrapped[1])
		table.insert(lines, preview)
		if #wrapped > 1 then
			local second_line = wrapped[2]
			if #wrapped > 2 then
				second_line = second_line:sub(1, width - 8) .. "..."
			end
			table.insert(lines, string.format("   %s", second_line))
		else
			table.insert(lines, "")
		end
		table.insert(lines, "") -- Add an empty line between entries
	end

	api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false

	-- Set up virtual lines to make navigation smoother
	local ns_id = api.nvim_create_namespace("clipboard_history")
	for i = 1, #lines, 3 do
		api.nvim_buf_set_extmark(buf, ns_id, i, 0, {
			virt_lines_above = true,
			virt_lines = { { { "", "Normal" } } },
		})
	end
end

local function select_item(history)
	local cursor_pos = api.nvim_win_get_cursor(win)
	local index = math.floor((cursor_pos[1] - 1) / 3) + 1
	if index and history[index] then
		local text = history[index]
		close_window()
		vim.schedule(function()
			local mode = api.nvim_get_mode().mode
			-- Split the text into lines
			local lines = vim.split(text, "\n", true)
			if mode == "n" or mode == "v" or mode == "V" then
				-- In normal or visual mode, paste at cursor
				vim.api.nvim_put(lines, "c", true, true)
			elseif mode == "i" then
				-- In insert mode, insert at cursor
				local row, col = unpack(vim.api.nvim_win_get_cursor(0))
				row = row - 1 -- Convert to 0-indexed

				-- Get current lines
				local current_lines = vim.api.nvim_buf_get_lines(0, row, row + 1, false)
				local current_line = current_lines[1]

				-- Split the current line
				local line_before = string.sub(current_line, 1, col)
				local line_after = string.sub(current_line, col + 1)

				-- Prepare new lines
				local new_lines = { line_before .. lines[1] }
				for i = 2, #lines do
					table.insert(new_lines, lines[i])
				end
				new_lines[#new_lines] = new_lines[#new_lines] .. line_after

				-- Replace the lines in the buffer
				vim.api.nvim_buf_set_lines(0, row, row + 1, false, new_lines)

				-- Move cursor to the end of the inserted text
				vim.api.nvim_win_set_cursor(0, { row + #new_lines, #new_lines[#new_lines] - #line_after })
			end
		end)
	else
		print("Invalid selection")
	end
end

local function setup_number_navigation()
	local number_buffer = ""
	local function go_to_line()
		local num = tonumber(number_buffer)
		if num and num > 0 and num <= #_G.clipboard_history.items then
			api.nvim_win_set_cursor(win, { (num - 1) * 3 + 1, 0 })
		end
		number_buffer = ""
	end

	for i = 0, 9 do
		vim.keymap.set("n", tostring(i), function()
			number_buffer = number_buffer .. tostring(i)
		end, { buffer = buf })
	end

	vim.keymap.set("n", "k", function()
		if number_buffer ~= "" then
			go_to_line()
		else
			vim.cmd("normal! 3j")
		end
	end, { buffer = buf })

	vim.keymap.set("n", "i", function()
		if number_buffer ~= "" then
			go_to_line()
		else
			vim.cmd("normal! 3k")
		end
	end, { buffer = buf })
end

local function ensure_cursor_on_item()
	local cursor_pos = api.nvim_win_get_cursor(win)
	local new_line = math.floor((cursor_pos[1] - 1) / 3) * 3 + 1
	api.nvim_win_set_cursor(win, { new_line, 0 })
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
		ensure_cursor_on_item()
		select_item(history)
	end, { buffer = buf })

	setup_number_navigation()

	-- Ensure cursor starts on the first item
	api.nvim_win_set_cursor(win, { 1, 0 })

	-- Set up autocommand to ensure cursor is always on an item
	vim.api.nvim_create_autocmd("CursorMoved", {
		buffer = buf,
		callback = ensure_cursor_on_item,
	})
end

return M
