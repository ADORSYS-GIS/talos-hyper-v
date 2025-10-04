#!/usr/bin/env bash
set -euo pipefail

# This script validates WinRM connectivity using winrm-cli and enumerates active WSMan listeners.

TARGET_HOST=""
USER=""
PASSWORD=""
USE_NTLM=false
PRODUCTION=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -TargetHost)
            TARGET_HOST="$2"
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
        -UseNtlm)
            USE_NTLM=true
            shift
            ;;
        -Production)
            PRODUCTION=true
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

log() { echo "[$(date +%T)] $*"; }
err_exit() { log "❌ $1"; exit 1; }

#--- Enumerate available WSMan listeners -----------------------------------
log "Enumerating WinRM listeners on ${TARGET_HOST}..."

# We will try both default ports; later you can add custom ones
PORTS=(5985 5986)
AVAILABLE_LISTENERS=()

for PORT in "${PORTS[@]}"; do
    if timeout 5 bash -c "cat < /dev/null > /dev/tcp/${TARGET_HOST}/${PORT}" 2>/dev/null; then
        AVAILABLE_LISTENERS+=($PORT)
    fi
done

if [[ ${#AVAILABLE_LISTENERS[@]} -eq 0 ]]; then
    err_exit "No reachable WinRM listeners on default ports (5985/5986)."
fi

log "✅ Reachable ports: ${AVAILABLE_LISTENERS[*]}"

#--- Select the preferred listener ------------------------------------------
# Prefer HTTPS if available
if [[ " ${AVAILABLE_LISTENERS[@]} " =~ "5986" ]]; then
    PORT=5986
    PROTO=https
else
    PORT=5985
    PROTO=http
fi

log "Using listener: ${PROTO}://${TARGET_HOST}:${PORT}"

#--- Test WinRM handshake ---------------------------------------------------
WINRM_FLAGS=""
[[ "$USE_NTLM" == true ]] && WINRM_FLAGS="-ntlm"
[[ "$PROTO" == "https" ]] && WINRM_FLAGS="$WINRM_FLAGS -https"

log "Testing WinRM handshake with ping..."
if ! ~/go/bin/winrm-cli \
        -hostname "$TARGET_HOST" \
        -port "$PORT" \
        -username "$USER" \
        -password "$PASSWORD" \
        -insecure \
        $WINRM_FLAGS \
        whoami; then
    err_exit "WinRM handshake failed (listener unreachable or authentication failed)"
fi

log "✅ WinRM handshake successful"

#--- Optional: enumerate all listeners on the host --------------------------
log "Detected WinRM listeners on ${TARGET_HOST}:"
for LP in "${AVAILABLE_LISTENERS[@]}"; do
    if [[ "$LP" == "5986" ]]; then
        log " - HTTPS listener on port $LP"
    else
        log " - HTTP listener on port $LP"
    fi
done

log "WinRM validation completed SUCCESSFULLY"
exit 0
