#!/bin/bash
# Capture all app screens via simctl + AXe, with robust retries, then report.
set +e
SIM=A7189E72-B981-470A-AD85-1F7E53E1D5C0
BUNDLE=com.moritztucher.dubdub-ios-conference
DIR=/Users/moritztucher/Private/iOS-Conferences/marketing/raw
mkdir -p "$DIR"
LOG=/tmp/capture_status.txt
: > "$LOG"

cap() { # $1 = output path
  for i in $(seq 1 12); do
    rm -f "$1"
    xcrun simctl io "$SIM" screenshot "$1" >/dev/null 2>&1
    if [ -s "$1" ]; then echo "OK   $(basename $1) (try $i)" >> "$LOG"; return 0; fi
    sleep 2
  done
  echo "FAIL $(basename $1)" >> "$LOG"; return 1
}
tap()   { axe tap -x "$1" -y "$2" --udid "$SIM" >/dev/null 2>&1; }
swipe() { axe swipe --start-x "$1" --start-y "$2" --end-x "$3" --end-y "$4" --udid "$SIM" >/dev/null 2>&1; }

# Fresh start
xcrun simctl terminate "$SIM" "$BUNDLE" >/dev/null 2>&1
sleep 1
xcrun simctl launch "$SIM" "$BUNDLE" >/dev/null 2>&1
sleep 4

# 1) List
cap "$DIR/01-list.png"

# 2) Filter menu (toolbar icon top-right)
tap 355 78; sleep 2
cap "$DIR/04-filter.png"
tap 196 460; sleep 1   # dismiss menu

# 3) Detail — tap a row (4th row ~ y 137pt center)
tap 150 137; sleep 2
cap "$DIR/02-detail.png"
swipe 5 400 380 400; sleep 1   # back
swipe 5 400 380 400; sleep 1

# 4) Search
tap 196 150; sleep 1
axe type "swift" --udid "$SIM" >/dev/null 2>&1; sleep 2
cap "$DIR/05-search.png"
tap 360 150; sleep 1            # clear
swipe 5 400 380 400 >/dev/null 2>&1; sleep 1

# 5) Settings tab (right third of tab bar)
tap 333 815; sleep 2
cap "$DIR/03-settings.png"

echo "---- LISTING ----" >> "$LOG"
ls -la "$DIR" >> "$LOG" 2>&1
echo "DONE" >> "$LOG"
