#!/usr/bin/env bash
# Port scan the server from a point of view. usage: sudo ./scan.sh outsider|office
who="${1:-outsider}"
case "$who" in outsider) target=10.77.0.1 ;; office) target=10.78.0.1 ;; *) echo "usage: sudo ./scan.sh outsider|office"; exit 1 ;; esac
echo "Scanning $target from '$who' ..."
for p in 80 443 2200 5432 6379 8080 9100; do
  if ip netns exec "$who" timeout 2 bash -c "exec 3<>/dev/tcp/$target/$p" 2>/dev/null; then echo "  $p/tcp  OPEN"; else echo "  $p/tcp  closed or filtered"; fi
done
