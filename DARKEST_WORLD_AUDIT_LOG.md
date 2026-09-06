# Darkest-World Audit Log

### Round 16 — authenticated suggestion model parser robustness
Status: FIXED / TEST ADDED / CI BLOCKED

- Hardened `WorldSuggestion.fromMap`: `submitted_at` now uses `DateTime.tryParse` and rejects null, blank, or invalid timestamps with `FormatException`.
- `soul_points` accepts null as zero and numeric values via `num.toInt()`, while malformed types throw `FormatException`.
- Added regression tests for valid parsing, malformed/missing/blank timestamps, and malformed soul-point types.
- No database migration, rows, artboxes, or stored image data were modified.
- CI remains blocked/pending because no workflow run is exposed.
- Commit: `1b883d0a19dc71c00d12c98b069b6105aa4b689a`.

### Round 17 — authenticated chat UI/session alignment
Status: FIXED / VERIFIED / CI BLOCKED

- Aligned `ChatWorldPage` with the live security model: chat messages are authenticated-only, so signed-out users no longer create or consume the realtime chat stream.
- Auth state changes now clear the existing stream/search state immediately on sign-out and recreate the stream only after sign-in.
- Signed-out chat panel now explicitly requires login instead of claiming that reading is available.
- Music/Marathon chat-message search is gated while signed out; public Games/Movies/Series content search remains available.
- Existing `ChatRepository` validation and authenticated send path remain intact.
- No database migration, rows, artboxes, or stored image data were modified.
- CI run was available but failed in `flutter analyze` on pre-existing `WorldStatusRepository` null-aware count warnings; fixed in Round 18.
- Commit: `c6cb8ea519ab7e80035e8b1948c0861b0f04d207`.

### Round 18 — remaining write-surface and CI audit
Status: AUTH AUDIT VERIFIED / FIXED / CI RUN TRIGGERED

- Audited the client repository for Supabase write surfaces: the only direct table inserts are chat messages and suggestions.
- Both repositories require an authenticated `currentUser` before inserting; server-side grants also expose `INSERT` only to `authenticated`, with ownership checks in RLS.
- Live Data API grants contain no `INSERT`, `UPDATE`, or `DELETE` privileges for `anon`; authenticated write access is limited to `darkestworld_chat_messages` and `darkestworld_suggestions`.
- Public tables have no remaining RLS-disabled tables in the exposed `public` schema.
- Public functions are invoker-security trigger functions; no additional client write RPC surface was found.
- CI is now exposed. The latest Round 17 run failed only because `WorldStatusRepository` used redundant `?? 0` after exact-count calls; removed those seven dead null-aware expressions.
- Commit: `637fad8fc27bd9d6843e98895670446002cf46f2`.
- A new CI run is triggered by this fix; final pass/fail is pending.
- No database migration, rows, artboxes, or stored image data were modified.

### Round 19 — stale WorldSection test contract + final foundation verification
Status: FIXED / CI GREEN / FOUNDATION VERIFIED

- Corrected the stale `WorldSection` model test: missing required `id`, `name`, and `slug` values are now expected to throw `FormatException`, matching the hardened production parser.
- Production `WorldSection.fromMap` was not weakened; required-field validation remains intact.
- Commit: `fc0c165fd4600c78f4311eaf3179b0e462d58270`.
- GitHub Actions run #139 completed successfully: `flutter analyze` and the full Flutter test suite passed.
- Final live Supabase foundation security check confirms every exposed `public` table has RLS enabled. `anon` has no INSERT/UPDATE/DELETE privileges; authenticated writes remain limited to chat messages and suggestions with ownership RLS checks.
- Main application entry still loads the world sections from Supabase and routes sections through the centralized world-navigation layer.
- No database migration, rows, artboxes, or stored image data were modified.

### Round 20 — Events World implementation
Status: IMPLEMENTED / TEST ADDED / CI GREEN

- Added dedicated `EventsWorld` routing in the centralized navigation layer.
- Added `EventsWorldRepository` backed by `darkestworld_events` with required-field and optional-date validation.
- Added read-only `EventsWorldPage` with loading, error, empty, refresh, event metadata, dates, and location.
- Added repository regression tests.
- Live `darkestworld_events` currently contains 0 rows.
- GitHub Actions run #146 completed successfully: `flutter analyze` and full Flutter tests passed.
- No database migration, rows, artboxes, or stored image data were modified.

