# Designer Agent Memory

## Purpose
Track design decisions, color palette, typography, and feedback received.

## Last Updated
2026-04-05 (run 60)
2026-04-05 (run 59)
2026-04-04 (run 58)
2026-04-04 (run 57)
2026-04-04 (run 56)
2026-04-04 (run 55)
2026-04-04 (run 54)
2026-04-04 (run 53)
2026-04-04 (run 52)
2026-04-04 (run 51)
2026-04-04 (run 50)
2026-04-04 (run 49)
2026-04-04 (run 48)
2026-04-04 (run 47)
2026-04-04 (run 46)

## Color Palette
Established on first mockup run (2026-04-04). **REFRESHED 2026-04-04 run 52 (MTB-23)** — muted earthy brutalism per CEO directive MTB-20. All screens must use these values exactly.
- Primary: #4C6EAD (muted dusty slate blue — replaces saturated #1E50FF)
- Background: #F7F3EF (warm off-white — replaces cold #FAFAFA)
- Surface: #FFFDF9 (warm card white — replaces pure #FFFFFF)
- Text Primary: #1A1A1A (warm near-black — replaces pure #000000)
- Text Secondary: #6B6B6B (warm mid-grey — replaces #555555)
- Borders: #2C2C2C (dark charcoal — replaces pure #000000)
- Shadows: 2px 2px 0 #2C2C2C (warm dark, not black)
- Tick Done: #4C6EAD (primary blue fill)
- Tick Missed: #FFFDF9 (warm white, with border)
- Tick Future: #E8E2DA (warm light grey)
- Warm Accent (optional secondary): #B5735A (terracotta)

