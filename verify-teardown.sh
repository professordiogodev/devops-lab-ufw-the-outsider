#!/usr/bin/env bash
# Proves the lab environment is gone. Run with: sudo ./verify-teardown.sh
set -uo pipefail
cd "$(dirname "$0")"
[ "$(id -u)" -eq 0 ] || { echo "Run with sudo:  sudo ./verify-teardown.sh" >&2; exit 1; }
pass=0; failn=0
check() { local d="$1"; shift; if "$@" >/dev/null 2>&1; then echo "PASS  $d"; pass=$((pass+1)); else echo "FAIL  $d"; failn=$((failn+1)); fi; }
no_user() { ! id "$1" >/dev/null 2>&1; }
no_group() { ! getent group "$1" >/dev/null 2>&1; }
no_path() { [ ! -e "$1" ]; }
no_proc() { ! pgrep -f "$1" >/dev/null 2>&1; }
no_listener() { ! ss -ltn 2>/dev/null | grep -qE ":$1\\b"; }

check "ufw is disabled" bash -c "ufw status | head -1 | grep -qi inactive"
check "no ufw rules remain" bash -c "[ \"\$(ufw show added 2>/dev/null | grep -c '^ufw ')\" = 0 ]"
check "network namespace 'outsider' is gone" bash -c "! ip netns list | grep -q outsider"
check "network namespace 'office' is gone" bash -c "! ip netns list | grep -q office"
check "virtual links vh-out and vh-off are gone" bash -c "! ip link show 2>/dev/null | grep -qE 'vh-out|vh-off'"
check "no lab listener process" no_proc 'services/listener.py'
check "/var/lib/clippy-lab is gone" no_path /var/lib/clippy-lab

echo
if [ "$failn" -eq 0 ]; then echo "TEARDOWN VERIFIED ($pass/$pass)"; else echo "NOT CLEAN: $failn leftover(s). Finish the tear down steps and run this again."; fi
exit "$failn"
