# =========================
# Windows SSH Bootstrap (Idempotent)
# =========================

$ErrorActionPreference = "Stop"

# -------------------------
# CONFIG (edit this section)
# -------------------------

$SSHD_PORT = 17937

$AuthorizedKeys = @(
"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKBYbvBqHC1HbBgrSXPVc3UDqMjCqjr/k1jqQIpnPJR skwig@blackbox",
"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDfbf7RIFcpdW+9ryqeDoRYEeors8vMRj2ILh+UC66xm skwig@smallbox",
"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPK6B/HcG55FYYlfz8Ok9Z6B1L2MnEZpZqgumq7RJJSI skwig@android"
)

# -------------------------
# 1. Ensure OpenSSH Server installed
# -------------------------

$cap = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'

if ($cap.State -ne "Installed") {
    Write-Host "Installing OpenSSH Server..."
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
} else {
    Write-Host "OpenSSH Server already installed."
}

# -------------------------
# 2. Ensure service exists and running
# -------------------------

$svc = Get-Service sshd -ErrorAction SilentlyContinue

if (-not $svc) {
    throw "sshd service not found even after installation."
}

if ($svc.Status -ne "Running") {
    Start-Service sshd
}

Set-Service sshd -StartupType Automatic

# -------------------------
# 3. Configure sshd_config
# -------------------------

$sshdConfig = "C:\ProgramData\ssh\sshd_config"

if (!(Test-Path $sshdConfig)) {
    throw "sshd_config not found. OpenSSH install may have failed."
}

$config = Get-Content $sshdConfig

function Set-ConfigLine {
    param (
        [string[]]$config,
        [string]$pattern,
        [string]$replacement
    )

    if ($config -match $pattern) {
        return ($config -replace $pattern, $replacement)
    } else {
        return $config + $replacement
    }
}

$config = Set-ConfigLine $config "^#?Port\s+.*" "Port $SSHD_PORT"
$config = Set-ConfigLine $config "^#?PermitRootLogin\s+.*" "PermitRootLogin no"
$config = Set-ConfigLine $config "^#?PasswordAuthentication\s+.*" "PasswordAuthentication no"
$config = Set-ConfigLine $config "^#?KbdInteractiveAuthentication\s+.*" "KbdInteractiveAuthentication no"
$config = Set-ConfigLine $config "^#?PubkeyAuthentication\s+.*" "PubkeyAuthentication yes"
$config = Set-ConfigLine $config "^#?AuthorizedKeysFile\s+.*" "AuthorizedKeysFile .ssh/authorized_keys"

$config | Set-Content $sshdConfig -Encoding ascii

Restart-Service sshd

# -------------------------
# 4. Firewall rule
# -------------------------

$ruleName = "OpenSSH-$SSHD_PORT"

if (-not (Get-NetFirewallRule -Name $ruleName -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule `
        -Name $ruleName `
        -DisplayName "OpenSSH Server ($SSHD_PORT)" `
        -Direction Inbound `
        -Action Allow `
        -Protocol TCP `
        -LocalPort $SSHD_PORT
} else {
    Write-Host "Firewall rule already exists."
}

# -------------------------
# 5. Setup authorized_keys
# -------------------------

$sshDir = "$env:USERPROFILE\.ssh"
$authKeys = "$sshDir\authorized_keys"

if (!(Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir | Out-Null
}

icacls $sshDir /inheritance:r | Out-Null
icacls $sshDir /grant "$($env:USERNAME):(F)" | Out-Null
icacls $authKeys /inheritance:r | Out-Null
icacls $authKeys /grant "$($env:USERNAME):(F)" | Out-Null

$desired = ($AuthorizedKeys -join "`n").Trim()
$desired | Set-Content $authKeys -Encoding ascii

takeown /F $authKeys /A | Out-Null
icacls $authKeys /setowner "$env:USERNAME" | Out-Null

icacls $authKeys /inheritance:r | Out-Null
icacls $authKeys /grant "$($env:USERNAME):(F)" | Out-Null

icacls $authKeys /remove "Administrators" 2>$null | Out-Null
icacls $authKeys /remove "SYSTEM" 2>$null | Out-Null

# -------------------------
# DONE
# -------------------------

Write-Host "`n=== SSH Bootstrap Complete ==="
Write-Host "Port: $SSHD_PORT"
