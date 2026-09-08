# Darkest-World Round 42 Addendum

## Status
SOURCE-OF-TRUTH GAP FIXED / CI PENDING

## Pre-change full control
- Current GitHub head before this round was `4839b3f3941130d53a80ea3456351d3bdd0af947`.
- Round 40 CI run #236 was verified green before Round 41 changes.
- Round 41 CI run #237 was still in progress at the start of this round; no claim of success is made here.
- Live Supabase schema was rechecked: public tables retain RLS; `darkestworld_content` and its relations remain empty by design; `storage_assets` remains the existing asset surface.
- Supabase Security Advisor remains clean with 0 findings.
- Live `darkestworld-content-import` is version 3, active, `verify_jwt=false`, and contains the public read-only IGDB/TMDB lookup implementation.
- GitHub code search confirmed that the live function had no tracked repository source tree before this round.
- Existing Flutter suggestion repository was re-read and still invokes `darkestworld-content-import` as the viewer lookup endpoint; no application behavior change was required.

## Verified gap
Round 41 identified a real maintenance/source-of-truth gap: the deployed Edge Function source existed only in the Supabase deployment and was not represented under the repository's `supabase/functions` tree. This made the live lookup implementation harder to audit, reproduce, review, and maintain.

## Change
Added the exact live version-3 viewer lookup source to GitHub:
- `supabase/functions/darkestworld-content-import/index.ts`
- `supabase/functions/darkestworld-content-import/import_map.json`

The tracked source preserves the already-live behavior:
- public read-only viewer lookup;
- IGDB game lookup;
- TMDB movie and TV lookup;
- CORS handling;
- normalized `image_url` values;
- strict source allowlist;
- blank-query rejection;
- POST-only behavior;
- no writes to `darkestworld_content` or any other table.

No Supabase deployment was performed in this round because the tracked source was copied from the already-live version-3 function rather than changed. This avoids an unnecessary runtime redeployment.

## Data / security
- No database migration.
- No database rows changed.
- No RLS policies changed.
- No Edge Function runtime version changed.
- No Dropbox files touched.
- No Storage assets or artboxes changed.
- Security Advisor remains clean.

## Result
The viewer lookup implementation now has a repository source-of-truth matching the verified live version-3 function. Future changes can be reviewed and deployed from tracked source instead of relying on an untracked live-only implementation.

## CI
GitHub Actions is expected to verify the repository after the source/documentation commits. CI status must be rechecked before this round is called fully green.
