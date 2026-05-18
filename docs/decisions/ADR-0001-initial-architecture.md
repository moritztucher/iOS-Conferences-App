# ADR-0001: Initial Architecture Decisions

## Status

Accepted

## Context

iOS-Conferences is a lightweight conference-aggregator app: it shows a chronologically sorted list of upcoming developer/tech conferences, opens a detail view with name/date/location/description/link, lets the user add the event to their system calendar, and opens the conference website in-app.

Constraints:
- Solo developer, MVP-scoped.
- iOS-only, modern target (iOS 18+) — we can use the latest SwiftUI/SwiftData APIs.
- No user accounts in MVP — keeps the legal/privacy footprint minimal and avoids Keychain/biometrics work.
- Content sourcing must respect copyright and trademarks — only factual data is stored, descriptions are paraphrased, logos are not bundled.
- Conferences should be browsable without a network connection after first fetch.

Open questions answered at init:
- Is listing conferences legal? **Yes**, with care around copying descriptions verbatim and using trademarked logos.
- Is linking to conference sites legal? **Yes**, especially via `SFSafariViewController`, which preserves the original domain visibility.

## Decision

| Area | Choice |
|------|--------|
| Project name | iOS-Conferences |
| Bundle ID | `com.pocketapps.conferences` |
| Git commit prefix | `CONF` |
| iOS target | iOS 26+ |
| Design language | Liquid Glass (iOS 26 native) — `.glassEffect()`, `GlassEffectContainer`, system toolbar/tab adoption |
| UI framework | SwiftUI (only) |
| Architecture | MVVM with a `NavigationCoordinator` (NavigationPath) |
| Concurrency | async/await only (no Combine, no completion handlers) |
| State | `@Observable` macro |
| Dependency injection | SwiftUI `Environment` (no global singletons) |
| Database | SwiftData |
| Networking | REST, wrapped in `NetworkService` |
| Auth | None |
| Navigation pattern | Simple `NavigationStack` with a coordinator |
| Sync strategy | Local-only (single-device SwiftData cache) |
| Offline support | Offline-first — cached list is browsable; refresh updates the cache |
| Biometrics / Keychain | No (no sensitive state) |
| Calendar integration | EventKit (`EKEventStore` + `EKEvent`) |
| External links | `SFSafariViewController` |
| Heavy background work | None expected |
| Accessibility priority | Standard (VoiceOver labels, Dynamic Type, `accessibilityReduceMotion` guard) |

## Consequences

### Pros
- **Lean stack:** zero third-party SPM dependencies at MVP — only system frameworks. Faster builds, fewer supply-chain risks.
- **Modern APIs from day one:** SwiftData, `@Observable`, `NavigationPath` — no migration debt in 12 months.
- **Low legal risk:** no user accounts, public factual data only, in-app Safari preserves attribution.
- **Offline-first feels instant:** SwiftData is the source of truth for the UI, network refresh is opportunistic.
- **Easy to evolve:** the NavigationCoordinator already uses NavigationPath, so adding tabs or deep links later is additive, not a rewrite.

### Cons
- **SwiftData is still maturing:** model-schema migrations, predicates, and threading semantics have rough edges that may bite during data evolution.
- **REST without GraphQL:** if the data source ends up being multiple feeds with different shapes, the client may need a normalising layer (acceptable trade-off — we don't know our source yet).
- **No auth means no per-user personalisation** (favourites, watched-list) without later adding either local-only persistence or an account system.
- **Self-hosted data dependency:** we'll need either an API or a curated JSON file checked into a repo / served from a CDN — that's a hidden ops cost.

## Alternatives Considered

### Database: CoreData
- **Pros:** mature, well-understood, plays nicely with CloudKit if multi-device sync is added later.
- **Cons:** verbose boilerplate, NSManagedObject ceremony, weaker Swift ergonomics than SwiftData. SwiftData covers our needs with far less code.

### Database: RealmSwift
- **Pros:** great DX, fast, battle-tested, easy migrations.
- **Cons:** third-party dependency, MongoDB/Realm has gone through ownership churn (sunset of Realm Sync's free tier, etc.). For a simple cache, SwiftData wins.

### Networking: GraphQL
- **Pros:** flexible queries, single endpoint, strong typing via Apollo or similar.
- **Cons:** overkill for a static-ish conference list; adds a heavy SPM dependency and a learning curve we don't need.

### Navigation: Multi-tab from day one
- **Pros:** forces the architecture to handle multiple roots early.
- **Cons:** we have one feature today (the list). YAGNI — start with a single stack, the coordinator pattern keeps the door open to tabs.

### Auth: Apple Sign-In + favourites
- **Pros:** unlocks per-user favourites and watched-list across devices.
- **Cons:** burdens the MVP with sign-in UX, privacy disclosures, and backend storage. Defer until there's a clear product reason.

### Web view: WKWebView
- **Pros:** more control over the rendering pipeline.
- **Cons:** loses the URL bar / share / Reader-mode affordances and increases the chance of looking like we're rebranding the conference site. `SFSafariViewController` is the legally safer and more user-trustworthy choice.

## References

- iOS guide: `~/.claude/docs/ios/ios-guide.md`
- Framework guides relevant to this stack:
  - SwiftData: `~/.claude/docs/ios/data/swiftdata.md`
  - EventKit: `~/.claude/docs/ios/system/eventkit.md`
- Apple docs:
  - `SFSafariViewController` — https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller
  - `EKEventStore` — https://developer.apple.com/documentation/eventkit/ekeventstore

## Date

2026-05-18
