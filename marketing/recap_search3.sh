#!/bin/bash
set +e
SIM=A7189E72-B981-470A-AD85-1F7E53E1D5C0
BUNDLE=com.moritztucher.dubdub-ios-conference
DIR=/Users/moritztucher/Private/iOS-Conferences/marketing/raw
LOG=/tmp/recsearch3.txt
: > "$LOG"

cap() { for i in $(seq 1 12); do rm -f "$1"; xcrun simctl io "$SIM" screenshot "$1" >/dev/null 2>&1; [ -s "$1" ] && return 0; sleep 2; done; return 1; }

filtered() {
  # returns 0 if the visible list looks filtered to Swift events
  axe describe-ui --udid "$SIM" 2>/dev/null > /tmp/ui_f.json
  local s w
  s=$(LC_ALL=C grep -c -a -i "swift" /tmp/ui_f.json)
  w=$(LC_ALL=C grep -c -a "WWDC Run" /tmp/ui_f.json)
  echo "  probe swift=$s wwdc_run=$w" >> "$LOG"
  [ "$s" -ge 1 ] && [ "$w" -eq 0 ]
}

xcrun simctl terminate "$SIM" "$BUNDLE" >/dev/null 2>&1
sleep 1
xcrun simctl launch "$SIM" "$BUNDLE" >/dev/null 2>&1
sleep 4

OK=0
for Y in 95 100 88 120 130 78; do
  echo "try y=$Y" >> "$LOG"
  axe tap -x 200 -y "$Y" --udid "$SIM" >/dev/null 2>&1
  sleep 1
  axe type "Swift" --udid "$SIM" >/dev/null 2>&1
  sleep 2
  if filtered; then echo "FOCUSED at y=$Y" >> "$LOG"; OK=1; break; fi
  # clear whatever we typed and reset before next attempt
  xcrun simctl terminate "$SIM" "$BUNDLE" >/dev/null 2>&1
  sleep 1
  xcrun simctl launch "$SIM" "$BUNDLE" >/dev/null 2>&1
  sleep 4
done

if [ "$OK" -eq 1 ]; then
  # dismiss keyboard so results fill the screen
  axe swipe --start-x 200 --start-y 500 --end-x 200 --end-y 460 --udid "$SIM" >/dev/null 2>&1
  sleep 2
  cap "$DIR/05-search.png" && echo "CAPTURED" >> "$LOG" || echo "CAPFAIL" >> "$LOG"
  axe describe-ui --udid "$SIM" 2>/dev/null > /tmp/ui_final.json
  echo "final swift=$(LC_ALL=C grep -c -a -i swift /tmp/ui_final.json) wwdc_run=$(LC_ALL=C grep -c -a 'WWDC Run' /tmp/ui_final.json)" >> "$LOG"
  echo "RESULT=SEARCH_OK" >> "$LOG"
else
  echo "RESULT=FALLBACK" >> "$LOG"
fi
echo "DONE" >> "$LOG"
