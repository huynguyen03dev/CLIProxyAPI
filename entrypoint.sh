#!/bin/sh
# Raise file descriptor limits before starting the proxy.
# Some hosts (Render free tier, shared containers) start with a low soft limit
# (1024), which causes fsnotify watcher creation to fail with
# "too many open files" once gitstore auths/config files and sockets pile up.
# We raise the soft limit as high as the hard limit allows, then exec the real binary.
set -e

HARD_LIMIT=$(ulimit -Hn 2>/dev/null || echo 1024)
echo "[entrypoint] hard nofile limit: $HARD_LIMIT"

# Try progressively larger soft limits; stop at first success.
for LIMIT in 1048576 524288 65536 16384 4096; do
  if [ "$LIMIT" -le "$HARD_LIMIT" ] 2>/dev/null; then
    if ulimit -n "$LIMIT" 2>/dev/null; then
      echo "[entrypoint] raised soft nofile limit to $(ulimit -n)"
      break
    fi
  fi
done

echo "[entrypoint] final soft nofile limit: $(ulimit -Sn)"
echo "[entrypoint] starting CLIProxyAPI..."
exec /CLIProxyAPI/CLIProxyAPI "$@"
