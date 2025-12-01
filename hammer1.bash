#!/usr/bin/env bash
# hammer.sh — accurate drop-rate tester for bashttpd / nc servers

TARGET="${1:-http://localhost:8080}"
PARALLEL="${2:-2}"      # how many concurrent curls
TOTAL="${3:-10}"       # total requests to send

echo "Hammering $TARGET — $PARALLEL concurrent, $TOTAL total requests"
echo "Press Ctrl-C to stop early"

# Temporary file for results
tmp=$(mktemp)

# Run the attack
seq "$TOTAL" | \
  xargs -n1 -P"$PARALLEL" -I{} \
    curl -s -o /dev/null -w "%{http_code}\n" --max-time 8 "$TARGET" > "$tmp" 2>/dev/null

# Final stats
success=$(grep -c "^200" "$tmp")
failed=$(( TOTAL - success ))

echo
echo "Finished!"
echo "Successful (200): $success"
echo "Dropped/failed  : $failed  (timeouts, resets, refused, etc.)"
printf "Drop rate       : %.2f%%\n" "$(bc -l <<< "100 * $failed / $TOTAL")"

rm -f "$tmp"
