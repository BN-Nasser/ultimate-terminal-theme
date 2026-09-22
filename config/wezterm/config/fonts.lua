local wezterm = require('wezterm')
local platform = require('utils.platform')

local font_family = 'JetBrains Mono'
local default_font_size = platform.is_mac and 12 or 10

-- Load saved font size from file (persists across restarts)
local function load_saved_font_size()
   local path = os.getenv('HOME') .. '/.wezterm_font_size'
   local f = io.open(path, 'r')
   if f then
      local size = tonumber(f:read('*a'))
      f:close()
      if size and size >= 6 and size <= 40 then
         return size
      end
   end
   return default_font_size
end

local font_size = load_saved_font_size()

---@type Config
return {
   font = wezterm.font_with_fallback({
      { family = font_family, weight = 'Regular' },
      { family = 'Noto Sans Arabic', weight = 'Medium' },
      { family = 'Noto Kufi Arabic', weight = 'Medium' },
      'Noto Color Emoji',
   }),
   font_size = font_size,

   --ref: https://wezfurlong.org/wezterm/config/lua/config/freetype_pcf_long_family_names.html#why-doesnt-wezterm-use-the-distro-freetype-or-match-its-configuration
   freetype_load_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
   freetype_render_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
}
