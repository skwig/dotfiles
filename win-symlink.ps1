echo $PSScriptRoot

cmd /c IF EXIST "%UserProfile%\AppData\Local\Microsoft\PowerToys\Keyboard Manager\default.json" DEL "%UserProfile%\AppData\Local\Microsoft\PowerToys\Keyboard Manager\default.json"
cmd /c mklink "%UserProfile%\AppData\Local\Microsoft\PowerToys\Keyboard Manager\default.json" "$PSScriptRoot\PowerToys\Keyboard Manager\default.json"

cmd /c IF EXIST "%UserProfile%\AppData\Local\Microsoft\PowerToys\PowerToys Run\settings.json" DEL "%UserProfile%\AppData\Local\Microsoft\PowerToys\PowerToys Run\settings.json"
cmd /c mklink "%UserProfile%\AppData\Local\Microsoft\PowerToys\PowerToys Run\settings.json" "$PSScriptRoot\PowerToys\PowerToys Run\settings.json"

cmd /c IF EXIST "%UserProfile%\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" DEL "%UserProfile%\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
cmd /c mklink "%UserProfile%\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" "$PSScriptRoot\wt\settings.json"

cmd /c IF EXIST "%UserProfile%\.glzr\glazewm\config.yaml" DEL "%UserProfile%\.glzr\glazewm\config.yaml"
cmd /c mklink "%UserProfile%\.glzr\glazewm\config.yaml" "$PSScriptRoot\glazewm\config.yaml"

New-Item "~\.config\wezterm\wezterm.lua" -Type File -Force
cmd /c IF EXIST "%UserProfile%\.config\wezterm\wezterm.lua" DEL "%UserProfile%\.config\wezterm\wezterm.lua"
cmd /c mklink "%UserProfile%\.config\wezterm\wezterm.lua" "$PSScriptRoot\wezterm\wezterm.lua"

cmd /c IF EXIST "%UserProfile%\.ideavimrc" DEL "%UserProfile%\.ideavimrc"
cmd /c MKLINK "%UserProfile%\.ideavimrc" "$PSScriptRoot\ideavim\.ideavimrc"

cmd /c IF EXIST "%UserProfile%\AppData\Local\nvim" RMDIR "%UserProfile%\AppData\Local\nvim"
cmd /c MKLINK /D "%UserProfile%\AppData\Local\nvim" "$PSScriptRoot\nvim\"

# $Profile is the path to the powershell profile. Usually ~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1
New-Item "$Profile" -Type File -Force
cmd /c IF EXIST "$Profile" DEL "$Profile"
cmd /c MKLINK "$Profile" "$PSScriptRoot\powershell\Microsoft.Powershell_profile.ps1"
