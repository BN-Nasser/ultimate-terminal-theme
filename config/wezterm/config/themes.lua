local wezterm = require("wezterm")
local M = {}

-- Define the 3 Master Templates
M.templates = {
	kevin = {
		name = "Kevin (Full Visuals)",
		use_fancy_tab_bar = false,
		window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
		color_scheme = "custom", -- Kevin's custom scheme
		font_size = 10.0,
	},
	sravioli = {
		name = "Sravioli (Minimalist)",
		use_fancy_tab_bar = false,
		window_padding = { left = 5, right = 5, top = 5, bottom = 5 },
		color_scheme = "Ubuntu",
		font_size = 11.0,
	},
	modern = {
		name = "Antigravity (Modern)",
		use_fancy_tab_bar = true,
		window_padding = { left = 10, right = 10, top = 10, bottom = 10 },
		color_scheme = "Catppuccin Mocha",
		font_size = 11.0,
	}
}

function M.apply_template(window, name)
	local template = M.templates[name] or M.templates.modern
	local overrides = window:get_config_overrides() or {}
	
	wezterm.GLOBAL.current_theme = name

	-- Structural Overrides
	overrides.use_fancy_tab_bar = template.use_fancy_tab_bar
	overrides.window_padding = template.window_padding
	overrides.font_size = template.font_size
	
	-- Color Overrides
	if template.color_scheme == "custom" then
		overrides.colors = require("colors.custom")
	else
		local scheme = wezterm.get_builtin_color_schemes()[template.color_scheme]
		if name == "modern" then
			scheme.background = "#300a24" -- Keep the purple for modern
		end
		overrides.colors = scheme
	end

	window:set_config_overrides(overrides)
	window:toast_notification("WezTerm", "Template switched to: " .. template.name, 2000)
end

return M
