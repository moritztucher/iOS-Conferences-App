#!/bin/bash
set +e
SIM=A7189E72-B981-470A-AD85-1F7E53E1D5C0
BUNDLE=com.moritztucher.dubdub-ios-conference
DIR=/Users/moritztucher/Private/iOS-Conferences/marketing/raw
LOG=/tmp/recsearch_status.txt
: > "$LOG"

cap() { for i in $(seq 1 12); do rm -f "$1"; xcrun simctl io "$SIM" screenshot "$1" >/dev/null 2>&1; [ -s "$1" ] && { echo "OK $(basename $1) (try $i)" >> "$LOG"; return 0; }; sleep 2; done; echo "FAIL $(basename $1)" >> "$LOG"; }
tap() { axe tap -x "$1" -y "$2" --udid "$SIM" >/dev/null 2>&1; }

# Fresh relaunch resets all filters to default (All kinds / All formats)
xcrun simctl terminate "$SIM" "$BUNDLE" >/dev/null 2>&1
sleep 1
xcrun simctl launch "$SIM" "$BUNDLE" >/dev/null 2>&1
sleep 4

# Tap the search field and type a query that has matches
tap 196 150
sleep 1
axe type "Swift" --udid "$SIM" >/dev/null 2>&1
sleep 1
# dismiss keyboard so results fill the screen (tap a neutral area / scroll)
axe swipe --start-x 196 --start-y 500 --end-x 196 --end-y 470 --udid "$SIM" >/dev/null 2>&1
sleep 2
cap "$DIR/05-search.png"
echo "DONE" >> "$LOG"