### Round 21 — Marathons World implementation
Status: IMPLEMENTED / TEST ADDED / CI GREEN

- Added `WorldMarathon` parsing with required `id`, `title`, and `slug` validation plus safe optional description/status/date handling.
- Added `MarathonsWorldRepository` backed by `darkestworld_marathons`, ordered by start date, title, and id.
- Added read-only `MarathonsWorldPage` with loading, error, empty, refresh, status, and schedule display.
- Routed `marathons` through the dedicated navigation destination and connected it from `main.dart`.
- Added regression tests for complete rows, optional fields, required fields, and malformed dates.
- Live `darkestworld_marathons` contains 0 rows; RLS is enabled, anonymous SELECT is disabled, authenticated SELECT is enabled, and no insert privilege is exposed.
- GitHub Actions run `34061169196` completed successfully: Flutter analyze and the full Flutter test suite passed.
- Current verified CI head: `c561c3d4693b7c8b6f43bd949a85ff4f9e0a16ae`.
- No database migration or data rows were changed. Existing artboxes/images remain untouched.

### Round 22 — Social Media World implementation
Status: IMPLEMENTED / TEST ADDED / CI GREEN

- Confirmed the existing `Social Media` world section uses slug `social-media` and description `Social media hub and posts`.
- Confirmed live `darkestworld_social_profiles` contains 8 active profile rows and `darkestworld_social_posts` currently contains 0 rows.
- Added `SocialProfile` and `SocialPost` models with required-field validation and safe optional text/date handling.
- Added `SocialMediaWorldRepository` backed by both social tables, filtering active profiles and ordering profiles deterministically; posts are ordered newest-first.
- Added read-only `SocialMediaWorldPage` with platform profiles, post list, loading/error/empty states, and refresh.
- Routed `social-media` through a dedicated `WorldDestination.socialMedia` and connected it from `main.dart`.
- Added regression tests for complete/optional profile data, required fields, post parsing, and malformed publication dates.
- GitHub Actions run #160 was superseded during the Chatbox/Create Your World implementation; the final verified CI chain is green on the subsequent commits.
- No database migration or rows were changed. Existing artboxes/images remain untouched.

### Round 23 — Chatbox / Create Your World implementation
Status: IMPLEMENTED / TEST ADDED / CI GREEN

- Added dedicated `Chatbox` routing while preserving the existing `Chat` destination and its Marathon Chat behavior.
- `chatbox` opens the existing `ChatWorldPage` without activating Marathon Chat.
- Added `CreateYourWorldRepository` backed read-only by the existing `create_your_world_system` configuration table.
- Added `CreateYourWorldSystem` parser validation for required text, booleans, and timestamps.
- Added dedicated `CreateYourWorldPage` construction shell showing the live feature configuration and explicitly avoiding personal-world writes.
- Routed `create-your-world` through the dedicated navigation destination and connected it from `main.dart`.
- Added regression tests for Create Your World parsing and dedicated Chatbox/Create Your World routing.
- Initial CI run #166 exposed a stale routing test; the test was corrected without changing production routing.
- Final GitHub Actions run #167 completed successfully: Flutter analyze and the full Flutter test suite passed.
- No database migration, rows, artboxes, or stored image data were modified.

### Round 24 — SNES import security fallback removal
Status: FIXED / LIVE FUNCTION UPDATED / NO DATA CHANGED

- Found a real security flaw during the A-to-Z audit in `snes-sealed-import`: the live Edge Function contained a hardcoded fallback value for `SNES_IMPORT_TOKEN`.
- Removed the hardcoded fallback from the live function.
- The function now refuses every request if `SNES_IMPORT_TOKEN` is absent and otherwise requires an exact `x-cron-token` match.
- Preserved the existing Dropbox OAuth, Dropbox file traversal, Supabase Storage upload, `storage_assets` recording, duplicate handling, and Dropbox deletion behavior.
- Kept `verify_jwt=false` because the function uses its existing custom internal authentication header.
- Deployed live `snes-sealed-import` version 13 successfully.
- Re-read the deployed function and confirmed the hardcoded token fallback is gone.
- No database rows, migrations, artboxes, or stored images were modified.
- A live Dropbox import was intentionally NOT triggered during verification, because doing so could delete source files from Dropbox; the existing 5-minute Cron configuration was left untouched.

