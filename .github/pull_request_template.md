<!--
Base branch must be `develop` (not `main` — `main` is release-only).
Title format: CONF-<area>: <imperative summary>   e.g. CONF-list: sort conferences by start date
See CONTRIBUTING.md for conventions.
-->

## What & why

<!-- What does this change, and why? -->

## Related issue

<!-- e.g. Closes #12 -->

## Checklist

- [ ] Base branch is `develop`
- [ ] Title follows `CONF-<area>: <imperative summary>`
- [ ] Builds green (`xcodebuild -project iOS-Conferences.xcodeproj -scheme iOS-Conferences -destination 'generic/platform=iOS Simulator' build`)
- [ ] Matches existing patterns; no unnecessary new shared components (see `docs/VIEW-INVENTORY.md`)
- [ ] Docs/ADR updated if behaviour or a design decision changed
