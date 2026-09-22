local wezterm = require('wezterm')
local Cells = require('utils.cells')

local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

local ICON_SEPARATOR = nf.oct_dash

local function get_cpu_usage()
   local handle = io.popen("top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print 100 - $1}'")
   if not handle then return "0%" end
   local result = handle:read("*a")
   handle:close()
   local usage = result:gsub("%s+", "")
   if usage == "" then return "0%" end
   return usage .. "%"
end

local function get_gpu_usage()
   -- Try nvidia-smi first (common on Ubuntu)
   local handle = io.popen("nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null")
   if not handle then return "N/A" end
   local result = handle:read("*a")
   handle:close()
   if result == "" then return "0%" end
   return result:gsub("%s+", "") .. "%"
end

local function get_disk_free()
   local handle = io.popen("df -h / --output=avail | tail -1 | tr -d ' ' 2>/dev/null")
   if not handle then return "0G" end
   local result = handle:read("*a")
   handle:close()
   return result:gsub("%s+", "")
end

local function get_smart_python(pane)
   -- Check for Virtualenv first
   local vars = pane:get_user_vars()
   local venv = vars and vars.VIRTUAL_ENV
   if venv then
      local venv_name = venv:match("([^/]+)$")
      return "(" .. venv_name .. ") "
   end
   -- Fallback to system python
   local handle = io.popen('python3 --version 2>/dev/null')
   if not handle then return "" end
   local result = handle:read("*a")
   handle:close()
   return result:gsub("Python ", ""):gsub("%s+", "")
end

-- Performance Cache: Throttle expensive shell commands
local last_update = 0
local cached = { cpu = '0%', gpu = '0%', disk = '0G', py = '' }

---@param opts? table
M.setup = function(opts)
   local colors = {
      cpu     = { fg = '#f38ba8', bg = 'rgba(0, 0, 0, 0.4)' },
      gpu     = { fg = '#fab387', bg = 'rgba(0, 0, 0, 0.4)' },
      disk    = { fg = '#a6e3a1', bg = 'rgba(0, 0, 0, 0.4)' },
      cwd     = { fg = '#cba6f7', bg = 'rgba(0, 0, 0, 0.4)' },
      python  = { fg = '#89b4fa', bg = 'rgba(0, 0, 0, 0.4)' },
      separator = { fg = '#45475a', bg = 'rgba(0, 0, 0, 0.4)' }
   }

   local new_cells = Cells:new()
   new_cells
      :add_segment('cwd_text', '', colors.cwd, attr(attr.intensity('Bold')))
      :add_segment('sep_cwd', ' ' .. ICON_SEPARATOR .. ' ', colors.separator)
      :add_segment('py_icon', nf.dev_python .. ' ', colors.python)
      :add_segment('py_text', '', colors.python, attr(attr.intensity('Bold')))
      :add_segment('sep_py', ' ' .. ICON_SEPARATOR .. ' ', colors.separator)
      :add_segment('cpu_icon', nf.fa_microchip .. ' ', colors.cpu)
      :add_segment('cpu_text', '', colors.cpu, attr(attr.intensity('Bold')))
      :add_segment('sep_cpu', ' ' .. ICON_SEPARATOR .. ' ', colors.separator)
      :add_segment('gpu_icon', nf.fa_server .. ' ', colors.gpu)
      :add_segment('gpu_text', '', colors.gpu, attr(attr.intensity('Bold')))
      :add_segment('sep_gpu', ' ' .. ICON_SEPARATOR .. ' ', colors.separator)
      :add_segment('disk_icon', nf.md_harddisk .. ' ', colors.disk)
      :add_segment('disk_text', '', colors.disk, attr(attr.intensity('Bold')))

   wezterm.on('update-status', function(window, pane)
      local ok, err = pcall(function()
         -- 1. Broadcast Window and Workspace Dimensions
         local sz = window:active_tab():get_size()
         wezterm.GLOBAL.window_width = sz.cols
         wezterm.GLOBAL.workspace_width = #window:active_workspace() + 4

         -- 2. Throttled Data Update (Every 3 seconds)
         local now = os.time()
         if (now - last_update) >= 3 then
            cached.cpu = get_cpu_usage()
            cached.gpu = get_gpu_usage()
            cached.disk = get_disk_free()
            cached.py = get_smart_python(pane)
            last_update = now
         end

         local cwd = pane:get_current_working_dir()
         local cwd_path = cwd and cwd.file_path:match("([^/]+)$") or "~"
         if cwd and cwd.file_path == os.getenv("HOME") then cwd_path = "~" end

         new_cells
            :update_segment_text('cwd_text', cwd_path)
            :update_segment_text('py_text', cached.py)
            :update_segment_text('cpu_text', cached.cpu)
            :update_segment_text('gpu_text', cached.gpu)
            :update_segment_text('disk_text', cached.disk)

         local render_list = { 
            'cwd_text', 'sep_cwd',
            'py_icon', 'py_text', 'sep_py',
            'cpu_icon', 'cpu_text', 'sep_cpu',
            'gpu_icon', 'gpu_text', 'sep_gpu',
            'disk_icon', 'disk_text' 
         }

         local status_text = wezterm.format(new_cells:render(render_list))
         
         -- 3. Calculate status width using stable formula
         wezterm.GLOBAL.status_width = #tostring(cached.cpu) + #tostring(cached.gpu) + #tostring(cached.disk) + 60
         
         window:set_right_status(status_text)
      end)
      
      if not ok then
         wezterm.log_error('right-status error: ' .. tostring(err))
         window:set_right_status('')
      end
   end)
end

return M
