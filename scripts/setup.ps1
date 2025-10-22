Write-Host "Starting dotfiles setup..."

# ---------- Helpers ----------
function Ensure-InPath {
  param(
    [Parameter(Mandatory=$true)][string]$Dir
  )
  $current = [Environment]::GetEnvironmentVariable('Path','User')
  if (-not ($current -split ';' | Where-Object { $_ -eq $Dir })) {
    $newPath = if ($current) { "$current;$Dir" } else { $Dir }
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "Added to PATH (User): $Dir"
  }
}

function Install-IfMissing {
  param(
    [Parameter(Mandatory=$true)][string]$CheckCmd,
    [Parameter(Mandatory=$true)][string]$WingetId,
    [string]$DisplayName
  )
  if (-not (Get-Command $CheckCmd -ErrorAction SilentlyContinue)) {
    $name = if ($DisplayName) { $DisplayName } else { $WingetId }
    Write-Host "Installing $name via winget..."
    try {
      winget install -e --id $WingetId --source winget --accept-source-agreements --accept-package-agreements | Out-Null
    } catch {
      Write-Warning "winget install failed for $name. Please install manually."
    }
  } else {
    Write-Host "$CheckCmd already installed"
  }
}

# Get the directory where the script actually lives
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Detect Windows reliably (PS 5.1 and 7+)
$isWindows = $false
try {
  if ($env:OS -eq 'Windows_NT') { $isWindows = $true }
  elseif ($PSVersionTable.PSEdition -eq 'Desktop') { $isWindows = $true }
  elseif ($PSVersionTable.Platform -eq 'Win32NT') { $isWindows = $true }
} catch {}

# ---------- Core tools (Windows) ----------
if ($isWindows) {
  Write-Host "Windows detected; installing core tools via winget..."
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Warning "winget is not available. Install 'App Installer' from Microsoft Store, then rerun this script."
  }
  # Git is required for lazy.nvim plugin bootstrap
  Install-IfMissing -CheckCmd git -WingetId 'Git.Git' -DisplayName 'Git'

  # Neovim editor
  Install-IfMissing -CheckCmd nvim -WingetId 'Neovim.Neovim' -DisplayName 'Neovim'

  # LLVM provides clang, clangd (LSP), clang-format
  Install-IfMissing -CheckCmd clangd -WingetId 'LLVM.LLVM' -DisplayName 'LLVM (clang/clangd)'
  $llvmBin = 'C:\\Program Files\\LLVM\\bin'
  if (Test-Path $llvmBin) { Ensure-InPath -Dir $llvmBin }

  # Optional: PowerShell 7 for a nicer shell
  if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
    try { winget install -e --id 'Microsoft.PowerShell' --source winget --accept-source-agreements --accept-package-agreements | Out-Null } catch {}
  }
}

# Config paths
$localConfig = "$env:LOCALAPPDATA"
$weztermDir = Join-Path $env:USERPROFILE ".config\wezterm"
New-Item -ItemType Directory -Force -Path (Join-Path $localConfig "nvim") | Out-Null
New-Item -ItemType Directory -Force -Path $weztermDir | Out-Null

# Copy files from repo
Write-Host "Copying config files..."
Copy-Item -Recurse -Force "$scriptRoot\..\nvim\*" (Join-Path $localConfig "nvim\")
Copy-Item -Recurse -Force "$scriptRoot\..\wezterm\*" "$weztermDir\"

Write-Host "Refreshing PATH for current session..."
$machinePath = [Environment]::GetEnvironmentVariable('Path','Machine')
$userPath = [Environment]::GetEnvironmentVariable('Path','User')
if ($machinePath -and $userPath) {
  $env:Path = "$machinePath;$userPath"
} elseif ($userPath) {
  $env:Path = $userPath
}

Write-Host "Verifying tool versions (ignore errors if just installed; try a new terminal):"
foreach ($cmd in @('git','nvim','clang','clangd')) {
  try {
    $v = & $cmd --version 2>$null | Select-Object -First 1
    if ($LASTEXITCODE -eq 0 -and $v) { Write-Host (" - {0}: {1}" -f $cmd, $v) }
    else { Write-Warning (" - {0}: not available yet" -f $cmd) }
  } catch { Write-Warning (" - {0}: not found" -f $cmd) }
}

Write-Host "Configuration complete! Open a NEW terminal for PATH changes to take effect."
