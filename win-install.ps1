# https://scoop.sh/
# Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# https://chocolatey.org/install
try {
  Set-PSDebug -Trace 1

  & "$PSScriptRoot/win-install.nonelevated.ps1"
  Start-Process -FilePath powershell.exe -Verb Runas -ArgumentList "-NoExit -File $PSScriptRoot/win-install.elevated.ps1"
} finally {
  Set-PSDebug -Trace 0
}
