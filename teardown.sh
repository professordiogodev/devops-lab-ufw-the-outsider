#!/usr/bin/env bash
# Run with: sudo ./teardown.sh
[ "$(id -u)" -eq 0 ] || { echo "Run with sudo" >&2; exit 1; }
ufw --force disable >/dev/null 2>&1; ufw --force reset >/dev/null 2>&1
ip netns pids office 2>/dev/null | xargs -r kill 2>/dev/null; pkill -f 'services/listener.py' 2>/dev/null
ip netns del outsider 2>/dev/null; ip netns del office 2>/dev/null
ip link del vh-out 2>/dev/null; ip link del vh-off 2>/dev/null
rm -rf /var/lib/clippy-lab
echo "Lab environment removed."
