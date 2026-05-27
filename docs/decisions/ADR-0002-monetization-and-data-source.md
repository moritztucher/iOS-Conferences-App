# ADR-0002: Data Source and Open Source

## Status

**Accepted (in part) · Amended 2026-05-27.**
The original ADR also locked in a StoreKit 2 "Buy me a coffee" tip as the
monetization model. That decision was reversed on 2026-05-27 — the app
no longer ships any in-app purchase or monetization mechanism. The
monetization section and the four monetization-alternative sub-sections
have been removed below. The data-source and open-source decisions stand
unchanged.

## Context

After ADR-0001, two product-shaping questions remained open:

1. **Where does the conference data come from?** No backend is desired; data needs to be maintainable without ongoing ops cost.
2. **Will the project be open source?** The user is considering making the repo public.

The two decisions are intertwined: making the repo public influences the data-source strategy (no private endpoints).

## Decision

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

- The conference list is a JSON file checked into the repo (`data/conferences.json`).
- The app fetches it at runtime from `cdn.jsdelivr.net/gh/<owner>/<repo>@<branch>/data/conferences.json` (CDN edges) with `raw.githubusercontent.com/<owner>/<repo>/<branch>/data/conferences.json` as a fallback.
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
  - Bundle ID `studio.pocketapps.iOS-Conferences` stays with the original; any forker who ships their own version is expected to change it.

### Favourites

Local-only via a separate SwiftData model `FavouriteConference { conferenceID: String, favouritedAt: Date }`. Decoupled from the cached `Conference` so refreshing the conference cache never touches favourites. No accounts, no cross-device sync at MVP.

## Consequences

### Pros
- **Zero infrastructure cost.** No backend, no database hosting, no CDN bill. GitHub + Apple handle everything.
- **Transparency.** Anyone can see exactly what conferences are listed and propose changes. This is also a strong trust signal.
- **Free distribution boost.** GitHub Stars, blog mentions of "this is open source", and inclusion in awesome-swiftui-style lists are real channels.

### Cons
- **PR moderation overhead.** Someone has to review and merge data PRs. Untrue or low-quality entries need a `CONTRIBUTING.md` rubric and willingness to say no.
- **Data freshness is human-driven.** A conference change of dates or cancellation only updates when someone PRs it. Acceptable for a small app, but document the SLA explicitly as "best-effort, community-driven."
- **GitHub becomes a hard dependency.** If `raw.githubusercontent.com` or jsdelivr is down, refresh fails. SwiftData cache makes this graceful, but it's worth knowing. Mitigation: try the CDN first, fall back to raw URL.
- **Public repo = visible mistakes.** Bugs, ugly commits, and bad decisions are all on display. Mitigate by keeping early work on a `develop` branch and tagging the first public release once it's presentable.

## Alternatives Considered

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

- MIT License text — https://opensource.org/licenses/MIT
- jsDelivr GitHub CDN — https://www.jsdelivr.com/?docs=gh

## Date

2026-05-18 (original) · Amended 2026-05-27 (monetization section removed)
