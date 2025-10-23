local wezterm = require("wezterm")
local config = wezterm.config_builder()

local neofusion_theme = {
  foreground = "#e0d9c7",
  background = "#070f1c",
  cursor_bg = "#e0d9c7",
  cursor_border = "#e0d9c7",
  cursor_fg = "#070f1c",
  selection_bg = "#ea6847",
  selection_fg = "#e0d9c7",
  ansi = {
    "#070f1c", -- Black (Host)
    "#ea6847", -- Red (Syntax string)
    "#ea6847", -- Green (Command)
    "#5db2f8", -- Yellow (Command second)
    "#2f516c", -- Blue (Path)
    "#d943a8", -- Magenta (Syntax var)
    "#86dbf5", -- Cyan (Prompt)
    "#e0d9c7", -- White
  },
  brights = {
    "#2f516c", -- Bright Black
    "#d943a8", -- Bright Red (Command error)
    "#ea6847", -- Bright Green (Exec)
    "#86dbf5", -- Bright Yellow
    "#5db2f8", -- Bright Blue (Folder)
    "#d943a8", -- Bright Magenta
    "#ea6847", -- Bright Cyan
    "#e0d9c7", -- Bright White
  },
}

config.colors = neofusion_theme

local function first_existing_path(paths)
  for _, path in ipairs(paths) do
    local handle = io.open(path, "r")
    if handle then
      handle:close()
      return path
    end
  end
  return nil
end

if wezterm.target_triple:find("windows") then
  local bash_path = first_existing_path({
    "C:\\Program Files\\Git\\bin\\bash.exe",
    "C:\\Program Files (x86)\\Git\\bin\\bash.exe",
    "C:\\msys64\\usr\\bin\\bash.exe",
  })

  if bash_path then
    config.default_prog = { bash_path, "-l" }
  else
    local pwsh_path = first_existing_path({
      "C:\\Program Files\\PowerShell\\7\\pwsh.exe",
      "C:\\Program Files\\PowerShell\\7-preview\\pwsh.exe",
    })

    if pwsh_path then
      config.default_prog = { pwsh_path, "-NoLogo" }
    else
      local win_ps = first_existing_path({
        "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
      })

      if win_ps then
        config.default_prog = { win_ps, "-NoLogo" }
      else
        wezterm.log_error("No Git Bash or PowerShell found; using cmd.exe fallback")
        config.default_prog = { "C:\\Windows\\System32\\cmd.exe" }
      end
    end
  end
else
  config.default_prog = { "/bin/zsh", "-l" }
end

config.font_size = 12.0
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

return config
