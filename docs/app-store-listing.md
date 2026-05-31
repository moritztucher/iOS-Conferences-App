# App Store Listing — dubdub

Canonical source for App Store Connect metadata. Update here, then copy into App Store Connect.

| Field | Value |
|-------|-------|
| Apple ID | `6774134161` |
| Bundle ID (running build) | `com.moritztucher.dubdub-ios-conference` |
| Primary language | English (U.S.) |
| Version | 1.0.0 |
| Build | 3 |

## Name (30 char max)

```
dubdub - Conferences & Events
```
_29 characters._

## Subtitle (30 char max)

```
The iOS conference calendar
```
_27 characters._

## Promotional Text (170 char max, editable anytime without review)

```
Every upcoming Apple-platform conference, watch party, and community event — in one place, sorted by date. Free, open, and community-curated.
```

## Description

```
dubdub is the iOS developer's conference calendar — every upcoming Apple-platform conference, watch party, and community event, in one place, sorted by date.

Stop digging through blogs, Mastodon threads, and one-off lists. dubdub keeps the whole calendar — the big conferences and the events that orbit them — on your phone, where you'll actually look.

• Browse every upcoming conference, watch party, and meetup, grouped by month
• Filter by kind (Conferences / Watch Parties / Events) and format (in person / online)
• Search by name, location, or tag (swift, wwdc, visionos, community…)
• Favourite the events you're considering — stored locally, no account needed
• Add any event to your calendar with the system editor — you pick the calendar and alerts
• Open the official website in an in-app Safari view
• Tap a location to open it in Apple Maps
• Share any event via the system share sheet

dubdub is free, forever. No ads, no subscriptions, no in-app purchases, no accounts, no tracking. The conference list is open and community-curated — spotted something missing? Suggest it right from the app.

Built for iOS 26 to feel like a natural part of the system.
```

## Keywords (100 char max)

```
conference,swift,ios,wwdc,developer,meetup,visionos,swiftui,apple,event,tech,calendar,watch party
```
_98 characters. No spaces after commas (Apple ignores them); avoid repeating words already in the Name/Subtitle._

## Support URL

```
https://github.com/moritztucher/iOS-Conferences-App
```

## Marketing URL (optional)

```
https://github.com/moritztucher/iOS-Conferences-App
```
_Optional — fine to leave blank until there's a dedicated landing page._

## Copyright

```
2026 Moritz Tucher
```
_Apple convention: `<year> <name/entity>`. Swap in a studio/company name if shipping under one._

## App Review — declarations

| Question | Answer | Rationale |
|----------|--------|-----------|
| Unrestricted Web Access | **YES** | Opens conference/GitHub URLs in `SFSafariViewController`; users can follow links to arbitrary pages. |
| User-Generated Content | NO | List is editorially curated via GitHub PRs; "Suggest a conference" composes an email / pre-filled Issue — nothing posts back into the app. |
| Messaging and Chat | NO | No user-to-user communication. |
| Advertising | NO | No ads, no paid promotion, no IAP. |
| Export compliance — non-exempt encryption | NO | Uses only HTTPS via Apple's OS (URLSession / SFSafariViewController). Exempt. Set in build settings via `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO`. |
