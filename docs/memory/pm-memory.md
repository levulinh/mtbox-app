# PM Agent Memory

## Purpose
Track issues processed, routing decisions made, and patterns noticed across all runs.

## Last Updated
2026-04-05 (run 59)

## Issues Processed
(format: YYYY-MM-DD | issue-id | title | action taken)
2026-04-04 | MTB-5 | Campaign list screen | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | MTB-6 | MVP: App shell with home, campaigns, and profile tabs | Posted acceptance criteria comment, moved Backlog → In Design

## Routing Decisions
(format: YYYY-MM-DD | issue-id | CEO said: "..." | routed to: status | reason)
2026-04-04 | MTB-6 | CEO said: "less bold, still brutalism; remove emojis, use font icons; better progress UI on campaigns; designs for two other tabs" | routed to: In Design | CEO requested changes to first Designer mockup
2026-04-04 | MTB-6 | CEO said: "Good to go!" (after revised Designer mockup with all 3 tabs) | routed to: In Progress | CEO approved revised mockup
2026-04-04 | MTB-7 | Campaign data model & persistence | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | MTB-8 | Campaign creation flow | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | MTB-9 | Campaign list screen | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | MTB-8 | Campaign creation flow | CEO approved Designer mockup ("Good"), moved Awaiting Design Approval → In Progress
2026-04-04 | MTB-7 | Campaign data model & persistence | CEO said "Go" after Designer's no-mockup-needed comment, moved Awaiting Design Approval → In Progress

