#!/usr/bin/env bash
set -euo pipefail

# This script validates WinRM connectivity using winrm-cli.

#--- Parameters --------------------------------------------------------------
TARGET_HOST=""
PORT=""
USER=""
PASSWORD=""
USE_HTTPS=false
USE_NTLM=false
PRODUCTION=false
CERT_THUMBPRINT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -TargetHost)
            TARGET_HOST="$2"
            shift 2
            ;;
        -Port)
            PORT="$2"
            shift 2
            ;;
        -User)
            USER="$2"
            shift 2
            ;;
        -Password)
            PASSWORD="$2"
            shift 2
            ;;
        -Https)
            USE_HTTPS=true
            shift
            ;;
        -UseNtlm)
            USE_NTLM=true
            shift
            ;;
        -Production)
            PRODUCTION=true
            shift
            ;;
        -CertThumbprint)
            CERT_THUMBPRINT="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

#--- Helper functions --------------------------------------------------------
log() { echo "[$(date +%T)] $*"; }
err_exit() { log "❌ $1"; exit 1; }

#--- 1) TCP connectivity ----------------------------------------------------
log "Checking TCP connectivity to ${TARGET_HOST}:${PORT} ..."
if ! timeout 5 bash -c "cat < /dev/null > /dev/tcp/${TARGET_HOST}/${PORT}" 2>/dev/null; then
    err_exit "TCP connection failed"
fi
log "✅ TCP OK"

#--- 2) Basic WinRM endpoint test -------------------------------------------
PROTO="http"
if [[ "$USE_HTTPS" == "true" ]]; then PROTO="https"; fi

log "Testing WSMan endpoint (${PROTO}://${TARGET_HOST}:${PORT}/wsman) ..."
WINRM_FLAGS=""
if [[ "$USE_NTLM" == "true" ]]; then WINRM_FLAGS="-ntlm"; fi
if [[ "$USE_HTTPS" == "true" ]]; then WINRM_FLAGS="$WINRM_FLAGS -https"; fi

if ! ~/go/bin/winrm-cli \
        -hostname "${TARGET_HOST}" \
        -port "${PORT}" \
        -username "${USER}" \
        -password "${PASSWORD}" \
        -insecure \
        $WINRM_FLAGS \
        exec "whoami" >/dev/null; then
    err_exit "WSMan endpoint not reachable or authentication failed"
fi
log "✅ WSMan endpoint reachable and authentication successful"

log "WinRM validation completed SUCCESSFULLY"
exit 0