**Legacy (before MTB-23, for reference only):**
- Old primary: #1E50FF | Old bg: #FAFAFA | Old surface: #FFFFFF | Old border/shadow: #000000

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
- Borders: 2px solid #2C2C2C (warm charcoal — updated from #000 per MTB-23 palette refresh)
- Card shadows: 2px 2px 0 #2C2C2C (updated from #000 per MTB-23)
- App bar shadow: border-bottom 2px solid #2C2C2C + box-shadow 0 2px 0 #2C2C2C
- Section headers: left border 3px solid #4C6EAD + 8px padding-left, 11px font, 700 weight (not 900), uppercase, #6B6B6B color
- Status bar: 44px, primary blue background; icons use Material Icons (signal_cellular_alt, wifi, battery_full)
- App bar: 56px, primary blue background; title 18px, 700 weight, uppercase
- Bottom nav: 60px, warm white (#FFFDF9) background, 2px top border, 2px vertical dividers between tabs
- Active nav tab: filled #4C6EAD background, white icon + label
- FAB: #4C6EAD fill, 2px #2C2C2C border, 2px 2px 0 #2C2C2C shadow; use Material Icons "add" icon
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
- 2026-04-04 run 33: Campaign completion (MTB-14) — full-screen blue takeover, no app bar/bottom nav; brutalist confetti = rows of 14px squares with varying fill/opacity; 100x100 white trophy block (emoji_events icon, 3px border, 4px shadow); "GOAL ACHIEVED!" headline; semi-transparent stat blocks; white "Back to Campaigns" CTA + "View Full History" text link
- 2026-04-04 run 33: Home with live data (MTB-15) — green "Live Data" dot + label in app bar top-right; "Today summary" card at top (3-stat mini grid: Active, Done Today, Best Streak); per-card dual action row: CHECK IN button + detail chevron; "Done Today" badge (green fill, black border) replaces "Active" badge on checked-in campaigns
- 2026-04-04 run 45: Streak indicator (MTB-16) — top-right badge on campaign cards; two states: active streak = blue fill + white text + local_fire_department icon; broken streak (missed a day) = white fill + black border + grey icon; badge shows "N DAY STREAK"; resets to 1 after a miss (not 0)
- 2026-04-04 run 47: Stats dashboard (MTB-18) — pushed screen (back arrow, no bottom nav); 3 stat cards stacked vertically (Total Campaigns=bar_chart, Longest Streak=local_fire_department, Completion Rate=percent); each card: blue icon block (48x48) + large blue value + uppercase label + grey description; Completion Rate card includes inline progress bar; "Campaign Breakdown" section: Completed/Active/Abandoned rows with proportional bars + counts; entry point is Profile tab -> Stats row
- 2026-04-04 run 48: Campaign archive (MTB-19) — pushed screen (back arrow, no bottom nav); summary banner at top (trophy icon + completed count in blue); archive cards: name + COMPLETED black badge, day-tick strip (black=done, white=missed), 3-cell meta row (Goal Days / Completed / Best Streak with blue icons), date range + "View Details" chevron linking to campaign detail (MTB-12)
- 2026-04-04 run 50: Onboarding flow (MTB-21) — 3-screen composite (fullPage screenshot); dashed annotation dividers between screens; Screen 1: blue hero block (icon + app name + tagline), bold headline, GET STARTED CTA + SKIP text link; Screen 2: two icon-feature rows (blue icon box 56x56 + title + desc), example campaign card, page progress dots; Screen 3: pre-filled form with active/focused field (blue border), goal days + DAYS unit pill, Create & Start CTA, black toast note; progress dots = brutalist squares (not circles) tracking flow position
- 2026-04-04 run 51: Notification reminders (MTB-22) — composite showing two states (reminder OFF / ON) in one full-page scroll; reminder section sits below progress inside campaign detail (pushed screen); toggle row: bell icon + label + caption + brutalist toggle (grey=off, blue=on); time picker row only active when ON (alarm icon + "Remind me at" + time value + chevron); info bar (blue fill, flush at card bottom) confirms active reminder; notification preview at bottom of page: blue app icon square + app name + time + title (menu_book icon) + body naming campaign + CHECK IN / DISMISS chips
- 2026-04-04 run 52: Palette refresh (MTB-23) — style guide composite with full Home screen using new muted palette; 8-swatch style guide panel below annotation divider; before/after comparison badge showing #1E50FF -> #4C6EAD transition
- 2026-04-04 run 53: Shadow/border refinement (MTB-24) — before/after comparison panel + Home screen; content surfaces use 1.5px border (#5A5A5A) + rgba(44,44,44,0.45) shadow; structural chrome (app bar border, nav top-border) stays at 2px #2C2C2C; shadow offset unchanged at 2px 2px to preserve brutalist geometry
- 2026-04-04 run 54: Visual delight (MTB-25) — celebration banner pattern: blue fill + check_circle icon + sub-copy; confetti = 3 rows of 15 rotated 8px squares in palette colors; streak badge = bold 2px #2C2C2C border (heavier than content surfaces to signal importance); empty states use 2px dashed #5A5A5A box (not solid) to feel lighter/inviting; annotation dividers separate panels; micro-interaction spec table uses 32x32 blue icon box + name + description rows
- 2026-04-04 run 57: Custom colors & icons (MTB-26) — campaign color picker: 8 swatches (2×4 grid, 44×44px) with selected state = white checkmark icon + 2px #2C2C2C border; icon picker: 8-cell grid (44×44px) with selected = #4C6EAD fill + white icon; campaign cards: 4px left accent stripe in campaign color + 40×40 icon box in campaign color + progress bar fill in campaign color + tick strip done-ticks in campaign color; streak badge stays #4C6EAD blue always (visual hierarchy); icon "local_fire_department" not available — use "whatshot" instead
- 2026-04-05 run 60: Flexible goal types (MTB-29) — 4-cell segmented control for Days/Hours/Sessions/Custom; Custom state reveals Metric Name text field; unit pill mirrors metric name; campaign cards gain a goal-type chip (small icon + label, grey fill); check-in button label adapts to goal type ("Log Session", "Log Hours", "Log Pages")
- 2026-04-04 run 58: Progress sharing (MTB-27) — entry point is a full-width "Share My Progress" button (blue, 2px #2C2C2C border/shadow) on campaign detail screen, between progress card and recent activity; share preview screen shows shareable card (campaign name uppercase 22px/900w, giant % number 54px, count block "22/30 Days Complete", 14px progress bar, tick strip, streak badge, MTBox branding strip with terracotta "Campaign Tracker" tag); two action buttons below: "Save to Gallery" (white) + "Share Now" (blue); share-via section: 4-app icon grid + filename copy row
- 2026-04-05 run 59: Refined onboarding (MTB-28) — "SAMPLE DATA" pill badge (terracotta, 10px 700w uppercase) in app bar top-right signals demo mode; welcome info card uses blue left-border 3px accent; "Dismiss Samples →" is a terracotta text-link (not a button) to keep it unobtrusive; reduced to 2 sample campaigns per CEO's "3-5 feels like many" comment; post-dismissal empty state uses dashed 1.5px border box pattern (consistent with MTB-25 empty state convention)

## Shadow & Border Refinement Spec (MTB-24)
Introduced 2026-04-04 run 53. Two-tier system: structural chrome stays bold, content surfaces softened.
- **Content surfaces** (cards, buttons, badges, ticks, progress bars, stat cells):
  - Border: `1.5px solid #5A5A5A`
  - Shadow: `2px 2px 0 rgba(44,44,44,0.45)`
- **Structural chrome** (app bar bottom-border, bottom-nav top-border):
  - Border: unchanged `2px solid #2C2C2C`
  - Bottom-nav vertical dividers: `1.5px solid #5A5A5A`
- Shadow offset (2px 2px) intentionally unchanged — only opacity drops

## Feedback Received
- 2026-04-04: CEO on MTB-6 v1: "I want the design to be less bold, but still brutalism. Remove the emojis and use font icons. The campaign list should have a better way to show the progress (with UI elements). Also, give me the designs of the two other tabs too."
  -> Action: Reduced border/shadow weight (3px->2px), switched all emojis to Material Icons, added progress bar + day-tick strip + percentage label to campaign cards, added Campaigns and Profile tab designs.

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
| 2026-04-04 runs 6-32 | (none) | No active "In Design" issues found (multiple idle runs) | Idle runs |
| 2026-04-04 run 33 | MTB-11 | Daily check-in flow — two-state card (before/after), gold today-tick, toast confirmation | Awaiting Design Approval |
| 2026-04-04 run 33 | MTB-12 | Campaign detail screen — stat row, progress bar, 7-col calendar grid, activity list | Awaiting Design Approval |
| 2026-04-04 run 33 | MTB-13 | Edit & delete campaign — pre-filled form, red delete button, confirmation dialog overlay | Awaiting Design Approval |
| 2026-04-04 run 33 | MTB-14 | Campaign completion flow — full-screen blue celebration, brutalist confetti, trophy block | Awaiting Design Approval |
| 2026-04-04 run 33 | MTB-15 | Home with live data — Live Data indicator, Today summary card, dual-action campaign cards | Awaiting Design Approval |
| 2026-04-04 run 34 | MTB-10 | MVP umbrella issue — no new mockup; linked all 5 child designs (MTB-11–15) in comment | Awaiting Design Approval |
| 2026-04-04 runs 35-44 | (none) | No active "In Design" issues found (multiple idle runs) | Idle runs |
| 2026-04-04 run 45 | MTB-16 | Streak indicators on campaign cards — two-state badge (active=blue, broken=white), fire icon, top-right of card | Awaiting Design Approval |
| 2026-04-04 run 46 | MTB-17 | Activity history feed with real data — date-grouped feed on Home tab, check_circle/radio icons, Done/Missed/Pending badges, real-time sync notice bar | Awaiting Design Approval |
| 2026-04-04 run 47 | MTB-18 | Stats dashboard — 3 stat cards (Total Campaigns, Longest Streak, Completion Rate), breakdown section, pushed screen from Profile | Awaiting Design Approval |
| 2026-04-04 run 48 | MTB-19 | Campaign archive — pushed screen; summary banner (trophy + total count); archive cards with COMPLETED badge, progress bar, day-tick strip, 3-cell meta row (Goal/Completed/Best Streak), date range + View Details link | Awaiting Design Approval |
| 2026-04-04 run 49 | (none) | No active "In Design" issues found — only archived MTB-5 visible, already handled | Idle run |
| 2026-04-04 run 50 | MTB-21 | Onboarding flow — 3-screen composite (Welcome, How It Works, Create First Campaign) | Awaiting Design Approval |
| 2026-04-04 run 50 | MTB-5 | Archived issue — updated mockup to current design system but no comment posted (issue is archived in Linear, cannot comment) | Skipped |
| 2026-04-04 run 51 | MTB-22 | Notification reminders — two-state composite (toggle OFF/ON), time picker row, info confirmation bar, notification preview card | Awaiting Design Approval |
| 2026-04-04 run 52 | MTB-23 | Palette refresh style guide — Home screen with new muted palette + 8-swatch style guide + before/after comparison | Awaiting Design Approval |
| 2026-04-04 run 53 | MTB-24 | Shadow & border refinement — before/after comparison panel + Home screen with 1.5px/rgba values; criteria checklist | Awaiting Design Approval |
| 2026-04-04 run 54 | MTB-25 | Visual delight polish — 4-panel composite: check-in celebration (banner+confetti+streak pulse), empty campaigns screen (dashed box+CTA), empty activity feed (history icon+text link), micro-interaction spec table (5 annotated rows) | Awaiting Design Approval |
| 2026-04-04 run 55 | (none) | No active "In Design" issues found — only archived MTB-5 visible, already handled in run 50 | Idle run |
| 2026-04-04 run 56 | MTB-5 | Archived/trashed issue — refreshed mockup to latest design system (MTB-24/25 refinements: 1.5px borders, rgba shadows, dashed empty state); no comment posted (issue still trashed in Linear, commentCreate returns 404) | Skipped |
| 2026-04-04 run 57 | MTB-5 | Issue appeared in "In Design" in Linear (possibly unarchived) but commentCreate still returns "Entity not found" — skipped again; mockup already current | Skipped |
| 2026-04-04 run 57 | MTB-26 | Custom campaign colors and icons — 2-panel composite: Edit Campaign form with color/icon pickers + Campaigns home with 3 colorized cards | Awaiting Design Approval |
| 2026-04-04 run 58 | MTB-5 | Trashed issue — commentCreate still returns "Entity not found"; skipped again | Skipped |
| 2026-04-04 run 58 | MTB-27 | Progress sharing — two-state composite: Campaign Detail with "Share My Progress" CTA + Share Preview screen (shareable card, Save to Gallery / Share Now buttons, share-via app grid) | Awaiting Design Approval |
| 2026-04-05 run 59 | MTB-28 | Refined onboarding with lightweight mock data — 3-panel composite: (1) Home with 2 sample campaigns + "SAMPLE DATA" app-bar pill + welcome info card + "Dismiss Samples" text-link; (2) dismiss confirmation dialog over dimmed home; (3) post-dismissal empty state with flag icon + "Create First Campaign" CTA. Reduced from PM's 3–5 to just 2 campaigns per CEO feedback. | Awaiting Design Approval |
| 2026-04-05 run 60 | MTB-29 | Flexible goal types — 3-panel composite: (1) Create Campaign form with SESSIONS selected in 4-cell segmented control (Days/Hours/Sessions/Custom); (2) CUSTOM selected showing extra Metric Name text input + editable unit pill; (3) Campaign list with 3 cards showing different goal types (Sessions, Custom Pages, Hours) with per-type chip badge and adapted check-in button labels | Awaiting Design Approval |
