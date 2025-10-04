param(
    [switch]$Production
)

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Run this script as Administrator. Exiting."
    exit 1
}

Write-Host "`n--- Safe WinRM Setup (project-aware) ---`n" -ForegroundColor Cyan

function Get-Listeners {
    $list = @()
    Get-ChildItem WSMan:\localhost\Listener -ErrorAction SilentlyContinue | ForEach-Object {
        $ks = $_.Keys
        $obj = [ordered]@{ Keys = $ks }
        foreach ($k in $ks) {
            if ($k -match '^Address=(.+)$') { $obj.Address = $Matches[1] }
            elseif ($k -match '^Transport=(.+)$') { $obj.Transport = $Matches[1] }
            elseif ($k -match '^Port=(\d+)$') { $obj.Port = [int]$Matches[1] }
            elseif ($k -match '^CertificateThumbprint=(.+)$') { $obj.CertificateThumbprint = $Matches[1] }
        }
        $list += (New-Object PSObject -Property $obj)
    }
    return $list
}

function Ensure-FirewallRuleForPort {
    param($Name, $Port)

    $existing = Get-NetFirewallRule -ErrorAction SilentlyContinue | ForEach-Object {
        $r = $_
        try { $pf = Get-NetFirewallPortFilter -AssociatedNetFirewallRule $r -ErrorAction SilentlyContinue } catch { $pf = $null }
        if ($pf -and ($pf.LocalPort -eq $Port)) { return $r }
    } | Select-Object -First 1

    if (-not $existing) {
        Write-Host "Creating firewall rule '$Name' for TCP $Port..."
        New-NetFirewallRule -Name $Name -DisplayName $Name -Profile Any -Direction Inbound -Action Allow -Protocol TCP -LocalPort $Port | Out-Null
    } else {
        if ($existing.Enabled -ne 'True') {
            Write-Host "Enabling existing firewall rule '$($existing.DisplayName)' for TCP $Port..."
            Set-NetFirewallRule -Name $existing.Name -Enabled True
        } else {
            Write-Host "✅ Firewall rule for TCP $Port already exists and is enabled."
        }
    }
}

# Expected config
if ($Production) {
    $expected = @{ Port = 5986; Transport = "HTTPS" }
    Write-Host "Mode: Production (HTTPS/${expected.Port})" -ForegroundColor Yellow
} else {
    $expected = @{ Port = 5985; Transport = "HTTP" }
    Write-Host "Mode: Non-production (HTTP/${expected.Port})" -ForegroundColor Yellow
}

$listeners = Get-Listeners
Write-Host "`nExisting WSMan listeners:"
if ($listeners.Count -eq 0) { Write-Host "  (none found)" } else { $listeners | Format-Table Port,Transport,Address,CertificateThumbprint -AutoSize }

$match = $listeners | Where-Object { $_.Port -eq $expected.Port -and $_.Transport -eq $expected.Transport } | Select-Object -First 1

if ($match) {
    Write-Host "`n✅ Expected listener already present: $($match.Transport):$($match.Port)"
} else {
    Write-Host "`nCreating expected listener $($expected.Transport):$($expected.Port)..."
    if ($expected.Transport -eq "HTTP") {
        New-WSManInstance -ResourceURI winrm/config/Listener -SelectorSet @{Address="*"; Transport="HTTP"} -ValueSet @{Port=$expected.Port} | Out-Null
    } else {
        $cert = Get-ChildItem Cert:\LocalMachine\My | Select-Object -First 1
        if (-not $cert) { throw "No certificate found in LocalMachine\My for HTTPS listener." }
        New-WSManInstance -ResourceURI winrm/config/Listener -SelectorSet @{Address="*"; Transport="HTTPS"} -ValueSet @{Port=$expected.Port; CertificateThumbprint=$cert.Thumbprint} | Out-Null
    }
}

# Configure auth
if (-not $Production) {
    Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true
    Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true
    Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
    Write-Host "Configured Basic + AllowUnencrypted and TrustedHosts='*'."
} else {
    Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $false
    Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $false
    Write-Host "Configured secure WinRM service (Production)."
}

# Firewall
$fwName = if ($expected.Transport -eq "HTTP") { "WinRM-HTTP-In-TCP" } else { "WinRM-HTTPS-In-TCP" }
Ensure-FirewallRuleForPort -Name $fwName -Port $expected.Port

Write-Host "`n--- Final listener set ---"
(Get-Listeners) | Format-Table Port,Transport,Address,CertificateThumbprint -AutoSize

# Connectivity test
function Get-LocalIPv4 {
    $cand = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notmatch '^127\.' -and $_.AddressState -eq 'Preferred' }
    if ($cand) {
        $v = $cand | Where-Object { $_.InterfaceAlias -match 'vEthernet' } | Select-Object -First 1
        if ($v) { return $v.IPAddress }
        return ($cand | Select-Object -First 1).IPAddress
    }
    return $null
}

$localIP = Get-LocalIPv4
if ($localIP) {
    Write-Host "`nTesting connectivity to ${localIP}:$($expected.Port)..."
    $tn = Test-NetConnection -ComputerName $localIP -Port $expected.Port -WarningAction SilentlyContinue
    Write-Host "TcpTestSucceeded : $($tn.TcpTestSucceeded)"
} else {
    Write-Warning "No suitable IPv4 address found for test."
}

# Connection info
Write-Host "`n--- Connection Info ---" -ForegroundColor Cyan
if ($localIP) { Write-Host "Host: $localIP" }
Write-Host "Port: $($expected.Port)"
Write-Host "Transport: $($expected.Transport)"

if ($expected.Transport -eq "HTTPS") {
    Write-Host "`nLinux/macOS client:"
    Write-Host "  winrm-cli -hostname $localIP -port $($expected.Port) -username Administrator -password '<Password>' -https -insecure"
} else {
    Write-Host "`nLinux/macOS client:"
    Write-Host "  winrm-cli -hostname $localIP -port $($expected.Port) -username Administrator -password '<Password>' -insecure"
}
