# iOS 26 Standout Opportunities — Deep Dive

**Date:** 2026-06-01 · **Scope:** how to make the app stand out using iOS 26, without breaking ADR-0003 (ecosystem-native, zero custom design tokens, no custom `.glassEffect()`, no onboarding).

## Strategy

This app's bet (ADR-0003) is that distinctiveness comes from **deep system integration** — "feels like Apple built it" — not custom chrome. So the highest-leverage iOS 26 work is in two buckets:

1. **System presence** — let conferences live *outside* the app: Home/Lock Screen widgets, a Live Activity countdown, Spotlight/Siri, a Control Center control. This is where a one-job app punches above its weight.
2. **In-app native showpieces** — a small number of stock-but-premium moments: an embedded venue map + Look Around, a richer share card, a favourites badge.

Everything below is stock Apple API. None of it adds a custom design token or a custom glass surface.

Legend — **Standout** (how much it differentiates) · **Effort** · **Infra** (new target / entitlement / App Group needed?).

---

## Tier 1 — System presence (the real standouts)

### 1.1 Home & Lock Screen widgets — "Next conference" / countdown
**Standout: ★★★★★ · Effort: Med · Infra: Widget extension + App Group**

A WidgetKit widget that shows the next upcoming (or next *favourited*) conference: name, dates, location, and a live countdown via `Text(date, style: .relative)` / `Text(.timerInterval:)`.
- **Home Screen:** small (countdown + name), medium (next 2–3, like a mini list), large (week ahead).
- **Lock Screen:** `accessoryInline` ("WWDC in 5d"), `accessoryCircular` (countdown ring with `Gauge`), `accessoryRectangular` (next conf + date).
- **Deep link:** `widgetURL` / `Link` into the matching `ConferenceDetailView`.
- **Smart Stack:** `TimelineEntryRelevance` so it surfaces the day a favourited conference starts.

*Why it fits:* a date-sorted conference app's single most useful glanceable fact is "what's next / how soon." This is the feature that makes people keep the app.
*Infra note:* the widget needs the data. Move the SwiftData store (or a lightweight cached JSON) into a shared **App Group** so the widget and app read the same cache.

### 1.2 Live Activity countdown — Dynamic Island + Lock Screen
**Standout: ★★★★★ · Effort: Med-High · Infra: Widget extension + ActivityKit**

For a favourited conference inside its final window (e.g. the last 24–48h, and during the event days), start a Live Activity with a countdown (`Text(timerInterval:)`) that renders in the **Dynamic Island** and on the Lock Screen. "WWDC — starts in 6h" → on the day, "Day 1 · Keynote soon."
- Started locally when the user taps **Track** on a favourited conference (or auto for favourites within the window).
- iOS 26 surfaces Live Activities in more places (CarPlay, Watch Smart Stack), multiplying reach.

*Why it fits:* the Dynamic Island is the most recognizably-iOS showpiece there is; a countdown to a conference you care about is a legitimate, non-gimmicky use.
*Caveat:* Live Activities are for the *imminent/live* window, not a months-out countdown — pair with the widget (1.1) which owns the long-range countdown. We have no session-level data, so keep the content to event-level (name, day N, start time).

### 1.3 Spotlight + App Intents + Siri — the CLAUDE.md integration
**Standout: ★★★★☆ · Effort: Med · Infra: App Intents (in-app, no extension) + entitlement for Siri**

Make conferences first-class system citizens:
- **`AppEntity` / `IndexedEntity`** for `Conference` → index every conference in **Core Spotlight** on each data refresh. Searching "WWDC" in system Spotlight surfaces the conference and deep-links into detail.
- **App Intents:** `OpenConferenceIntent`, `FindConferencesIntent(filter:)`, `AddConferenceToCalendarIntent`. These also power widget interactivity and Shortcuts.
- **`AppShortcutsProvider`:** "Hey Siri, when's the next conference?" / "Show my conference favourites."
- **iOS 26 Assistant schemas** (`@AssistantEntity`/`@AssistantIntent`): let Apple Intelligence reason over conferences.

*Why it fits:* CLAUDE.md explicitly names Spotlight + App Intents as carrying the "feels like Apple built it" weight. Highest "native credibility" per unit effort, and no new target.

