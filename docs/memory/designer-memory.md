# Designer Agent Memory

## Purpose
Track design decisions, color palette, typography, and feedback received.

## Last Updated
2026-04-04 (run 49)
2026-04-04 (run 48)
2026-04-04 (run 47)
2026-04-04 (run 46)

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
Rules established 2026-04-04, revised 2026-04-04 run 2 per CEO feedback — must apply to every screen:
- NO border-radius anywhere (no rounded corners)
- NO gradients
- NO soft shadows — only hard drop shadows (offset X/Y, no blur)
- NO emojis — use Material Icons (Google Fonts CDN) for all icons
- Borders: 2px solid #000 (revised from 3px — "less bold but still brutalism")
- Card shadows: 2px 2px 0 #000 (revised from 4px — same reason)
- App bar shadow: border-bottom 2px solid #000 + box-shadow 0 2px 0 #000
- Section headers: left border 3px solid #1E50FF + 8px padding-left, 11px font, 700 weight (not 900), uppercase, #555 color
- Status bar: 44px, primary blue background; icons use Material Icons (signal_cellular_alt, wifi, battery_full)
- App bar: 56px, primary blue background; title 18px, 700 weight, uppercase
- Bottom nav: 60px, white background, 2px top border, 2px vertical dividers between tabs
- Active nav tab: filled #1E50FF background, white icon + label
- FAB: blue fill, 2px black border, 2px 2px 0 #000 shadow; use Material Icons "add" icon
- Font weight: 700 for headings (revised from 900), 500-600 for body/meta

## Component Decisions
- 2026-04-04: Used 3-tab bottom navigation as persistent shell — tabs: Home, Campaigns, Profile
- 2026-04-04: Active tab uses solid blue fill (not underline indicator) — more brutalist
- 2026-04-04 run 2: Progress bars: 10px tall, 2px black border, blue fill for active, black fill for completed; labeled with "Day X of Y" + percentage
- 2026-04-04 run 2: Day-tick strip below progress bar — shows history at a glance (blue=completed, white=missed, light grey=future)
- 2026-04-04: Status badges: "Active" = blue fill + white text; "Done"/"Completed" = white fill + black border
- 2026-04-04 run 2: Activity feed uses Material Icons check_circle (blue) for done, radio_button_unchecked (grey) for missed — no dots/emojis
- 2026-04-04: Stats grid: 3-column flex row, each cell a bordered card with Material Icon + blue value + uppercase label
- 2026-04-04: FAB positioned bottom-right, above bottom nav (bottom: 76px to clear nav)
- 2026-04-04 run 2: Profile tab: avatar = square with initials (no photo/emoji), settings list with icon + label + chevron rows
- 2026-04-04 run 5: Campaign list screen (MTB-9) — two sections (Active / Completed) with section header showing count; campaign cards with name, goal, Day X of Y label, percentage, progress bar, day-tick strip; empty state: dashed border card with message pointing to FAB
- 2026-04-04 run 5: Campaign creation (MTB-8) — full-screen pushed view (not modal); two-state design on one screen (error state + clean state separated by dashed annotation divider); error banner (red) at top of form; name field has red border + inline error on validation failure; goal uses number input + attached grey "DAYS" unit pill; Cancel (white) + Create (blue) buttons side by side
- 2026-04-04 run 33: Daily check-in (MTB-11) — two-state card on home screen: before (gold today-tick + blue CHECK IN button with add_task icon) / after (tick turns blue + bordered CHECKED IN row + black toast confirmation bar with streak count); dashed annotation divider separates states
- 2026-04-04 run 33: Campaign detail (MTB-12) — pushed screen (back arrow, no bottom nav); 3-stat row (streak, completed, goal) with same stat-card pattern; progress bar + percentage; 7-column calendar grid (done=blue fill, missed=grey, future=light grey, today=2px black border); scrollable recent activity list with check_circle/radio_button_unchecked icons
- 2026-04-04 run 33: Edit & delete (MTB-13) — same pushed form layout as MTB-8; pre-filled inputs; Cancel+Save button pair; dashed divider before danger zone; delete button is red border/shadow (never blue); confirmation dialog: red header + warning icon + "Keep It" / "Delete" footer
- 2026-04-04 run 33: Campaign completion (MTB-14) — full-screen blue takeover, no app bar/bottom nav; brutalist confetti = rows of 14px squares with varying fill/opacity; 100×100 white trophy block (emoji_events icon, 3px border, 4px shadow); "GOAL ACHIEVED!" headline; semi-transparent stat blocks; white "Back to Campaigns" CTA + "View Full History" text link
- 2026-04-04 run 33: Home with live data (MTB-15) — green "Live Data" dot + label in app bar top-right; "Today summary" card at top (3-stat mini grid: Active, Done Today, Best Streak); per-card dual action row: CHECK IN button + detail chevron; "Done Today" badge (green fill, black border) replaces "Active" badge on checked-in campaigns
- 2026-04-04 run 45: Streak indicator (MTB-16) — top-right badge on campaign cards; two states: active streak = blue fill + white text + local_fire_department icon; broken streak (missed a day) = white fill + black border + grey icon; badge shows "N DAY STREAK"; resets to 1 after a miss (not 0)
- 2026-04-04 run 47: Stats dashboard (MTB-18) — pushed screen (back arrow, no bottom nav); 3 stat cards stacked vertically (Total Campaigns=bar_chart, Longest Streak=local_fire_department, Completion Rate=percent); each card: blue icon block (48x48) + large blue value + uppercase label + grey description; Completion Rate card includes inline progress bar; "Campaign Breakdown" section: Completed/Active/Abandoned rows with proportional bars + counts; entry point is Profile tab → Stats row
- 2026-04-04 run 48: Campaign archive (MTB-19) — pushed screen (back arrow, no bottom nav); summary banner at top (trophy icon + completed count in blue); archive cards: name + COMPLETED black badge, day-tick strip (black=done, white=missed), 3-cell meta row (Goal Days / Completed / Best Streak with blue icons), date range + "View Details →" chevron linking to campaign detail (MTB-12)

