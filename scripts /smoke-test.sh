#!/usr/bin/env bash
# Simple checks against a running copy of the site.
# Usage: bash scripts/smoke-test.sh http://localhost:8080
set -euo pipefail

BASE_URL="${1:-http://localhost:8080}"

# Wait up to about 20 seconds for the container to start
for i in 1 2 3 4 5 6 7 8 9 10; do
  if curl -fsS "$BASE_URL/health" >/dev/null 2>&1; then
    break
  fi
  echo "Waiting for the site to start ($i)"
  sleep 2
done

echo "Test 1: /health returns ok"
if [ "$(curl -fsS "$BASE_URL/health")" != "ok" ]; then
  echo "FAIL: /health did not return ok"
  exit 1
fi

BODY="$(curl -fsS "$BASE_URL/")"

echo "Test 2: home page loads and has the expected heading"
if ! grep -q "This page was deployed by a pipeline" <<< "$BODY"; then
  echo "FAIL: heading not found on the home page"
  exit 1
fi

echo "Test 3: commit id was stamped into the page"
if grep -q "__GIT_SHA__" <<< "$BODY"; then
  echo "FAIL: the commit id placeholder was not replaced"
  exit 1
fi

echo "Test 4: an unknown page returns 404"
CODE="$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/does-not-exist")"
if [ "$CODE" != "404" ]; then
  echo "FAIL: expected 404 but got $CODE"
  exit 1
fi

echo "All tests passed"
