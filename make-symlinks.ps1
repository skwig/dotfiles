echo $PSScriptRoot
cmd /c mklink "%UserProfile%\AppData\Local\Microsoft\PowerToys\Keyboard Manager\default.json" "$PSScriptRoot\PowerToys\Keyboard Manager\default.json"
cmd /c mklink "%UserProfile%\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" "$PSScriptRoot\wt\settings.json"
cmd /c mklink "%UserProfile%\.glzr\glazewm\config.yaml" "$PSScriptRoot\glazewm\config.yaml"
cmd /c mklink "%UserProfile%\.ideavimrc" "$PSScriptRoot\ideavim\.ideavimrc"