# --- SSH & SOCKS UTILITIES ---

function Get-SshList {
    $sshConfig = Join-Path $env:USERPROFILE ".ssh\config"
    if (-not (Test-Path $sshConfig)) { return }

    Write-Host "`nDetected SSH Aliases:" -ForegroundColor Cyan
    Get-Content $sshConfig | ForEach-Object {
        $line = $_.Trim()
        if ($line -match "^Host\s+(?!Name)(?<alias>[^\s#]+)") {
            Write-Host "  • $($Matches['alias'])" -ForegroundColor White
        }
    }
    Write-Host ""
}

function Start-SocksProxy {
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Alias,

        [Parameter(Mandatory=$false, Position=1)]
        [int]$Port = 1080
    )

    if (Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue) {
        Write-Host "Error: Port $Port is already in use." -ForegroundColor Red
        return
    }

    Write-Host "Opening SOCKS5 proxy via $Alias on port $Port..." -ForegroundColor Cyan

    Start-Job -Name "SshSocks_$Port" -ScriptBlock {
        param($a, $p)
        ssh -D "127.0.0.1:$p" -N -o ExitOnForwardFailure=yes $a
    } -ArgumentList $Alias, $Port | Out-Null

    Start-Sleep -Seconds 2
    if ((Get-Job -Name "SshSocks_$Port").State -eq "Running") {
        Write-Host "Success: Proxy is active on port $Port." -ForegroundColor Green
    } else {
        Write-Host "Error: Proxy failed. Run 'Receive-Job -Name SshSocks_$Port'" -ForegroundColor Red
    }
}

function Stop-SocksProxy {
    param ([int]$Port = 1080)
    $jobName = "SshSocks_$Port"
    
    $job = Get-Job -Name $jobName -ErrorAction SilentlyContinue
    $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue

    if ($job) {
        Stop-Job $job
        Remove-Job $job
        Write-Host "SOCKS5 Job for port $Port terminated." -ForegroundColor Yellow
    }

    if ($connection) {
        Stop-Process -Id $connection.OwningProcess -Force -ErrorAction SilentlyContinue
        Write-Host "Killed SSH process on port $Port." -ForegroundColor Yellow
    }

    if (-not $job -and -not $connection) {
        Write-Host "No active proxy or process found on port $Port." -ForegroundColor Gray
    }
}

# Use 'Set-Alias' but let the function handle the parameters
Set-Alias ssh-list Get-SshList
Set-Alias socks Start-SocksProxy
Set-Alias stopsocks Stop-SocksProxy
