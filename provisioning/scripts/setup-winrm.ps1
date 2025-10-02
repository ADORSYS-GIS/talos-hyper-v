<#
  Run on the Hyper-V host (as Administrator).
  Example:
    .\setup_winrm.ps1 -Production:$false
    .\setup_winrm.ps1 -Production:$true -CertSubject "CN=hyperv.example.local"
#>

param(
  [switch]$Production,
  [string]$CertSubject = "CN=hyperv.local",
  [switch]$CreateSelfSignedCert
)

function Fail($m) { Write-Error $m; exit 1 }

Write-Host "Beginning WinRM & firewall setup. Production=$Production"

# 1) Ensure WinRM service and basic config
Write-Host "-> Enabling WinRM service and basic config..."
try {
  winrm quickconfig -q
} catch {
  Fail "Failed to run winrm quickconfig: $_"
}

# 2) Adjust authentication settings
Write-Host "-> Configuring auth settings..."
# Allow Negotiate (NTLM) and Basic if required
winrm set winrm/config/service/auth '@{Negotiate="true"}' | Out-Null
if (-not $Production) {
  # for non-prod convenience allow Basic and unencrypted if explicit
  winrm set winrm/config/service/auth '@{Basic="true"}' | Out-Null
  winrm set winrm/config/service '@{AllowUnencrypted="true"}' | Out-Null
  Write-Host "   Non-production: Basic+AllowUnencrypted enabled (for testing only)."
} else {
  # production: do not allow unencrypted
  winrm set winrm/config/service/auth '@{Basic="false"}' | Out-Null
  winrm set winrm/config/service '@{AllowUnencrypted="false"}' | Out-Null
  Write-Host "   Production: Basic and AllowUnencrypted disabled."
}

# 3) Firewall rules for WinRM
Write-Host "-> Opening firewall ports 5985 (HTTP) and 5986 (HTTPS) for WinRM..."
New-NetFirewallRule -DisplayName "WinRM HTTP-In"  -Direction Inbound -Action Allow -Protocol TCP -LocalPort 5985 -Profile Any -ErrorAction SilentlyContinue | Out-Null
New-NetFirewallRule -DisplayName "WinRM HTTPS-In" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 5986 -Profile Any -ErrorAction SilentlyContinue | Out-Null

# 4) Setup HTTPS listener for production (requires certificate)
if ($Production) {
  Write-Host "-> Production: ensuring HTTPS listener and certificate..."
  # either find an existing cert matching subject or create a self-signed one (if requested)
  $cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Subject -like "*$CertSubject*" } | Select-Object -First 1
  if (-not $cert -and $CreateSelfSignedCert) {
    Write-Host "   No existing cert found; creating self-signed cert for $CertSubject (valid 2 years)."
    $cert = New-SelfSignedCertificate -DnsName ($CertSubject -replace "CN=","") -CertStoreLocation Cert:\LocalMachine\My -NotAfter (Get-Date).AddYears(2)
    if (-not $cert) { Fail "Could not create self-signed certificate." }
  }
  if (-not $cert) { Fail "No certificate available for HTTPS listener; supply certificate before proceeding." }

  $thumb = $cert.Thumbprint
  Write-Host "   Using certificate thumbprint: $thumb"

  # Create HTTPS listener
  # Remove existing winrm HTTPS listener to avoid duplicates
  try { winrm delete winrm/config/Listener?Address=*+Transport=HTTPS 2>$null } catch {}
  winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=''; CertificateThumbprint='$thumb'}" | Out-Null

  # ensure service uses certificate and disallow unencrypted
  winrm set winrm/config/service '@{AllowUnencrypted="false"}' | Out-Null
  Write-Host "   HTTPS WinRM listener created with cert."
  Write-Host "-> IMPORTANT: If your Terraform runner is external, ensure the runner trusts this certificate (add to trusted root or set provider insecure=true for testing)."
} else {
  # non-prod: create HTTP listener if not present
  Write-Host "-> Ensuring HTTP listener exists (non-production)..."
  try { winrm delete winrm/config/Listener?Address=*+Transport=HTTP 2>$null } catch {}
  winrm create winrm/config/Listener?Address=*+Transport=HTTP "@{Hostname='';Port='5985'}" | Out-Null
  Write-Host "   HTTP listener configured on 5985 (AllowUnencrypted enabled for testing)."
}

# 5) Ensure network bindings: advise to check vEthernet adapter after external switch creation
Write-Host "`nSetup complete. Next steps (manual verification recommended):"
Write-Host " - Run 'winrm enumerate winrm/config/listener' to view listeners."
Write-Host " - Run 'Get-NetFirewallRule -DisplayName \"WinRM *\" | Format-Table' to confirm firewall."
Write-Host " - If you use an HTTPS self-signed cert, add it to the runner's Trusted Root CA store or set insecure connection on the client."
Write-Host " - If using an External VSwitch, ensure the host's vEthernet adapter has proper IP (run Get-NetIPAddress -InterfaceAlias \"vEthernet (<SwitchName>)\")."

if ($Production) {
  Write-Host "Production certificate thumbprint: $thumb"
}