### 1.4 Control Center / Action Button control
**Standout: ★★★☆☆ · Effort: Low-Med · Infra: Widget extension (`ControlWidget`)**

A `ControlWidget` for Control Center / Lock Screen / Action Button: "Next conference" (opens it) or "Search conferences" (opens the search tab via an App Intent). Cheap once a widget extension exists for 1.1/1.2.

---

## Tier 2 — In-app native showpieces

### 2.1 Embedded venue map + Look Around in the detail  ⭐ best pure-design pick
**Standout: ★★★★☆ · Effort: Low-Med · Infra: none (CLGeocoder at runtime)**

Today the When & Where section has a *Location* row that punts to Apple Maps. iOS's own event detail (Calendar) **embeds a map**. Add a stock SwiftUI `Map` showing a `Marker` at the venue, with `mapStyle(.standard(...))`; tap to open Maps, long-press/secondary action to present `lookAroundViewer(isPresented:scene:)` for a street-level look at the venue.
- We store `mapQuery` (string) but no coordinates — geocode once with `CLGeocoder.geocodeAddressString`, cache the result on the model. Online events simply omit the map.

*Why it fits:* this is the single most "Apple event detail" visual upgrade, entirely stock MapKit, and it makes the detail screen feel premium. Pure design wheelhouse — no new target.

### 2.2 Rich `ShareLink` with `SharePreview`
**Standout: ★★☆☆☆ · Effort: Low · Infra: none**

Upgrade the detail `ShareLink(item: shareText)` to share the conference **URL** with `SharePreview(conference.name, image: <logo or rendered tile>)`, so the share sheet shows a rich card instead of a text blob. Uses the gradient placeholder we already render as the fallback image.

### 2.3 Favourites tab badge
**Standout: ★★☆☆☆ · Effort: Trivial · Infra: none**

`.badge(favouritesCount)` on the Favourites `Tab` — a stock numeric badge showing how many are saved. One line, useful, native.

### 2.4 iOS 26 scroll-edge & background polish
**Standout: ★★☆☆☆ · Effort: Low · Infra: none**

- `scrollEdgeEffectStyle(_:for:)` — tune the Liquid Glass fade where list content meets the bars (`.soft` reads nicely over the dark list).
- `backgroundExtensionEffect()` (iOS 26) on the detail hero — let the banner bleed its colour under the safe-area/edges for a richer, more immersive top. Stays within the sanctioned hash colour.

---

## Tier 3 — Niche / off-strategy (note, don't rush)

- **Wallet event pass** (PassKit): add a conference to Wallet as a dated event pass. Cute, niche; arguably calendar already covers it.
- **Foundation Models** (on-device LLM): could power semantic/fuzzy search or "conferences like this." *Off-strategy:* the data philosophy is objective-facts-only, and it adds nondeterminism — skip unless search relevance becomes a real pain.
- **Translation API:** translate descriptions. Low value given blurbs are short and mostly English.

---

## Recommended sequence

1. **Embedded venue map + Look Around (2.1)** — best design ROI, no infra, immediate "premium native" feel. Start here.
2. **Favourites badge (2.3) + rich ShareLink (2.2)** — quick wins in the same pass.
3. **Spotlight + App Intents + Siri (1.3)** — biggest "feels like Apple built it" with no new target; sets up entities reused by widgets.
4. **Widgets / countdown (1.1)** — the feature that makes the app *live on the phone*. Requires the App Group + widget extension; do it once and 1.2/1.4 become cheap.
5. **Live Activity (1.2)** and **Control (1.4)** — layer on after the widget extension exists.

## The one signature

If you pick a single thing to define the app: **the "Next conference" countdown widget + Live Activity (1.1 + 1.2)** — a date-sorted conference app whose answer to "what's next and how soon" lives on your Home Screen, Lock Screen, and Dynamic Island is genuinely distinctive and unmistakably iOS. The embedded venue map (2.1) is the in-app companion signature.

## ADR-0003 check

All Tier 1–2 items are stock Apple API: WidgetKit, ActivityKit, App Intents, Core Spotlight, MapKit, ShareLink, system `.badge`. No custom design tokens, no custom `.glassEffect()` on our own views (system applies glass to widgets/Dynamic Island/tabs automatically), no onboarding. The widget/Live Activity work is *new surface area*, not a restyle — scope it as features, not a design tweak.
