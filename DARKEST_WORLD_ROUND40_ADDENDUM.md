# Darkest-World Round 40 Addendum

## Status
IMPLEMENTED / TEST ADDED / CI PENDING

## Pre-change full control
- Current GitHub head was `f761ee47e6908555cee9f66673f2505858e4cd79` before this round.
- Round 39 CI run #233 (`897f013f313a06347ec335baa6414a7a076a6512`) completed successfully.
- Round 39's final documentation commit was present before this round.
- Live Supabase counts verified: 12 sections, 948 storage assets, 8 social profiles, and 0 rows in content, relations, timeline, events, marathons, social posts, and suggestions.
- All exposed public tables were verified with RLS enabled.
- `darkestworld_suggestions` remains authenticated-only for INSERT and own-row SELECT.
- Supabase migrations were rechecked; the latest production migration remains `20260906220901_lock_down_private_memory_notes_policy`.
- The viewer lookup architecture remains read-only toward `darkestworld_content`; no automatic import is permitted.
- The SNES Dropbox import/security architecture and stored art assets were not targeted.

## Verified gap
The viewer lookup repository already had validation for source/type allowlists, but there was no regression coverage proving that blank queries, unsupported sources, unsupported content types, and mismatched source/type pairs are rejected before any external lookup is attempted.

## Change
Added regression tests to `test/suggestion_repository_model_test.dart` covering:
- blank query returns an empty result without a network call;
- unsupported source is rejected;
- unsupported content type is rejected;
- mismatched source/content type is rejected.

Production lookup behavior was not changed because the existing validation already correctly implements these guards.

## Data / security
- No Supabase migration.
- No database rows changed.
- No content imported.
- No Dropbox files touched.
- No artboxes or Storage assets changed.
- No Edge Function changed.
- No RLS/security policy changed.

## Commit
`be7c3ef0054d3b0d8e836296cd7bba0c99b8aa77`

## CI
GitHub Actions run #235 is currently in progress for this commit. It must be rechecked before Round 40 can be marked CI-green.
