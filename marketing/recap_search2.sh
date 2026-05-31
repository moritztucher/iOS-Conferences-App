#!/bin/bash
set +e
SIM=A7189E72-B981-470A-AD85-1F7E53E1D5C0
BUNDLE=com.moritztucher.dubdub-ios-conference
DIR=/Users/moritztucher/Private/iOS-Conferences/marketing/raw
LOG=/tmp/recsearch2.txt
: > "$LOG"

cap() { for i in $(seq 1 12); do rm -f "$1"; xcrun simctl io "$SIM" screenshot "$1" >/dev/null 2>&1; [ -s "$1" ] && return 0; sleep 2; done; return 1; }

xcrun simctl terminate "$SIM" "$BUNDLE" >/dev/null 2>&1
sleep 1
xcrun simctl launch "$SIM" "$BUNDLE" >/dev/null 2>&1
sleep 4

# Search field sits just under the large "Conferences" title.
# AXe uses POINTS. Sim is 402pt wide; field center x~200, y~110pt.
axe tap -x 200 -y 110 --udid "$SIM" >/dev/null 2>&1
sleep 1
axe type "Swift" --udid "$SIM" >/dev/null 2>&1
sleep 2

# Verify the list is now filtered: dump UI text and check it mentions Swift events
# and NOT the unrelated default rows (e.g. "WWDC Run").
axe describe-ui --udid "$SIM" 2>/dev/null > /tmp/ui_search.json
SWIFT_HITS=$(LC_ALL=C grep -c -a -i "swift" /tmp/ui_search.json)
WWDCRUN=$(LC_ALL=C grep -c -a "WWDC Run" /tmp/ui_search.json)
echo "swift_hits=$SWIFT_HITS wwdc_run=$WWDCRUN" >> "$LOG"

# Dismiss keyboard so results fill screen (swipe the list up slightly)
axe swipe --start-x 200 --start-y 500 --end-x 200 --end-y 460 --udid "$SIM" >/dev/null 2>&1
sleep 2

cap "$DIR/05-search.png" && echo "CAPTURED" >> "$LOG" || echo "CAPFAIL" >> "$LOG"

# Re-dump after dismissing keyboard for the record
axe describe-ui --udid "$SIM" 2>/dev/null > /tmp/ui_search2.json
echo "after_swift=$(LC_ALL=C grep -c -a -i swift /tmp/ui_search2.json) after_wwdcrun=$(LC_ALL=C grep -c -a 'WWDC Run' /tmp/ui_search2.json)" >> "$LOG"
echo "DONE" >> "$LOG"
