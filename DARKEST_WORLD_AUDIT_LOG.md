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
- GitHub Actions run #146 completed successfully: Flutter analyze and full Flutter tests passed.
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
Status: IMPLEMENTED / TEST ADDED / CI PENDING

- Confirmed the existing `Social Media` world section uses slug `social-media` and description `Social media hub and posts`.
- Confirmed live `darkestworld_social_profiles` contains 8 active profile rows and `darkestworld_social_posts` currently contains 0 rows.
- Added `SocialProfile` and `SocialPost` models with required-field validation and safe optional text/date handling.
- Added `SocialMediaWorldRepository` backed by both social tables, filtering active profiles and ordering profiles deterministically; posts are ordered newest-first.
- Added read-only `SocialMediaWorldPage` with platform profiles, post list, loading/error/empty states, and refresh.
- Routed `social-media` through a dedicated `WorldDestination.socialMedia` and connected it from `main.dart`.
- Added regression tests for complete/optional profile data, required fields, post parsing, and malformed publication dates.
- No database migration or rows were changed. Existing artboxes/images remain untouched.

## Current next queue

1. Foundation remains green and security-verified.
2. Marathons World is complete and CI-green.
3. Social Media World is implemented; finish CI verification before moving on.
4. Next likely queue after green CI: Chatbox / Create Your World, while preserving the existing data model and avoiding unnecessary database writes.
5. Keep existing artboxes/images/data untouched during all feature work.
