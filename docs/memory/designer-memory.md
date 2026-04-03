# Designer Agent Memory

## Purpose
Track design decisions, color palette, typography, and feedback received.

## Last Updated
2026-04-04

## Color Palette
Established on first mockup run (2026-04-04). All screens must use these values exactly.
- Primary: #1E50FF (blue accent — buttons, active nav, progress bars, badges)
- Background: #FAFAFA (off-white — screen backgrounds)
- Surface: #FFFFFF (white — cards, nav bar)
- Text Primary: #000000
- Text Secondary: #555555
- Borders: #000000 (always solid, always 3px min)
- Shadows: 3px 3px 0 #000 (standard), 4px 4px 0 #000 (cards)

## Typography
- Font family: -apple-system, 'SF Pro Display', sans-serif
- Heading size: 26px, weight 900, letter-spacing -1px
- App bar title: 22px, weight 900, uppercase
- Section label: 13px, weight 900, uppercase, letter-spacing 1px
- Body / card name: 13–16px, weight 800–900
- Meta / caption: 11–12px, weight 600–700, uppercase
- Badge / tag: 9–10px, weight 900, uppercase

## Design System: Light Brutalism
Rules established 2026-04-04 — must apply to every screen:
- NO border-radius anywhere (no rounded corners)
- NO gradients
- NO soft shadows — only hard drop shadows (offset X/Y, no blur)
- Borders: minimum 3px solid #000
- Card shadows: 4px 4px 0 #000
- App bar shadow: border-bottom 3px solid #000 + box-shadow 0 3px 0 #000
- Section headers: left border 4px solid #1E50FF + 8px padding-left
- Status bar: 44px, primary blue background
- App bar: 56px, primary blue background
- Bottom nav: 60px, white background, 3px top border, 3px vertical dividers between tabs
- Active nav tab: filled #1E50FF background, white label
- FAB: blue fill, 3px black border, 4px 4px 0 #000 shadow

## Component Decisions
- 2026-04-04: Used 3-tab bottom navigation as persistent shell — tabs: Home, Campaigns, Profile
- 2026-04-04: Active tab uses solid blue fill (not underline indicator) — more brutalist
- 2026-04-04: Progress bars: 12px tall, 2px black border, blue fill for active, solid black fill for completed
- 2026-04-04: Status badges: "Active" = blue fill + white text; "Done"/"Completed" = white fill + black border
- 2026-04-04: Activity feed dots: blue for completed check-in, white for missed check-in
- 2026-04-04: Stats grid: 3-column flex row, each cell a bordered card with blue value + uppercase label
- 2026-04-04: FAB positioned bottom-right, above bottom nav (bottom: 76px to clear nav)

## Feedback Received
(none yet — awaiting CEO review)

## Mockups Created
| Date | Issue | Screen | Status |
|------|-------|--------|--------|
| 2026-04-04 | MTB-6 | App shell — Home tab (active), bottom nav with Campaigns + Profile tabs | Awaiting Design Approval |
| 2026-04-04 | MTB-5 | Campaign list screen with FAB | Archived issue — mockup created for reference, no Linear comment posted |
