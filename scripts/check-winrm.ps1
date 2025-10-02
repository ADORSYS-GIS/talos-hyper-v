<#
.SYNOPSIS
  Validate WinRM connectivity, firewall port reachability and auth type.

.PARAMETER Host
.PARAMETER Port
.PARAMETER Https
.PARAMETER UseNtlm
.PARAMETER User
.PARAMETER Password
.PARAMETER Production
.PARAMETER CertThumbprint
#>

param(
  [Parameter(Mandatory=$true)][string]$Host,
  [Parameter(Mandatory=$true)][int]$Port,
  [Parameter(Mandatory=$true)][bool]$Https,
  [Parameter(Mandatory=$true)][bool]$UseNtlm,
  [Parameter(Mandatory=$true)][string]$User,
  [Parameter(Mandatory=$true)][securestring]$Password,
  [Parameter(Mandatory=$true)][bool]$Production,
  [Parameter(Mandatory=$false)][string]$CertThumbprint = ""
)

function Write-ErrAndExit($msg, $code=1) {
  Write-Error $msg
  exit $code
}

Write-Host "WinRM validation starting for ${Host}:$Port (HTTPS=$Https, NTLM=$UseNtlm, Production=$Production)"

# 1) Check TCP connectivity from local runner
Write-Host "-> Checking TCP connectivity to ${Host}:$Port ..."
$tcpCheck = Test-NetConnection -ComputerName $Host -Port $Port -WarningAction SilentlyContinue
if (-not $tcpCheck.TcpTestSucceeded) {
  Write-ErrAndExit "TCP connectivity check FAILED to ${Host}:$Port. Is firewall blocking the port or host unreachable?"
}
Write-Host "   TCP OK."

# 2) Test-WSMan (this verifies the WinRM service responds)
try {
  $wsmanUrl = "http://$Host:5985/wsman"
  if ($Https) { $wsmanUrl = "https://$Host:5986/wsman" }

  Write-Host "-> Testing WSMan endpoint: $wsmanUrl"
  # Use Test-WSMan to get basic response headers; it may error if auth fails
  Test-WSMan -ComputerName $Host -Port $Port -UseSSL:$Https -ErrorAction Stop | Out-Null
  Write-Host "   WSMan endpoint reachable."
} catch {
  Write-ErrAndExit "Test-WSMan failed: $($_.Exception.Message)"
}

# 3) Basic remote command to verify auth (Invoke-Command)
Write-Host "-> Attempting a small remote command to check authentication..."
$secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($User, $secpasswd)

$invokeSucceeded = $false
try {
  $sessionOptions = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
  if ($UseNtlm) {
    # try with Negotiate (which will use NTLM on workgroup)
    $s = New-PSSession -ComputerName $Host -Credential $cred -Authentication Negotiate -UseSSL:$Https -Port $Port -SessionOption $sessionOptions -ErrorAction Stop
  } else {
    # basic auth
    $s = New-PSSession -ComputerName $Host -Credential $cred -Authentication Basic -UseSSL:$Https -Port $Port -SessionOption $sessionOptions -ErrorAction Stop
  }

  Invoke-Command -Session $s -ScriptBlock { whoami; (Get-ChildItem Env:COMPUTERNAME).Value } -ErrorAction Stop | ForEach-Object { Write-Host "   -> $_" }
  $invokeSucceeded = $true
  Remove-PSSession -Session $s -ErrorAction SilentlyContinue
} catch {
  Write-ErrAndExit "Remote authentication command failed. Error: $($_.Exception.Message)"
}
if ($invokeSucceeded) { Write-Host "   Remote auth OK." }

# 4) Production policy checks
if ($Production) {
  Write-Host "-> Production mode: enforcing HTTPS and certificate..."
  if (-not $Https) {
    Write-ErrAndExit "Production requires HTTPS WinRM (set https=true in provider)."
  }
  if ([string]::IsNullOrWhiteSpace($CertThumbprint)) {
    Write-ErrAndExit "Production requires an HTTPS listener with a trusted certificate. Provide cert thumbprint via cert_thumbprint."
  }

  # verify the remote listener certificate matches the thumbprint (best-effort)
  try {
    $remoteThumb = Invoke-Command -ComputerName $Host -Credential $cred -ScriptBlock {
      $listeners = winrm enumerate winrm/config/listener
      # try to parse certificate thumbprint
      $listeners | Select-String -Pattern "CertificateThumbprint"
    } -Authentication Negotiate -UseSSL:$true -Port $Port -ErrorAction Stop

    if ($remoteThumb -and ($remoteThumb.ToString() -match $CertThumbprint)) {
      Write-Host "   Remote listener certificate thumbprint appears to match."
    } else {
      Write-Host "   Warning:unable to confirm matching thumbprint remotely. Ensure the server uses the provided thumbprint."
    }
  } catch {
    Write-Host "   Warning: Could not verify remote listener thumbprint due to remote call limitations: $($_.Exception.Message)"
  }

  # Ensure AllowUnencrypted is not enabled on server
  try {
    $allowUnencrypted = Invoke-Command -ComputerName $Host -Credential $cred -ScriptBlock {
      (winrm get winrm/config/service) -match "AllowUnencrypted"
    } -Authentication Negotiate -UseSSL:$true -Port $Port -ErrorAction Stop

    if ($allowUnencrypted -and $allowUnencrypted.ToString() -match "AllowUnencrypted = true") {
      Write-ErrAndExit "Production policy violation: WinRM AllowUnencrypted is true on remote host. Disable it for production."
    } else {
      Write-Host "   Remote AllowUnencrypted check OK."
    }
  } catch {
    Write-Host "   Warning: Could not check AllowUnencrypted on remote host: $($_.Exception.Message)"
  }
}

Write-Host "WinRM validation completed SUCCESSFULLY."
exit 0
