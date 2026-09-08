# Darkest-World Round 41 Addendum

## Status
FIXED / LIVE FUNCTION UPDATED / CI PENDING

## Pre-change full control
- Current GitHub head before this round was `e6f020590aad144390274f514130bb3afba9d88d`.
- Round 40 GitHub Actions run #236 completed successfully: Flutter analyze and the full Flutter test suite passed.
- Round 40 added regression coverage for blank queries, unsupported sources/types, and mismatched source/type pairs.
- Live Supabase schema was rechecked: all exposed public tables have RLS enabled; content, relations, timeline, events, marathons, social posts, and suggestions remain empty by design.
- Supabase Security Advisor remains clean with 0 findings.
- `darkestworld-content-import` was live at version 2 with `verify_jwt=true`.
- The Flutter Suggestions UI intentionally allows signed-out viewers to search IGDB/TMDB, while authenticated users alone may submit suggestions.
- The deployed lookup function did not return `image_url`, although the Flutter result model/UI supports it.

## Verified gap
There was a real runtime mismatch in the viewer lookup path:
1. The UI permits signed-out lookup.
2. Supabase Edge Function version 2 still required a user JWT at the platform layer, which blocks signed-out requests before function code runs.
3. The function returned normalized metadata but omitted the `image_url` field expected by the viewer result model/UI.
4. Browser-style invocation also lacked explicit CORS handling.

## Change
Updated the live `darkestworld-content-import` Edge Function to version 3:
- disabled platform JWT verification because this endpoint is intentionally a public, read-only viewer lookup;
- added explicit CORS handling for `OPTIONS` and response headers;
- added IGDB cover image URLs when a cover image ID exists;
- added TMDB poster image URLs when a poster path exists;
- preserved the strict source allowlist (`igdb`, `tmdb_movie`, `tmdb_tv`);
- preserved blank-query rejection and POST-only behavior;
- preserved the read-only contract: the function writes nothing to `darkestworld_content` or any other table.

The current live function was re-read after deployment and confirmed as version 3 with `verify_jwt=false`.

## Data / security
- No database migration.
- No database rows changed.
- No content imported.
- No Dropbox files touched.
- No artboxes or Storage assets changed.
- No RLS policies changed.
- Security Advisor remains clean.
- The public endpoint exposes only external lookup results and does not expose private database data or write access.

## Deployment
- Function: `darkestworld-content-import`
- Previous version: 2
- New live version: 3
- New deployment hash: `14e0299142e5b16912b29c55693efb31c0f676aed1abaeb1252d596f8569c06d`

## Repository
- This addendum is documentation only and does not change application behavior.
- GitHub Actions will verify the repository remains green after the documentation commit.

## Remaining open point
The live Edge Function source is still not represented as a normal tracked `supabase/functions/darkestworld-content-import` source tree in the repository. That is a source-of-truth/maintenance gap, not a runtime blocker, and should only be addressed in a separate coherent round after a fresh full audit.
