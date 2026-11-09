#!/usr/bin/env bash
# Builds the network: this machine (the server), "outsider" (the internet) and "office" (your office). Run with: sudo ./setup.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Run with sudo:  sudo ./setup.sh" >&2; exit 1; }
cd "$(dirname "$0")"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq && apt-get install -y -qq ufw python3 iproute2 netcat-openbsd >/dev/null
./teardown.sh >/dev/null 2>&1 || true
ufw --force disable >/dev/null 2>&1 || true

mk() { # name hostif hostip peerip
  ip netns add "$1"
  ip link add "$2" type veth peer name "v-$1"
  ip link set "v-$1" netns "$1"
  ip addr add "$3/24" dev "$2"; ip link set "$2" up
  ip netns exec "$1" ip addr add "$4/24" dev "v-$1"; ip netns exec "$1" ip link set "v-$1" up; ip netns exec "$1" ip link set lo up
}
mk outsider vh-out 10.77.0.1 10.77.0.2
mk office   vh-off 10.78.0.1 10.78.0.2

mkdir -p /var/lib/clippy-lab; : > /var/lib/clippy-lab/pids
start() { setsid nohup python3 services/listener.py "$1" "$2" >/dev/null 2>&1 & echo $! >> /var/lib/clippy-lab/pids; }
start 8080 "clippy-web: hello"
start 2200 "SSH-2.0-ClippyFake admin shell"
start 5432 "postgres: clippy database"
start 6379 "redis: clippy cache"
start 9100 "metrics: node exporter"
cp scan.sh /var/lib/clippy-lab/scan.sh 2>/dev/null || true
sleep 1
echo "Network ready. Server = 10.77.0.1 / 10.78.0.1. outsider = 10.77.0.2, office = 10.78.0.2"
echo "Try:  sudo ./scan.sh outsider"
