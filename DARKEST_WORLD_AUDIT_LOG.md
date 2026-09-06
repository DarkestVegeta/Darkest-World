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

## Current next queue

1. Foundation is green and security-verified.
2. Move from stabilization into the next unfinished feature/foundation-adjacent implementation.
3. Keep existing artboxes/images/data untouched during all feature work.
