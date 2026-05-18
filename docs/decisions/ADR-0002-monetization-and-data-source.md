# ADR-0002: Monetization, Data Source, and Open Source

## Status

Accepted

## Context

After ADR-0001, three product-shaping questions remained open:

1. **How does the app make money?** The user wants a small "buy me a coffee" tip rather than subscriptions, ads, or upsells.
2. **Where does the conference data come from?** No backend is desired; data needs to be maintainable without ongoing ops cost.
3. **Will the project be open source?** The user is considering making the repo public.

The three decisions are intertwined: making the repo public influences both the data-source strategy (no private endpoints) and the monetization model (the IAP product is tied to the original developer's App Store account, not the repo).

## Decision

### Monetization: repeatable consumable StoreKit 2 IAP

- **Product:** one **consumable** IAP at **€1.49** (price tier 2 in App Store Connect). Consumable (not non-consumable) so users can tip again.
- **Display name:** "Buy me a coffee ☕" (or similar).
- **Placement:** a single row in Settings/About. The button is always tappable — repeat purchases are the point. **No nags anywhere else in the app.**
- **No "Restore Purchases" button** — consumables cannot be restored on iOS; each transaction is one-shot.
- **Local tip counter:** count successful purchases in UserDefaults to power a friendly "You've bought me N coffees ☕ — thank you!" line. Not authoritative for entitlement (there's no entitlement) — purely UX.
- **Implementation:** StoreKit 2 (`Product.products(for:)`, `Product.purchase()`, transaction listener, `await transaction.finish()` after each one). **No RevenueCat** — overkill for one product.
- **Why not an external "Buy Me a Coffee" / Stripe / PayPal link?** Apple's Guideline 3.1.1 requires IAP for developer tips and gratuities consumed in-app. External payment links for this purpose get rejected.

### Community Contributions: GitHub-Issue-based "Suggest a Conference"

- **In-app form** (in Settings + the list's empty state) with fields: name, website URL, start date, end date, location, one-line description, optional contributor name.
- **Submit action:** construct a GitHub Issues URL using the issue-template query string format:
  `https://github.com/<owner>/<repo>/issues/new?template=conference-request.yml&title=<urlencoded>&body=<urlencoded>`
  and open it in `SFSafariViewController`. The user is then on GitHub, signs in if needed, and presses Submit.
- **Repo side:** `.github/ISSUE_TEMPLATE/conference-request.yml` defines the structured form so issues come in consistent. A maintainer then converts approved issues into PRs against `data/conferences.json`.
- **Fallback:** if the GitHub URL can't be opened (extremely unlikely), the form falls back to a `mailto:` with the same prefilled body.
- **Escape hatch:** a footer link "Already discussed? Comment on the running thread →" opens a single pinned `Suggestions` issue in Safari. Useful for one-liner additions where filling the structured form is overkill.
- **Why not a backend form / Google Form?** Avoids the ops cost and the "where does the data live" problem. Issues are already version-controlled, discoverable, and integrate with the PR workflow.

### Data Source: `conferences.json` in the public GitHub repo

- The conference list is a JSON file checked into the repo (e.g. `data/conferences.json`).
- The app fetches it at runtime from `raw.githubusercontent.com/<owner>/<repo>/main/data/conferences.json` or, for better availability and CDN edges, `cdn.jsdelivr.net/gh/<owner>/<repo>@main/data/conferences.json`.
- SwiftData caches the parsed list locally → offline-first works the same as before.
- **Community contributions:** new conferences are added via Pull Requests against the JSON file. `CONTRIBUTING.md` documents the schema.
- **Zero hosting cost.** No serverless function, no Firebase, no Supabase, no S3 — just GitHub.

### Open Source: MIT License

- **License:** MIT — standard for SwiftUI sample-style apps; permissive, well-understood.
- **Repository structure:**
  - `iOS-Conferences/` — the Xcode project
  - `data/conferences.json` — the data file (the actual content the app shows)
  - `README.md` — what it is, how to run, how to contribute
  - `CONTRIBUTING.md` — JSON schema, PR conventions
  - `LICENSE` — MIT
- **Repo rules:**
  - No secrets in the code (none today — no auth, no API keys).
  - The IAP product ID is a constant in code; the App Store Connect product is owned by the original developer's account. Forkers must register their own IAP under their own bundle ID.
  - Bundle ID `com.pocketapps.conferences` stays with the original; any forker who ships their own version is expected to change it.

### Favourites

Local-only via a separate SwiftData model `FavouriteConference { conferenceID: String, favouritedAt: Date }`. Decoupled from the cached `Conference` so refreshing the conference cache never touches favourites. No accounts, no cross-device sync at MVP.

## Consequences

### Pros
- **Zero infrastructure cost.** No backend, no database hosting, no CDN bill. GitHub + Apple handle everything.
- **Transparency.** Anyone can see exactly what conferences are listed and propose changes. This is also a strong trust signal.
- **Free distribution boost.** GitHub Stars, blog mentions of "this is open source", and inclusion in awesome-swiftui-style lists are real channels.
- **Forkability without revenue leakage.** Forkers can't accidentally collect tips meant for the original developer — the IAP is tied to the original App Store account.
- **Single SKU = trivial StoreKit code.** No subscription edge cases, no entitlement gating, no restore-cross-platform complexity.

### Cons
- **PR moderation overhead.** Someone has to review and merge data PRs. Untrue or low-quality entries need a `CONTRIBUTING.md` rubric and willingness to say no.
- **Data freshness is human-driven.** A conference change of dates or cancellation only updates when someone PRs it. Acceptable for a small app, but document the SLA explicitly as "best-effort, community-driven."
- **GitHub becomes a hard dependency.** If `raw.githubusercontent.com` or jsdelivr is down, refresh fails. SwiftData cache makes this graceful, but it's worth knowing. Mitigation: try the CDN first, fall back to raw URL.
- **Revenue ceiling is tiny.** A €1.49 tip from a small fraction of users is rounding error compared to a subscription. This is by design — the goal is to cover hosting (there is none) and buy the developer a coffee, not to build a business.
- **Public repo = visible mistakes.** Bugs, ugly commits, and bad decisions are all on display. Mitigate by keeping early work on a `develop` branch and tagging the first public release once it's presentable.

## Alternatives Considered

### Monetization: subscription
- **Pros:** recurring revenue, smooths cash flow.
- **Cons:** wildly disproportionate to the value delivered (one screen of factual data). Would also require Apple's subscription disclosure UX, restore handling, and trial expiration screens. Strong **no**.

### Monetization: ads
- **Pros:** revenue without asking users to pay.
- **Cons:** ruins the UX of an "at-a-glance overview" app, requires an SDK (privacy disclosure, App Store Privacy Nutrition Label complications), and the eCPM on a tiny niche app is not worth it. Strong **no**.

### Monetization: external "Buy Me a Coffee" link
- **Pros:** zero Apple cut, dead simple to add.
- **Cons:** **Apple Guideline 3.1.1 rejection.** Tips for app developers consumed in-app must use IAP. Not worth the rejection.

### Monetization: RevenueCat for the single tip
- **Pros:** future-proof if more products are added; nicer dashboards.
- **Cons:** SDK weight and complexity for one product. Free tier covers it, but it's pure overkill for one consumable. StoreKit 2 directly is ~50 lines.

### Monetization: non-consumable IAP
- **Pros:** restorable across devices, only one purchase per user.
- **Cons:** the user explicitly wants the tip to be **repeatable** — non-consumable would block re-purchases. Wrong product type for a tip jar.

### Suggest-a-conference: native form posting to a serverless function
- **Pros:** no GitHub account required for the user.
- **Cons:** reintroduces backend ops cost we just designed out. The contribution flywheel is the whole point of the open-source data model — submissions belong in the same Git history as the data they modify.

### Data source: backend (Firebase / Supabase / a serverless function)
- **Pros:** richer queries, real-time updates, an admin UI.
- **Cons:** monthly cost, ops burden, deployment pipeline, and another secret to manage. The PR-based model handles freshness adequately at this scale.

### Data source: scraping conference sites
- **Pros:** no manual entry.
- **Cons:** legal risk (ToS, robots.txt), maintenance burden (each site changes its HTML), and brittleness. JSON-in-repo is cleaner.

### License: Apache 2.0
- **Pros:** explicit patent grant.
- **Cons:** there's no patent surface here. MIT is shorter, more familiar, and sufficient.

### License: closed source
- **Pros:** total control.
- **Cons:** loses the community-data-curation flywheel, which is the whole reason the no-backend model works.

## References

- Apple App Store Guideline 3.1.1 (In-App Purchase) — https://developer.apple.com/app-store/review/guidelines/#in-app-purchase
- StoreKit 2 docs — https://developer.apple.com/documentation/storekit
- MIT License text — https://opensource.org/licenses/MIT
- jsDelivr GitHub CDN — https://www.jsdelivr.com/?docs=gh

## Date

2026-05-18