### Round 25 — private memory notes RLS hardening
Status: FIXED / SECURITY ADVISOR CLEAN / CI GREEN

- Fresh read-only control check confirmed Round 24 CI run #169 completed successfully: Flutter analyze and the full Flutter test suite passed.
- Rechecked the live Supabase schema and confirmed `private.darkestworld_memory_notes` is intentionally not a client-facing data surface.
- Supabase security advisor reported one informational `rls_enabled_no_policy` finding because the private table had RLS enabled but no explicit policy.
- Added an explicit restrictive deny-all RLS policy for direct access to `private.darkestworld_memory_notes`; privileged backend/service access remains governed separately.
- Supabase security advisor was confirmed clean after the change.
- No existing rows were changed, and no artboxes or stored images were touched.
- Migration: `20260906220901_lock_down_private_memory_notes_policy`.
- GitHub Actions run #170 completed successfully: Flutter analyze and the full Flutter test suite passed.

### Round 26 — Timeline / Chronology construction layer
Status: IMPLEMENTED / TEST ADDED / CI GREEN

- Fresh control check was completed before implementation; the Round 25 CI chain was green and the existing architecture was preserved.
- Added a dedicated `Timeline` navigation destination without changing the existing world-section database rows.
- Added `TimelineWorldPage` as the first construction layer for the Notion-defined Timeline / Chronology concept.
- The page documents cross-media chronology such as `Game → Game → Movie → Series → Game`, supporting Games, Movies, Series, franchise timelines and related content.
- Added a navigation regression test and a widget regression test.
- The page is explicitly read-only and does not create or modify timeline data.
- Supabase live SQL access was unavailable during this round, so no database migration or timeline schema change was attempted; this avoids guessing the existing timeline table contract.
- No database rows, artboxes, or stored images were changed.
- The initial widget regression assertion was corrected to account for the page title and heading both using `Timeline / Chronology`.
- GitHub Actions run #177 completed successfully on head `3f778f8c06d72034f55bcfdd6543768802a817a1`.

### Round 27 — DarkestVegeta Visual Hub construction layer
Status: IMPLEMENTED / TEST ADDED / CI FIX IN PROGRESS

- Added the first read-only construction layer for the Notion-defined DarkestVegeta Visual Hub.
- Added the Visual Hub navigation entry and page, including the Streaming Room structure with `LEFT`, `CENTER`, and `RIGHT` areas plus the DarkestVegeta persona / desk area.
- Added a widget regression test for the Visual Hub construction layer.
- Flutter analyze passed and 63 tests passed before one regression assertion failed because the page title appears in two widgets.
- Fixed only that stale/overly strict test assertion; production Visual Hub code was not changed.
- Latest fix commit: `9de9deea55d93bbdab2aeb31597ef0cbc0719ff1`.
- The failed CI run was `#181` on the previous Visual Hub commit; a fresh CI run is required for the corrected head.
- No database migration, rows, artboxes, or stored images were modified.

## Current next queue

1. Foundation remains green and security-verified.
2. Marathons World is complete and CI-green.
3. Social Media World is complete and CI-green.
4. Chatbox / Create Your World construction layer is complete and CI-green.
5. Round 24 SNES import security flaw is fixed in the live function.
6. Round 25 private memory-note RLS advisor finding is fixed; security advisor is clean.
7. Round 26 Timeline / Chronology construction layer is complete and CI-green.
8. Round 27 Visual Hub is implemented; CI must be verified green on the corrected head before this round is closed.
9. Next feature round must begin with a fresh read-only control check and must preserve the existing data model and existing artboxes/images.
10. Keep the SNES Dropbox import flow untouched unless a dedicated import-security task is explicitly being performed.
11. Do not select DarkestWall as the next feature merely because it is an open concept; its implementation remains intentionally deferred.
