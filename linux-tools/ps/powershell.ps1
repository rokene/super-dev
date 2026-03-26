# --- SSH & SOCKS UTILITIES ---

function Get-SshList {
    # Dynamically build the path using the UserProfile environment variable
    $sshConfig = Join-Path $env:USERPROFILE ".ssh\config"
    
    if (-not (Test-Path $sshConfig)) {
        Write-Host "SSH Config not found at $sshConfig" -ForegroundColor Red
        return
    }

    Write-Host "`nDetected SSH Aliases:" -ForegroundColor Cyan
    
    # Read the file and match 'Host' followed by the alias
    # Handles potential encoding quirks by using Get-Content's native parser
    Get-Content $sshConfig | ForEach-Object {
        $line = $_.Trim()
        if ($line -match "^Host\s+(?!Name)(?<alias>[^\s#]+)") {
            Write-Host "  • $($Matches['alias'])" -ForegroundColor White
        }
    }
    Write-Host ""
}

function Start-Socks {
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Alias,
        [int]$Port = 1080
    )

    # Validate port availability
    if (Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue) {
        Write-Host "Error: Port $Port is already in use by another process." -ForegroundColor Red
        return
    }

    Write-Host "Opening SOCKS5 proxy via $Alias on port $Port..." -ForegroundColor Cyan

    # Background Job: Uses the native 'ssh' client which naturally respects ~/.ssh/config
    Start-Job -Name "SshSocks_$Port" -ScriptBlock {
        param($a, $p)
        ssh -D "127.0.0.1:$p" -N -o ExitOnForwardFailure=yes $a
    } | Out-Null

    # Give the job a moment to attempt the handshake
    Start-Sleep -Seconds 2
    $job = Get-Job -Name "SshSocks_$Port"

    if ($job.State -eq "Running") {
        Write-Host "Success: Proxy is active." -ForegroundColor Green
        Write-Host "Usage: Configure browser/app to SOCKS5 127.0.0.1:$Port" -ForegroundColor Gray
    } else {
        Write-Host "Error: Proxy failed to start. Run 'Receive-Job -Name SshSocks_$Port' to debug." -ForegroundColor Red
    }
}

function Stop-Socks {
    param ([int]$Port = 1080)
    
    $jobName = "SshSocks_$Port"
    $job = Get-Job -Name $jobName -ErrorAction SilentlyContinue
    
    if ($job) {
        Stop-Job $job
        Remove-Job $job
        Write-Host "SOCKS5 proxy on port $Port has been terminated." -ForegroundColor Yellow
    } else {
        Write-Host "No active proxy found on port $Port." -ForegroundColor Gray
    }
}

# Aliases for high-speed terminal usage
Set-Alias ssh-list Get-SshList
Set-Alias socks Start-Socks
Set-Alias stop-socks Stop-Socks
