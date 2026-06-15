# Wakeful

A beautifully simple **keep-awake** app that lives in your Mac's menu bar. One
click stops your Mac from going to sleep — perfect for downloads, presentations,
long renders, or just reading without the screen dimming.

**Privacy first** — Wakeful uses Apple's power-management API only. No
Accessibility, no keyboard monitoring, nothing leaves your Mac.

## Features
- One-click keep-awake from the menu bar
- Choose system-only or keep the display on too
- **Wakeful Pro** (one-time purchase): timed sessions (15m–2h with auto-sleep),
  launch at login, and all themes

## Build
The Xcode project is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
brew install xcodegen
xcodegen generate
open Wakeful.xcodeproj
```

CI/CD: built & signed for the Mac App Store on Codemagic (`codemagic.yaml`).
Monetization via [RevenueCat](https://www.revenuecat.com) (entitlement `pro`).

- Bundle ID: `app.wakeful.Wakeful`
- Minimum macOS: 13.0
