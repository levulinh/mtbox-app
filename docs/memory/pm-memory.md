# PM Agent Memory

## Purpose
Track issues processed, routing decisions made, and patterns noticed across all runs.

## Last Updated
2026-04-04 (run 25)

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
