Write-Host "Starting dotfiles setup..."

# Get the directory where the script actually lives
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Config paths
$localConfig = "$env:LOCALAPPDATA"
$weztermDir = Join-Path $env:USERPROFILE ".config\wezterm"
New-Item -ItemType Directory -Force -Path (Join-Path $localConfig "nvim") | Out-Null
New-Item -ItemType Directory -Force -Path $weztermDir | Out-Null

# Copy files from repo
Write-Host "Copying config files..."
Copy-Item -Recurse -Force "$scriptRoot\..\nvim\*" (Join-Path $localConfig "nvim\")
Copy-Item -Recurse -Force "$scriptRoot\..\wezterm\*" "$weztermDir\"

Write-Host "Configuration complete!"
