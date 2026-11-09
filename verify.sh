#!/usr/bin/env bash
# Run with: sudo ./verify.sh
set -uo pipefail
cd "$(dirname "$0")"
[ "$(id -u)" -eq 0 ] || { echo "Run with sudo:  sudo ./verify.sh" >&2; exit 1; }
ip netns list | grep -q outsider || { echo "Run sudo ./setup.sh first"; exit 1; }
pass=0; failn=0
check() { local d="$1"; shift; if "$@" >/dev/null 2>&1; then echo "PASS  $d"; pass=$((pass+1)); else echo "FAIL  $d"; failn=$((failn+1)); fi; }
open_from()   { ip netns exec "$1" timeout 2 bash -c "exec 3<>/dev/tcp/$2/$3"; }
closed_from() { ! open_from "$@"; }

echo "== The firewall =="
check "ufw is active"                                          bash -c "ufw status | head -1 | grep -qi 'Status: active'"
check "default for incoming traffic is deny"                   bash -c "ufw status verbose | grep -i '^Default:' | grep -qi 'deny (incoming)'"

echo "== The outsider (the internet) =="
check "can open the web port 8080"                             open_from outsider 10.77.0.1 8080
check "cannot reach the admin shell on 2200"                   closed_from outsider 10.77.0.1 2200
check "cannot reach PostgreSQL on 5432"                        closed_from outsider 10.77.0.1 5432
check "cannot reach Redis on 6379"                             closed_from outsider 10.77.0.1 6379
check "cannot reach the metrics on 9100"                       closed_from outsider 10.77.0.1 9100

echo "== The office (trusted network 10.78.0.2) =="
check "can open the web port 8080"                             open_from office 10.78.0.1 8080
check "can open the admin shell on 2200"                       open_from office 10.78.0.1 2200
check "can read the metrics on 9100"                           open_from office 10.78.0.1 9100
check "still cannot reach PostgreSQL on 5432"                  closed_from office 10.78.0.1 5432
check "still cannot reach Redis on 6379"                       closed_from office 10.78.0.1 6379

echo "== The server itself =="
check "the app on this machine can still reach PostgreSQL via localhost" bash -c "timeout 2 bash -c 'exec 3<>/dev/tcp/127.0.0.1/5432'"
check "the rule for 2200 is limited to the office, not Anywhere" bash -c "ufw status | grep -E '^2200' | grep -qv Anywhere\$ || ufw status | grep -E '2200.*10.78.0.2'"

echo "== Your record =="
check "ufw-rules.txt shows your rules (8080 and the office address)" bash -c "grep -q 8080 ufw-rules.txt && grep -q 10.78.0.2 ufw-rules.txt"

echo
if [ "$failn" -eq 0 ]; then echo "ALL CHECKS PASSED ($pass/$pass)"; else echo "$failn check(s) failed, $pass passed"; fi
exit "$failn"
