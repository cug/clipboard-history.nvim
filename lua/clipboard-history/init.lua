local M = {}

local function log_debug(message)
	local log_file = io.open(vim.fn.stdpath("data") .. "/clipboard_history_debug.log", "a")
	if log_file then
		log_file:write(os.date("%Y-%m-%d %H:%M:%S") .. " - " .. tostring(message) .. "\n")
		log_file:close()
	end
end

local function save_history()
	local file = io.open(vim.fn.stdpath("data") .. "/clipboard_history.json", "w")
	if file then
		file:write(vim.fn.json_encode(_G.clipboard_history))
		file:close()
	end
end

local function load_history()
	local file = io.open(vim.fn.stdpath("data") .. "/clipboard_history.json", "r")
	if file then
		local content = file:read("*all")
		file:close()
		if content ~= "" then
			_G.clipboard_history = vim.fn.json_decode(content)
		end
	end
	-- Ensure items table exists
	_G.clipboard_history.items = _G.clipboard_history.items or {}
end

local last_yanked_text = ""
local last_yank_time = 0

function M.setup(opts)
	opts = opts or {}

	local max_history = vim.g.clipboard_history_max_history or opts.max_history or 30

	_G.clipboard_history = _G.clipboard_history or { items = {}, max_history = max_history }

	load_history()

	_G.clipboard_history.max_history = _G.clipboard_history.max_history or max_history

	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			local status, err = pcall(function()
				log_debug("TextYankPost triggered")
				local yanked_text = vim.fn.getreg('"')
				log_debug("Yanked text type: " .. type(yanked_text))
				log_debug("Yanked text length: " .. tostring(#yanked_text))

				if type(yanked_text) == "string" and #yanked_text > 0 then
					log_debug("Yanked text is valid")

					-- Check if this is a duplicate event
					local current_time = vim.loop.now()
					if yanked_text == last_yanked_text and current_time - last_yank_time < 100 then
						log_debug("Duplicate yank event detected, ignoring")
						return
					end

					last_yanked_text = yanked_text
					last_yank_time = current_time

					if #_G.clipboard_history.items == 0 or yanked_text ~= _G.clipboard_history.items[1] then
						log_debug("New yanked text is different from the last entry")
						table.insert(_G.clipboard_history.items, 1, yanked_text)
						if _G.clipboard_history.max_history then
							while #_G.clipboard_history.items > _G.clipboard_history.max_history do
								table.remove(_G.clipboard_history.items)
							end
						end
						save_history()
						log_debug("History updated and saved")
					else
						log_debug("Yanked text is the same as the last entry, not updating")
					end
				else
					log_debug("Yanked text is not valid")
				end
			end)

			if not status then
				log_debug("Error in TextYankPost callback: " .. tostring(err))
			end
		end,
	})

	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			save_history()
		end,
	})
end

function M.clear_history()
	_G.clipboard_history.items = {}
	save_history()
	print("Clipboard history cleared")
end

return M
