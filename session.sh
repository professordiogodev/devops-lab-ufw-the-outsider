#!/usr/bin/env bash
# An open "admin session" from the office to the SSH-like port 2200.
#   sudo ./session.sh start    open it      sudo ./session.sh status    is it still alive?
[ "$(id -u)" -eq 0 ] || { echo "Run with sudo" >&2; exit 1; }
case "${1:-}" in
  start) ip netns pids office 2>/dev/null | xargs -r kill 2>/dev/null; sleep 1
         ip netns exec office setsid nohup bash -c 'exec -a session-holder bash -c "exec 3<>/dev/tcp/10.78.0.1/2200; sleep 600"' >/dev/null 2>&1 &
         sleep 1; echo "Office admin session opened." ;;
  status) if ip netns exec office ss -tn 2>/dev/null | grep -q '10.78.0.1:2200.*ESTAB\|ESTAB.*10.78.0.1:2200'; then echo "Session: ALIVE (connection still established)"; else echo "Session: DEAD"; fi ;;
  *) echo "usage: sudo ./session.sh start|status" ;;
esac
