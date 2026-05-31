#!/bin/bash
set +e
SIM=A7189E72-B981-470A-AD85-1F7E53E1D5C0
BUNDLE=com.moritztucher.dubdub-ios-conference
DIR=/Users/moritztucher/Private/iOS-Conferences/marketing/raw
LOG=/tmp/recap_status.txt
: > "$LOG"

cap() { for i in $(seq 1 12); do rm -f "$1"; xcrun simctl io "$SIM" screenshot "$1" >/dev/null 2>&1; [ -s "$1" ] && { echo "OK $(basename $1) (try $i)" >> "$LOG"; return 0; }; sleep 2; done; echo "FAIL $(basename $1)" >> "$LOG"; }
tap() { axe tap -x "$1" -y "$2" --udid "$SIM" >/dev/null 2>&1; }

# Fresh relaunch -> default filter (All kinds / All formats), list visible
xcrun simctl terminate "$SIM" "$BUNDLE" >/dev/null 2>&1
sleep 1
xcrun simctl launch "$SIM" "$BUNDLE" >/dev/null 2>&1
sleep 4

# Tap the 4th row (CommunityKit, a multi-day in-person conference -> rich detail)
tap 150 410
sleep 3
cap "$DIR/02-detail.png"
echo "DONE" >> "$LOG"
