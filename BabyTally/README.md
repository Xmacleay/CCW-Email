# BabyTally

A baby feed/diaper/sleep/growth tracker, positioned as the one-time-purchase
alternative to subscription trackers (Huckleberry, Baby Tracker, etc).

**Pitch:** "$2.99 once. No account, no subscription, no cloud, ever." Widget
included free (most subscription competitors paywall it).

## What's built

- SwiftUI app, SwiftData local storage only (no networking code anywhere in
  the project — nothing to remove before submission, nothing to leak).
- Home tab: time-since-last-feed/diaper, one-tap sleep start/stop, quick-log
  sheets for feed/diaper/growth.
- History tab: unified timeline grouped by day, swipe to delete.
- Stats tab: 7-day charts for feeds, diapers, sleep hours (Swift Charts).
- Settings: multi-child support (twins), CSV export for pediatrician visits,
  no-tracking messaging.
- Home Screen + Lock Screen widget (`BabyTallyWidget`) showing time since
  last feed/diaper, reading the same on-device store via an App Group.
- Unit tests for the model logic and CSV export (`BabyTallyTests`).

## What's NOT built yet

- App icon artwork (placeholder `Contents.json` only — drop real PNGs into
  `BabyTally/Assets.xcassets/AppIcon.appiconset` before archiving).
- Screenshots / App Store Connect listing copy beyond the blurb below.
- Onboarding polish, haptics, accessibility audit (Dynamic Type should mostly
  work for free via SwiftUI, but VoiceOver labels haven't been added to the
  quick-log buttons).
- Any of this has been compiled. This sandbox is Linux with no Xcode/Swift
  toolchain, so the code is written from API knowledge but **not yet
  build-verified**. Treat the first `xcodegen generate` + build on your Mac
  as the real first compile pass — expect to fix a handful of small issues
  (most likely: SwiftData `#Predicate`/relationship edge cases, or Charts API
  signatures if your Xcode version differs).

## Setup (on a Mac, with Xcode 15+ installed)

```bash
brew install xcodegen
cd BabyTally
xcodegen generate
open BabyTally.xcodeproj
```

Then in Xcode:

1. Select the `BabyTally` and `BabyTallyWidgetExtension` targets → Signing &
   Capabilities → set your Team. Bundle IDs are pre-set to
   `com.babytally.app` / `com.babytally.app.widget` — change the prefix in
   `project.yml` (`bundleIdPrefix`) and the two `PRODUCT_BUNDLE_IDENTIFIER`
   values if you want your own reverse-DNS domain.
2. Both targets reference App Group `group.com.babytally.shared` — this
   needs to exist under your developer account (Xcode will offer to create
   it automatically the first time you build, or add it manually in the
   Apple Developer portal under Identifiers → App Groups).
3. Build & run on a simulator or device (`Cmd+R`).
4. Add a real app icon (1024×1024 PNG, no alpha) in
   `Assets.xcassets/AppIcon.appiconset`.

## App Store listing draft

- **Name:** BabyTally
- **Subtitle:** Feed, diaper & sleep tracker. No subscription.
- **Price:** $2.99, one-time
- **Description opener:** "Every other baby tracker wants $5-10 a month
  forever. BabyTally is $2.99, once. Track feeds, diapers, sleep, and growth
  — all stored privately on your phone, with a free Lock Screen widget so
  you can see at a glance when you last fed or changed your baby."
- **Keywords angle:** baby tracker, no subscription, newborn log, feeding
  tracker, diaper log, sleep tracker, baby app one time purchase
- **Privacy nutrition label:** "Data Not Collected" — true, since there's no
  networking code in the app at all. This is a real ranking/trust advantage,
  call it out explicitly in the listing.

## Next steps once this builds

1. Real app icon + 3-5 screenshots (iPhone 6.7" + 6.5" sizes required).
2. TestFlight a build to a few actual parents before submitting.
3. App Store Connect: create the app, set price tier, write the listing,
   submit for review (expect ~1-3 days, no special review concerns since
   there's no account/login and no special permissions requested).
