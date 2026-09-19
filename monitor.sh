#!/usr/bin/env bash
# Checks that the website answers, writes one line to a log file,
# and restarts the container if the check fails.
#
# Usage:  bash scripts/monitor.sh [health-url]
# Run it every 5 minutes with cron (see the README).
set -u

URL="${1:-http://localhost/health}"
LOG="${LOG_FILE:-$HOME/site-monitor.log}"
NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

if curl -fsS --max-time 5 "$URL" >/dev/null 2>&1; then
  echo "$NOW OK $URL" >> "$LOG"
else
  echo "$NOW FAIL $URL - restarting container 'website'" >> "$LOG"
  docker restart website >> "$LOG" 2>&1 || echo "$NOW restart failed" >> "$LOG"
  exit 1
fi