## Patterns & Learnings
(append observations about team dynamics, delays, recurring issues)
2026-04-04 | First run. One Backlog issue (MTB-5) found with clear enough description to write acceptance criteria directly. No issues in Awaiting Design Approval or Awaiting Decision.
2026-04-04 | Second run. One Backlog issue (MTB-6) — MVP app shell, priority Urgent. Description was detailed (screens, design style, tech notes), so acceptance criteria written directly. No issues in Awaiting Design Approval or Awaiting Decision.
2026-04-04 | Third run. No Backlog issues. MTB-6 was in Awaiting Design Approval — CEO rejected the first Designer mockup (too bold, emojis present, only Home tab shown). Moved back to In Design. No Awaiting Decision issues.
2026-04-04 | Fourth run. No Backlog or Awaiting Decision issues. MTB-6 in Awaiting Design Approval — Designer submitted revised mockup (all 3 tabs, softer brutalism, Material Icons, redesigned progress bar). CEO replied "Good to go!" — approved. Moved MTB-6 to In Progress.
2026-04-04 | Fifth run. No issues in Backlog, Awaiting Design Approval, or Awaiting Decision. MTB-6 is now "In Review" — Programmer completed implementation (PR #1) and QA is reviewing. MTB-5 remains in In Design. Nothing for PM to route this run.
2026-04-04 | Sixth run. No issues in Backlog, Awaiting Design Approval, or Awaiting Decision. MTB-6 still "In Review" — QA has not yet posted a review comment. MTB-5 remains In Design. Nothing to route. Waiting on QA result for MTB-6.
2026-04-04 | Seventh run. No issues in Backlog, Awaiting Design Approval, or Awaiting Decision. MTB-6 is now "Done" — fully completed. MTB-5 remains In Design (archived). Nothing to route this run.
2026-04-04 | Eighth run. No issues in Backlog, Awaiting Design Approval, or Awaiting Decision. All queues empty. Nothing to route this run.
2026-04-04 | Ninth run. Three new Backlog issues: MTB-7 (data persistence), MTB-8 (campaign creation), MTB-9 (campaign list screen). All three had clear enough descriptions for direct acceptance criteria. No issues in Awaiting Design Approval or Awaiting Decision. All three moved to In Design.
2026-04-04 | Tenth run. No Backlog issues. Three issues in Awaiting Design Approval: MTB-7 (Designer said no mockup needed, no CEO reply yet — skipped), MTB-8 (Designer posted mockup, no CEO reply yet — skipped), MTB-9 (CEO replied "Good 👍" — approved, moved to In Progress). No Awaiting Decision issues. Key technical learning: save_issue requires `state` parameter (not `status`, `statusId`, or `stateId`) to update workflow status.
2026-04-04 | Eleventh run. No Backlog or Awaiting Decision issues. MTB-7 in Awaiting Design Approval — still no CEO reply, skipped. MTB-8 in Awaiting Design Approval — CEO replied "Good" after Designer mockup, approved, moved to In Progress. Two issues now In Progress: MTB-8 and MTB-9.
2026-04-04 | Twelfth run. No Backlog or Awaiting Decision issues. MTB-7 still in Awaiting Design Approval — Designer noted no mockup needed (backend-only task), but CEO has not yet replied. Skipped. Nothing to route this run.
2026-04-04 | Thirteenth run. No Backlog or Awaiting Decision issues. MTB-7 still in Awaiting Design Approval — Designer noted no mockup needed (backend-only task), CEO still has not replied. Skipped again. Nothing to route this run.
2026-04-04 | Fourteenth run. No Backlog or Awaiting Decision issues. MTB-7 still in Awaiting Design Approval — Designer noted no mockup needed (backend-only task), CEO still has not replied. Skipped again. Nothing to route this run. MTB-7 has been blocked here for multiple runs waiting on CEO acknowledgement.
2026-04-04 | Fifteenth run. No Backlog or Awaiting Decision issues. MTB-7 still in Awaiting Design Approval — Designer noted no mockup needed (backend-only task), CEO still has not replied (6th run waiting). Skipped again. Nothing to route this run.
2026-04-04 | Sixteenth run. No Backlog or Awaiting Decision issues. MTB-7 still in Awaiting Design Approval — Designer noted no mockup needed (backend-only task), CEO still has not replied (7th run waiting). Skipped again. Nothing to route this run.
2026-04-04 | Seventeenth run. No Backlog or Awaiting Decision issues. MTB-7 still in Awaiting Design Approval — Designer noted no mockup needed (backend-only task), CEO still has not replied (8th run waiting). Skipped again. Nothing to route this run.
2026-04-04 | Eighteenth run. No Backlog or Awaiting Decision issues. MTB-7 still in Awaiting Design Approval — Designer noted no mockup needed (backend-only task), CEO still has not replied (9th run waiting). Skipped again. Nothing to route this run.
2026-04-04 | Nineteenth run. No Backlog or Awaiting Decision issues. MTB-7 still in Awaiting Design Approval — Designer noted no mockup needed (backend-only task), CEO still has not replied (10th run waiting). Skipped again. Nothing to route this run.
2026-04-04 | Twentieth run. No Backlog or Awaiting Decision issues. MTB-7 still in Awaiting Design Approval — Designer noted no mockup needed (backend-only task), CEO still has not replied (11th run waiting). Skipped again. Nothing to route this run.
2026-04-04 | Twenty-first run. No Backlog or Awaiting Decision issues. MTB-7 still in Awaiting Design Approval — Designer noted no mockup needed (backend-only task), CEO still has not replied (12th run waiting). Skipped again. Nothing to route this run.
2026-04-04 | Twenty-second run. No Backlog or Awaiting Decision issues. MTB-7 still in Awaiting Design Approval — Designer noted no mockup needed (backend-only task), CEO still has not replied (13th run waiting). Skipped again. Nothing to route this run.
2026-04-04 | Twenty-third run. No Backlog or Awaiting Decision issues. MTB-7 still in Awaiting Design Approval — Designer noted no mockup needed (backend-only task), CEO still has not replied (14th run waiting). Skipped again. Nothing to route this run.
2026-04-04 | Twenty-fourth run. No Backlog or Awaiting Decision issues. MTB-7 still in Awaiting Design Approval — Designer noted no mockup needed (backend-only task), CEO still has not replied (15th run waiting). Skipped again. Nothing to route this run.
2026-04-04 | Twenty-fifth run. No Backlog or Awaiting Decision issues. MTB-7 still in Awaiting Design Approval — Designer noted no mockup needed (backend-only task), CEO still has not replied (16th run waiting). Skipped again. Nothing to route this run.
2026-04-04 | Twenty-sixth run. No Backlog or Awaiting Decision issues. MTB-7 in Awaiting Design Approval — CEO finally replied "Go" (after 16 runs of waiting), posted after the Designer comment. Approved. Moved MTB-7 to In Progress.
2026-04-04 | Twenty-seventh run. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.
2026-04-04 | Twenty-eighth run. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.
2026-04-04 | Twenty-ninth run. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.
2026-04-04 | Thirtieth run. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.
2026-04-04 | Thirty-first run. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.
2026-04-04 | Thirty-second run. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.
2026-04-04 | Thirty-third run. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.
2026-04-04 | Thirty-fourth run. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.
2026-04-04 | Thirty-fifth run. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.
2026-04-04 | Thirty-sixth run. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.
2026-04-04 | Thirty-seventh run. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.
2026-04-04 | Thirty-eighth run. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.
2026-04-04 | Thirty-ninth run. Six new Backlog issues: MTB-10 (MVP meta-directive in CTO Directives project), MTB-11 (daily check-in), MTB-12 (campaign detail screen), MTB-13 (edit & delete), MTB-14 (campaign completion flow), MTB-15 (home screen live data). All had clear intent, accepted criteria written directly. No Awaiting Design Approval or Awaiting Decision issues. All six moved to In Design.
2026-04-04 | Fortieth run. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.
2026-04-04 | Forty-first run. No Backlog or Awaiting Decision issues. Five issues in Awaiting Design Approval: MTB-11 (daily check-in), MTB-12 (campaign detail screen), MTB-13 (edit & delete), MTB-14 (campaign completion flow), MTB-15 (home screen live data). Designer has posted mockups on all five, but no CEO reply yet on any. All skipped — waiting for CEO review.
2026-04-04 | Forty-second run. No Backlog or Awaiting Decision issues. Five issues in Awaiting Design Approval: MTB-11, MTB-12, MTB-13, MTB-14, MTB-15. Designer mockups present on all five, still no CEO reply on any. All skipped — waiting for CEO review. (2nd run waiting)
2026-04-04 | Forty-third run. No Backlog or Awaiting Decision issues. Six issues in Awaiting Design Approval: MTB-10 (MVP meta, Designer posted summary table of all 5 screens), MTB-11, MTB-12, MTB-13, MTB-14, MTB-15. Designer mockups present on all six, no CEO reply on any. All skipped — waiting for CEO review. (3rd run waiting for MTB-11–15; 1st for MTB-10's Designer summary)
2026-04-04 | Forty-fourth run. No Backlog or Awaiting Decision issues. Six issues still in Awaiting Design Approval: MTB-10, MTB-11, MTB-12, MTB-13, MTB-14, MTB-15. Designer mockups present on all six, no CEO reply on any. All skipped — waiting for CEO review. (4th run waiting for MTB-11–15; 2nd for MTB-10)
2026-04-04 | Forty-fifth run. No Backlog or Awaiting Decision issues. Six issues still in Awaiting Design Approval: MTB-10, MTB-11, MTB-12, MTB-13, MTB-14, MTB-15. Designer mockups present on all six, no CEO reply on any. All skipped — waiting for CEO review. (5th run waiting for MTB-11–15; 3rd for MTB-10)
2026-04-04 | MTB-10 | Finish the MVP for Campaign tracker app | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | MTB-11 | Daily check-in flow | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | MTB-12 | Campaign detail screen | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | MTB-13 | Edit & delete campaign | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | MTB-14 | Campaign completion flow | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | MTB-15 | Home screen with live data | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | Forty-sixth run. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.
2026-04-04 | Forty-seventh run. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.
2026-04-04 | MTB-16 | Streak indicators on campaign cards | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | MTB-17 | Activity history feed with real data | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | MTB-18 | Stats dashboard (total campaigns, longest streak, completion rate) | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | Forty-eighth run. Three new Backlog issues: MTB-16 (streak indicators), MTB-17 (activity history), MTB-18 (stats dashboard). All Phase 2 engagement features with clear intent. Acceptance criteria written and all moved to In Design. No Awaiting Design Approval or Awaiting Decision issues.
2026-04-04 | MTB-19 | Campaign archive (view completed campaigns) | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | Forty-ninth run. One new Backlog issue: MTB-19 (campaign archive). Phase 2 engagement feature with clear intent. Acceptance criteria written and moved to In Design. No Awaiting Design Approval or Awaiting Decision issues.
2026-04-04 | Fiftieth run. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.
2026-04-04 | MTB-21 | Onboarding flow for new users | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | MTB-22 | Local push notifications / daily reminders | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | MTB-23 | UI color palette refresh (softer brutalism) | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | MTB-24 | Shadow and border style refinement | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | MTB-25 | Visual delight polish (micro-interactions, empty states) | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | MTB-26 | Custom campaign colors and icons | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | MTB-27 | Progress sharing (export screenshot) | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-04 | Fifty-second run. Two new Backlog issues: MTB-26 (custom colors/icons), MTB-27 (progress sharing). Both Phase 3 Polish features with clear intent. Acceptance criteria written directly for both. All moved to In Design. No Awaiting Design Approval or Awaiting Decision issues.
2026-04-04 | Fifty-first run. Five new Backlog issues (Phase 3 Polish): MTB-21 (onboarding), MTB-22 (daily reminders), MTB-23 (color palette), MTB-24 (shadows), MTB-25 (micro-interactions). All had clear intent tied to CEO directive MTB-20 ("more muted colors, less bold shadows, more friendly feel while keeping brutalism"). Acceptance criteria written directly for all five. All moved to In Design. No Awaiting Design Approval or Awaiting Decision issues.
2026-04-05 | MTB-28 | Refined onboarding with realistic lightweight mock data | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-05 | MTB-29 | Flexible goal types (days, hours, sessions, or custom metric) | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-05 | MTB-30 | Focus session mode (distraction-free timer with auto-record to campaign) | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-05 | Run 52. Three new Backlog issues: MTB-28 (refined onboarding mock data), MTB-29 (flexible goal types), MTB-30 (focus session mode). All Phase 4 Depth features with clear intent. Acceptance criteria written directly for all three. All moved to In Design. No Awaiting Design Approval or Awaiting Decision issues. Nothing to route this run.
2026-04-05 | Run 53. Direct CEO mention on MTB-28: "3-5 still feels like many to me" — revised acceptance criteria from 5 down to 3 focused behavioral criteria. No Backlog, Awaiting Design Approval, or Awaiting Decision issues found. All queues empty. Nothing to route this run.
2026-04-05 | Run 54. No Backlog, Awaiting Decision, or new issues. MTB-30 (Focus session mode) in Awaiting Design Approval with Designer mockup posted, CEO reply not yet received — skipped. All queues empty. Nothing to route this run.
2026-04-05 | Run 55. No Backlog, Awaiting Decision, or new issues. MTB-30 (Focus session mode) still in Awaiting Design Approval — Designer mockup posted 2026-04-04 at 15:31, CEO reply still pending (2nd run waiting). Skipped. All queues empty. Nothing to route this run.
2026-04-05 | MTB-31 | Account registration and sign-in | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-05 | MTB-32 | User profile screen | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-05 | MTB-33 | Cloud sync — upload local campaign data to Supabase on sign-in | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-05 | MTB-34 | Real-time multi-device sync | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-05 | MTB-35 | Sign-out and data management | Posted acceptance criteria comment, moved Backlog → In Design
2026-04-05 | Run 56. CEO direct mention on MTB-35 ("@levulinhkrpm please start your work"). Five new Backlog issues from Phase 5 Cloud roadmap: MTB-31 (auth), MTB-32 (profile screen), MTB-33 (cloud sync upload), MTB-34 (real-time sync), MTB-35 (sign-out/delete). All had clear intent tied to the Phase 5 Cloud phase description. Acceptance criteria written directly for all five (behavioral criteria, no implementation details). All five moved to In Design. No Awaiting Design Approval or Awaiting Decision issues. Direct mention file cleaned up. Nothing to route this run.
2026-04-05 | Run 57. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.
2026-04-05 | Run 58. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.
2026-04-05 | Run 59. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.
2026-04-05 | Run 60. No Backlog, Awaiting Design Approval, Awaiting Decision, or In Review issues. One archived issue in In Design (MTB-5). All queues empty. Nothing to route this run.
2026-04-05 | Run 61. No Backlog, Awaiting Decision, or Awaiting Design Approval issues. All queues empty. Nothing to route this run.
2026-04-05 | MTB-36 | Connect live Supabase credentials and wire backend integration | CEO direct mention: wrote acceptance criteria (behavioral), moved Backlog → In Progress (skipped design phase for backend wiring)
2026-04-05 | Run 62. CEO direct mention on MTB-36 (skip design, move to In Progress). Three behavioral acceptance criteria written: auth, data persistence, real-time sync. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Direct mention file cleaned.
2026-04-05 | Run 63. No Backlog (except MTB-37 in CTO Directives project — skipped), Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.2026-04-05 | Run 64. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Nothing to route this run.
2026-04-05 | Run 65. No Backlog (Campaign Tracker App scope), Awaiting Design Approval, or Awaiting Decision issues. Found 5 new Backlog issues in Vocab Learning App project (MTB-38 design system, MTB-39 OpenRouter, MTB-40 article discovery, MTB-41 tappable reader, MTB-42 AI definitions) — these are outside Campaign Tracker scope. Needs CEO clarification on multi-product PM routing. All Campaign Tracker queues empty. Nothing to route this run.
2026-04-05 | Run 66. No Backlog, Awaiting Design Approval, or Awaiting Decision issues in Campaign Tracker App scope. Vocab Learning App Backlog (MTB-38–42) still pending CEO clarification on multi-product routing. All queues empty. Nothing to route this run.
2026-04-05 | Run 67. No Backlog (Campaign Tracker App scope), Awaiting Design Approval, or Awaiting Decision issues. All Campaign Tracker queues empty. Vocab Learning App Backlog (MTB-38–42) still present — awaiting CEO routing decision. Nothing to route this run.
2026-04-05 | Run 68 (PM Agent). Five new Vocab Learning App Backlog issues processed: MTB-38 (Night Scholar design system), MTB-39 (OpenRouter integration), MTB-40 (Article discovery screen), MTB-41 (In-text reader with tappable words), MTB-42 (Word tap → AI definition bottom sheet). All Phase 1 features with clear intent from CTO roadmap. Acceptance criteria written for each (behavioral, testable, neutral). All five self-assigned and moved to In Design. Created AGENTS.md for Vocab Learning App. No Awaiting Decision issues. Campaign Tracker App queues remain empty.
2026-04-05 | Run 69 (this run). Campaign Tracker App: all queues empty (all 36+ issues Done, roadmap exhausted). Vocab Learning App: processed 4 new Phase 2 Backlog issues (MTB-43–46). All moved to In Design. Acceptance criteria written for each. No Awaiting Decision issues found. All Phase 1 issues still in Designer review.
2026-04-05 | Run 70 (this run). No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Campaign Tracker App: all 36+ issues Done, roadmap fully exhausted (phases 1–5b complete). Vocab Learning App: MTB-43–46 (Phase 2 Engagement) all In Design (already moved from Backlog by prior PM run). MTB-38–42 (Phase 1) all Done — Phase 1 complete, Phase 2 in-flight. Nothing to route this run.
2026-04-05 | Run 71. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Campaign Tracker App: all 36+ issues Done, roadmap fully exhausted (phases 1–5b complete). Vocab Learning App: MTB-43–46 (Phase 2) all In Design, MTB-38–42 (Phase 1) all Done — Phase 1 complete, Phase 2 in-flight. Nothing to route this run.
2026-04-06 | Run 72. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Campaign Tracker App: all 36+ issues Done, roadmap fully exhausted (phases 1–5b complete). Vocab Learning App: MTB-43–46 (Phase 2) all In Design, MTB-38–42 (Phase 1) all Done — Phase 1 complete, Phase 2 in-flight. Linear OAuth pending (not authenticated yet). All queues remain clear. Nothing to route this run.
2026-04-06 | Run 73. No Backlog, Awaiting Design Approval, or Awaiting Decision issues. All queues empty. Campaign Tracker App: all 36+ issues Done, roadmap fully exhausted (phases 1–5b complete). Nothing to route this run.
