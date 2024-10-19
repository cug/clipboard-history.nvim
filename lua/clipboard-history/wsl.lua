local M = {}

local function log_debug(message)
	local log_file = io.open(vim.fn.stdpath("data") .. "/clipboard_history_debug.log", "a")
	if log_file then
		log_file:write(os.date("%Y-%m-%d %H:%M:%S") .. " - " .. tostring(message) .. "\n")
		log_file:close()
	end
end

function M.yank_to_windows_clipboard()
	log_debug("Yanking to Windows clipboard")

	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local lines = vim.fn.getline(start_pos[2], end_pos[2])

	if #lines == 0 then
		print("No text selected")
		log_debug("No text selected")
		return
	end

	if #lines > 1 then
		lines[#lines] = lines[#lines]:sub(1, end_pos[3])
	end

	lines[1] = lines[1]:sub(start_pos[3])

	local selected_text = table.concat(lines, "\n")

	log_debug("Selected text: " .. vim.inspect(selected_text))

	selected_text = selected_text:gsub("([\"'\\])", "\\%1")
	selected_text = selected_text:gsub("\n", "\\n")

	local cmd = string.format([[powershell.exe -command "Set-Clipboard '%s'"]], selected_text)

	log_debug("Command: " .. cmd)

	local output = vim.fn.system(cmd)
	local exit_code = vim.v.shell_error

	log_debug("Exit code: " .. tostring(exit_code))
	log_debug("Output: " .. vim.inspect(output))

	if exit_code == 0 then
		print("Yanked to Windows clipboard")
	else
		print("Failed to yank to Windows clipboard. Error: " .. output)
		log_debug("Failed to yank to Windows clipboard. Error: " .. output)
	end
end

return M
