local wezterm = require('wezterm')
local Cells = require('utils.cells')

local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

local GLYPH_SEMI_CIRCLE_LEFT = nf.ple_left_half_circle_thick --[[ '' ]]
local GLYPH_SEMI_CIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[ '' ]]
local GLYPH_KEY_TABLE = nf.md_table_key --[[ '󱏅' ]]
local GLYPH_KEY = nf.md_key --[[ '󰌆' ]]

---@type table<string, Cells.SegmentColors>
local colors = {
   default = { bg = '#fab387', fg = '#1c1b19' },
   scircle = { bg = 'rgba(0, 0, 0, 0.4)', fg = '#fab387' },
}

local cells = Cells:new()

cells
   :add_segment(1, GLYPH_SEMI_CIRCLE_LEFT, colors.scircle, attr(attr.intensity('Bold')))
   :add_segment(2, ' ', colors.default, attr(attr.intensity('Bold')))
   :add_segment(3, ' ', colors.default, attr(attr.intensity('Bold')))
   :add_segment(4, GLYPH_SEMI_CIRCLE_RIGHT, colors.scircle, attr(attr.intensity('Bold')))

M.setup = function()
   wezterm.on('update-status', function(window, _pane)
      -- Broadcast window dimensions for tab-title layout (moved from right-status)
      local ok_sz, sz = pcall(function() return window:active_tab():get_size() end)
      local new_width = (ok_sz and sz) and sz.cols or wezterm.GLOBAL.window_width
      local new_workspace = #window:active_workspace() + 4
      
      -- Cache GLOBAL updates to prevent UI redraw storms
      if wezterm.GLOBAL.window_width ~= new_width then
         wezterm.GLOBAL.window_width = new_width
      end
      if wezterm.GLOBAL.workspace_width ~= new_workspace then
         wezterm.GLOBAL.workspace_width = new_workspace
      end
      if wezterm.GLOBAL.status_width ~= 0 then
         wezterm.GLOBAL.status_width = 0
      end

      local key_table = window:active_key_table()
      local workspace = window:active_workspace()
      local res = {}

      -- Reset cells for fresh render
      cells:update_segment_text(2, ''):update_segment_text(3, '')

      -- Workspace segment
      local workspace_icon = nf.md_desktop_mac
      cells:update_segment_text(2, workspace_icon)
      cells:update_segment_text(3, ' ' .. workspace)
      res = cells:render_all()

      -- Mode indicator (Overwrites icon/text if mode is active)
      if key_table then
         cells:update_segment_text(2, GLYPH_KEY_TABLE)
         cells:update_segment_text(3, ' ' .. string.upper(key_table))
         res = cells:render_all()
      elseif window:leader_is_active() then
         cells:update_segment_text(2, GLYPH_KEY)
         cells:update_segment_text(3, ' LEADER')
         res = cells:render_all()
      end

      window:set_left_status(wezterm.format(res))
   end)
end

return M
