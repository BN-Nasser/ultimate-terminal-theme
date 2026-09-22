local wezterm = require("wezterm")
local act = wezterm.action
local M = {}

function M.apply(config)
	-- New Leader Key
	config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 2000 }

	config.keys = {
		-- Copy & Exit Copy Mode (English & Arabic)
		{ 
			key = "c", 
			mods = "CTRL|SHIFT", 
			action = act.Multiple({
				act.CopyTo("Clipboard"),
				act.CopyMode("Close"), -- Close mode after copying
			}) 
		},
		{ 
			key = "ؤ", 
			mods = "CTRL|SHIFT", 
			action = act.Multiple({
				act.CopyTo("Clipboard"),
				act.CopyMode("Close"),
			}) 
		},
		
		-- Paste (English & Arabic)
		{ key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
		{ key = "ر", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
		
		-- Select All (English & Arabic) - One press logic
		{ 
			key = "a", 
			mods = "CTRL", 
			action = act.Multiple({
				act.ActivateCopyMode,
				act.CopyMode("MoveToScrollbackTop"),
				act.CopyMode({ SetSelectionMode = "Cell" }),
				act.CopyMode("MoveToScrollbackBottom"),
			}) 
		},
		{ 
			key = "ش", 
			mods = "CTRL", 
			action = act.Multiple({
				act.ActivateCopyMode,
				act.CopyMode("MoveToScrollbackTop"),
				act.CopyMode({ SetSelectionMode = "Cell" }),
				act.CopyMode("MoveToScrollbackBottom"),
			}) 
		},

		-- Template Switching (Ctrl + Alt)
		{ key = "Alt", mods = "CTRL", action = act.ActivateKeyTable({ name = "theme_mode", one_shot = true }) },
		{ key = "Meta", mods = "CTRL", action = act.ActivateKeyTable({ name = "theme_mode", one_shot = true }) },

		-- Navigation & Splits
		{ key = "O", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "خ", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "E", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "ث", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "W", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },
		{ key = "ص", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },
		{ key = "T", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "ف", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },

		-- Navigate panes with Ctrl+Arrows
		{ key = "LeftArrow", mods = "CTRL", action = act.ActivatePaneDirection("Left") },
		{ key = "RightArrow", mods = "CTRL", action = act.ActivatePaneDirection("Right") },
		{ key = "UpArrow", mods = "CTRL", action = act.ActivatePaneDirection("Up") },
		{ key = "DownArrow", mods = "CTRL", action = act.ActivatePaneDirection("Down") },

		-- Leader Modes
		{ key = "r", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_mode", one_shot = false }) },
		{ key = "m", mods = "LEADER", action = act.ActivateKeyTable({ name = "move_mode", one_shot = false }) },
		
		-- Background Cycle
		{
			key = "B",
			mods = "CTRL|SHIFT",
			action = wezterm.action_callback(function(window, pane)
				local backdrops = require("utils.backdrops")
				local overrides = window:get_config_overrides() or {}
				backdrops:set_random_backdrop(overrides)
				window:set_config_overrides(overrides)
			end),
		},
		{ key = "R", mods = "CTRL|SHIFT", action = act.ReloadConfiguration },
	}

	-- Key Tables
	config.key_tables = {
		resize_mode = {
			{ key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 1 }) },
			{ key = "RightArrow", action = act.AdjustPaneSize({ "Right", 1 }) },
			{ key = "UpArrow", action = act.AdjustPaneSize({ "Up", 1 }) },
			{ key = "DownArrow", action = act.AdjustPaneSize({ "Down", 1 }) },
			{ key = "Escape", action = "PopKeyTable" },
		},
		move_mode = {
			{ key = "LeftArrow", action = act.ActivatePaneDirection("Left") },
			{ key = "RightArrow", action = act.ActivatePaneDirection("Right") },
			{ key = "UpArrow", action = act.ActivatePaneDirection("Up") },
			{ key = "DownArrow", action = act.ActivatePaneDirection("Down") },
			{ key = "Escape", action = "PopKeyTable" },
		},
		theme_mode = {
			{ key = "k", action = wezterm.action_callback(function(window, pane) require("config.themes").apply_template(window, "kevin") end) },
			{ key = "s", action = wezterm.action_callback(function(window, pane) require("config.themes").apply_template(window, "sravioli") end) },
			{ key = "m", action = wezterm.action_callback(function(window, pane) require("config.themes").apply_template(window, "modern") end) },
			{ key = "Escape", action = "PopKeyTable" },
		},
		-- Ensure copy mode itself handles the exit on copy
		copy_mode = {
			{ key = "c", mods = "CTRL", action = act.Multiple({ act.CopyTo("Clipboard"), act.CopyMode("Close") }) },
			{ key = "ؤ", mods = "CTRL", action = act.Multiple({ act.CopyTo("Clipboard"), act.CopyMode("Close") }) },
			{ key = "Escape", action = act.CopyMode("Close") },
		}
	}
end

return M