## Feedback Received
- 2026-04-04: CEO on MTB-6 v1: "I want the design to be less bold, but still brutalism. Remove the emojis and use font icons. The campaign list should have a better way to show the progress (with UI elements). Also, give me the designs of the two other tabs too."
  → Action: Reduced border/shadow weight (3px→2px), switched all emojis to Material Icons, added progress bar + day-tick strip + percentage label to campaign cards, added Campaigns and Profile tab designs.

## Mockups Created
| Date | Issue | Screen | Status |
|------|-------|--------|--------|
| 2026-04-04 | MTB-6 v1 | App shell — Home tab (active), bottom nav with Campaigns + Profile tabs | Sent back for revision by CEO |
| 2026-04-04 run 2 | MTB-6 v2 | All 3 tabs revised: Home (less bold, font icons), Campaigns (progress bar + day-ticks), Profile (avatar, stats, settings) | Awaiting Design Approval |
| 2026-04-04 | MTB-5 | Campaign list screen with FAB | Archived issue — mockup created for reference, no Linear comment posted |
| 2026-04-04 run 3 | (none) | No active "In Design" issues found — MTB-5 archived, MTB-6 already in Awaiting Design Approval | Idle run |
| 2026-04-04 run 4 | (none) | No active "In Design" issues found — same state as run 3 | Idle run |
| 2026-04-04 run 5 | MTB-9 | Campaign list screen — Active + Completed sections, progress bars, day-ticks, FAB | Awaiting Design Approval |
| 2026-04-04 run 5 | MTB-8 | Campaign creation flow — full-screen form with error + clean state shown | Awaiting Design Approval |
| 2026-04-04 run 5 | MTB-7 | Data persistence — backend only, no mockup needed, noted in comment | Awaiting Design Approval |
| 2026-04-04 run 6 | (none) | No active "In Design" issues found — only MTB-5 (archived) visible, already handled | Idle run |
| 2026-04-04 run 7 | (none) | No active "In Design" issues found — only MTB-5 (archived) visible, already handled | Idle run |
| 2026-04-04 run 8 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 9 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 10 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 11 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 12 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 13 | (none) | No active "In Design" issues found — only MTB-5 (archived) visible, already handled | Idle run |
| 2026-04-04 run 14 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 15 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 16 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 17 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 18 | (none) | No active "In Design" issues found — only MTB-5 (archived) visible, already handled | Idle run |
| 2026-04-04 run 19 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 20 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 21 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 22 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 23 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 24 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 25 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 26 | (none) | No active "In Design" issues found — only MTB-5 (archived) visible, already handled | Idle run |
| 2026-04-04 run 27 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 28 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 29 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 30 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 31 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 32 | (none) | No active "In Design" issues found — only MTB-5 (archived) visible, already handled | Idle run |
| 2026-04-04 run 33 | MTB-11 | Daily check-in flow — two-state card (before/after), gold today-tick, toast confirmation | Awaiting Design Approval |
| 2026-04-04 run 33 | MTB-12 | Campaign detail screen — stat row, progress bar, 7-col calendar grid, activity list | Awaiting Design Approval |
| 2026-04-04 run 33 | MTB-13 | Edit & delete campaign — pre-filled form, red delete button, confirmation dialog overlay | Awaiting Design Approval |
| 2026-04-04 run 33 | MTB-14 | Campaign completion flow — full-screen blue celebration, brutalist confetti, trophy block | Awaiting Design Approval |
| 2026-04-04 run 33 | MTB-15 | Home with live data — Live Data indicator, Today summary card, dual-action campaign cards | Awaiting Design Approval |
| 2026-04-04 run 34 | MTB-10 | MVP umbrella issue — no new mockup; linked all 5 child designs (MTB-11–15) in comment | Awaiting Design Approval |
| 2026-04-04 run 35 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 36 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 37 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 38 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 39 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 40 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 41 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 42 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 43 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 44 | (none) | No active "In Design" issues found | Idle run |
| 2026-04-04 run 45 | MTB-16 | Streak indicators on campaign cards — two-state badge (active=blue, broken=white), fire icon, top-right of card | Awaiting Design Approval |

| 2026-04-04 run 46 | MTB-17 | Activity history feed with real data — date-grouped feed on Home tab, check_circle/radio icons, Done/Missed/Pending badges, real-time sync notice bar | Awaiting Design Approval |
| 2026-04-04 run 47 | MTB-18 | Stats dashboard — 3 stat cards (Total Campaigns, Longest Streak, Completion Rate), breakdown section, pushed screen from Profile | Awaiting Design Approval |
| 2026-04-04 run 48 | MTB-19 | Campaign archive — pushed screen; summary banner (trophy + total count); archive cards with COMPLETED badge, progress bar, day-tick strip, 3-cell meta row (Goal/Completed/Best Streak), date range + View Details link | Awaiting Design Approval |
| 2026-04-04 run 49 | (none) | No active "In Design" issues found — only archived MTB-5 visible, already handled | Idle run |
