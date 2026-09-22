local gpu_adapters = require('utils.gpu-adapter')
local backdrops = require('utils.backdrops')
local colors = require('colors.custom')

---@type Config
return {
   max_fps = 60,
   front_end = 'OpenGL', ---@type 'WebGpu' | 'OpenGL' | 'Software'
   webgpu_power_preference = 'HighPerformance',
   webgpu_preferred_adapter = gpu_adapters:pick_best(),
   underline_thickness = '1.5pt',

   -- cursor
   animation_fps = 60,
   cursor_blink_ease_in = 'EaseIn',
   cursor_blink_ease_out = 'EaseOut',
   default_cursor_style = 'BlinkingBlock',
   cursor_blink_rate = 500,

   -- color scheme
   colors = colors,

   -- background
   background = backdrops:initial_options({ no_img = false }),

   -- scrollbar
   enable_scroll_bar = true,

   -- tab bar
   enable_tab_bar = true,
   use_fancy_tab_bar = true,
   tab_max_width = 999,
   tab_bar_at_bottom = false,
   hide_tab_bar_if_only_one_tab = false,
   show_tab_index_in_tab_bar = false,
   switch_to_last_active_tab_when_closing_tab = true,

   -- pane status
   window_decorations = 'TITLE | RESIZE',
   window_background_opacity = 0.9,

   -- command palette
   command_palette_fg_color = '#b4befe',
   command_palette_bg_color = '#11111b',
   command_palette_font_size = 12,
   command_palette_rows = 25,

   -- window
   window_padding = {
      left = 0,
      right = 0,
      top = 0,
      bottom = 0,
   },
   adjust_window_size_when_changing_font_size = false,
   window_close_confirmation = 'NeverPrompt',
   window_frame = {
      active_titlebar_bg = '#090909',
      font_size = 14.5,
   },
   
   inactive_pane_hsb = {
      saturation = 0.7,
      brightness = 0.3,
   },

   visual_bell = {
      fade_in_function = 'EaseIn',
      fade_in_duration_ms = 250,
      fade_out_function = 'EaseOut',
      fade_out_duration_ms = 250,
      target = 'CursorColor',
   },
}
