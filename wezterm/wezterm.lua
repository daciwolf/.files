local wezterm = require 'wezterm'
local config = {}

-- Detect Git Bash path dynamically
local git_bash_paths = {
  "C:\\Program Files\\Git\\bin\\bash.exe",
  "C:\\Program Files (x86)\\Git\\bin\\bash.exe",
  "C:\\msys64\\usr\\bin\\bash.exe",
}

local bash_path = nil
for _, path in ipairs(git_bash_paths) do
  local f = io.open(path, "r")
  if f then
    f:close()
    bash_path = path
    break
  end
end

if wezterm.target_triple:find("windows") then
  if bash_path then
    config.default_prog = { bash_path, "-l" }
  else
    -- Prefer PowerShell if available
    local pwsh_candidates = {
      "C:\\Program Files\\PowerShell\\7\\pwsh.exe",
      "C:\\Program Files\\PowerShell\\7-preview\\pwsh.exe",
    }
    local pwsh_path = nil
    for _, p in ipairs(pwsh_candidates) do
      local f = io.open(p, "r")
      if f then f:close(); pwsh_path = p; break end
    end

    if pwsh_path then
      config.default_prog = { pwsh_path, "-NoLogo" }
    else
      local win_ps = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
      local f = io.open(win_ps, "r")
      if f then
        f:close()
        config.default_prog = { win_ps, "-NoLogo" }
      else
        wezterm.log_error("No Git Bash or PowerShell found; using cmd.exe fallback")
        config.default_prog = { "C:\\Windows\\System32\\cmd.exe" }
      end
    end
  end
else
  config.default_prog = { "/bin/bash", "-l" }
end

-- UI preferences
-- Prefer an Aura color scheme if present; otherwise fall back to Gruvbox
local aura_scheme = nil
local ok, builtin = pcall(wezterm.get_builtin_color_schemes)
if ok and builtin then
  for name, _ in pairs(builtin) do
    if name:lower():find("aura") then aura_scheme = name; break end
  end
end
config.color_scheme = aura_scheme or "Gruvbox Dark"
config.font_size = 12.0
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

return config
