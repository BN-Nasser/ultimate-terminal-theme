local wezterm = require("wezterm")
local M = {}

M.setup = function()
	wezterm.on("update-status", function(window, pane)
		if wezterm.GLOBAL.current_theme ~= "modern" then
			return
		end

		local stat = window:active_workspace()
		local stat_color = "#f7c196"
		
		-- Mode indicators
		local active_table = window:active_key_table()
		if active_table then
			stat = "MODE: " .. active_table:upper()
			stat_color = "#ff8e78"
		end
		
		if window:leader_is_active() then
			stat = "LDR"
			stat_color = "#8e78ff"
		end

		local date = wezterm.strftime("%Y-%m-%d %H:%M:%S")

		window:set_right_status(wezterm.format({
			{ Foreground = { Color = stat_color } },
			{ Attribute = { Intensity = "Bold" } },
			{ Text = "  " .. stat .. "  " },
			"ResetAttributes",
			{ Text = " | " },
			{ Text = date .. "  " },
		}))
		
		-- Clear left status for modern look
		window:set_left_status("")
	end)
end

return M
