# Darkest-World Audit Log

Purpose: keep every `go` round moving forward instead of repeating the same work.

## Rules

- Do not repeat a completed audit item unless a new change, regression, dependency, or explicit recheck requires it.
- Every `go` round must choose a new unfinished foundation item or a concrete regression caused by a newer change.
- Record what was inspected, changed, tested, and what remains.
- Existing artboxes and their stored data are never modified as part of foundation/system work.
- Do not add new feature work while the main foundation still has correctness gaps.

## Status legend

- DONE = inspected and considered sound
- FIXED = issue found and corrected
- TESTED = verification completed
- OPEN = still requires work
- BLOCKED = requires an external prerequisite

## Audit history

### Round 1 — foundation/security/navigation baseline
Status: DONE / FIXED / TESTED

- Established the Flutter ↔ Supabase foundation and database-driven world navigation.
- Verified public-data RLS/grants and authenticated-only chat/suggestions access.
- Verified scoped Chat architecture and realtime chat path.
- Removed the experimental falling-star Easter egg from the main world so foundation work stays focused.
- Added content-browser focus boundary protection and tests for small collections.
- Preserved the existing SNES/artbox data; no artbox was removed or modified.

### Round 2 — current main routing audit
Status: DONE / VERIFIED

- Rechecked the current `main.dart` against the live `darkestworld_sections` rows.
- Confirmed all 12 database sections are loaded dynamically.
- Confirmed dedicated routing exists for Game World, Cinema World, Series World, Music World, and Chat.
- Confirmed the remaining sections safely fall back to the generic foundation page for now.
- Confirmed this fallback is a deliberate foundation state, not a missing route accident.

### Round 3 — explicit world navigation contract
Status: FIXED / TEST ADDED / CI PENDING

- Added `lib/core/world_navigation.dart` as the single explicit mapping from world slug to destination type.
- Updated `main.dart` to use that contract instead of embedding the slug-routing contract directly in the page.
- Added `test/world_navigation_test.dart` covering all 12 current world slugs plus an unknown future slug.
- This makes accidental routing changes easier to detect and prevents the main page from silently gaining inconsistent routing logic.
- GitHub commits: `11c4f89ea7176e73c7ea2ebf754d31c066858561`, `a7727c43255966fe166dc07a267785aedfeefb29`, `3d3bc5ef3069134246f30611c660048ccf042bab`.
- CI lookup returned no workflow run, so this round is not marked CI-passed.

### Round 4 — fallback-world foundation/data contract
Status: FIXED / TEST ADDED / CI PENDING

- Audited `BasicSectionPage` and the world-section model.
- Tightened `WorldSection.fromMap`: `id`, `name`, and `slug` must be usable; optional description is normalized; sort order keeps existing numeric/default behavior.
- Added `test/world_sections_repository_test.dart` for valid parsing and malformed required fields.
- No artboxes or stored image data were changed.
- Commits: `3a644ba512c886fd133ca45421faff1ce98e8ae8`, `939475c3c8eaa587edf7b3ad9`.
- CI remains pending.

### Round 5 — world → browser → detail navigation contract
Status: FIXED / TEST ADDED / CI PENDING

- Audited `content_browser_page.dart`, `content_detail_page.dart`, and `content_repository.dart` as one navigation chain.
- Split Related and franchise-navigation loading so one failed query cannot hide the other's successful result.
- Hardened franchise navigation around trimmed current ids and extracted deterministic Previous/CURRENT/Next ordering into `ContentRepository.buildFranchiseNavigation`.
- Timeline wins when it identifies the current item; otherwise release date → title → id fallback remains available.
- Added `test/content_repository_navigation_test.dart`.
- Commits: `c9d0a28266234be1a67049195779607b02afe90c`, `9a95e364073f4fd3b9f00e333c2e88cb73727e8d`, `1fb5c0a60c2942b8fb693839ba4d31cd5c4e0fbd`.
- CI remains pending.

### Round 6 — realtime lifecycle and authenticated chat session behavior
Status: FIXED / VERIFIED / CI PENDING

- Audited Chat Realtime lifecycle and authentication state handling.
- Added an `onAuthStateChange` subscription to `ChatWorldPage`, canceled in `dispose`.
- Chat remains readable signed out; message creation is visibly disabled until authentication exists; repository/RLS remain authoritative.
- Verified live `darkestworld_chat_messages` Realtime publication and authenticated SELECT/INSERT policy contract.
- No Realtime schema objects or artboxes were changed.
- Commit: `b9e3ba7353f0df3c32b1b7b8d42938b013372fd9`.
- CI remains pending.

### Round 7 — authenticated Suggestions session behavior + CI contract audit
Status: FIXED / VERIFIED / CI BLOCKED

- Audited SuggestionsPage and SuggestionRepository as the remaining existing authenticated write surface.
- Added auth-state lifecycle handling and disabled submission while signed out.
- Audited CI workflow: `flutter analyze` and `flutter test` run on pushes to `main` and pull requests, but no workflow run is exposed for the current commits and no manual dispatch is available through the connector.
- No artboxes or stored image data were touched.
- Commit: `75196ca1614b3b077a9c0c448ed833b598905f54`.

### Round 8 — recommendation row-security gap + suggestion model coverage
Status: FIXED / TEST ADDED / VERIFIED / CI BLOCKED

- Found and fixed the missing authenticated own-viewer SELECT policies on `darkestworld_viewer_recommendations` and `darkestworld_viewer_recommendation_ranking`.
- Re-ran security inspection: recommendation warnings disappeared; private `darkestworld_memory_notes` remains intentionally internal with no anon/auth grants.
- Expanded the database security regression suite from 16 to 18 assertions and added suggestion model coverage.
- Backend migration `add_viewer_recommendation_read_policies` applied successfully.
- Commits: `478b92cd029745cb2660916ca56fc4331ff09db9`, `fac8e06499b7eeb68dab7e5ffd869aea4b9eb1`.
- CI remains blocked/pending.

### Round 9 — music category data contract
Status: FIXED / TEST ADDED / CI BLOCKED

- Hardened `MusicWorldCategory.fromMap`: required id/name/slug are trimmed and nonblank; description is normalized; sort order is preserved.
- Added `test/music_world_repository_test.dart` for normalization, nullable description/default sort order, and malformed required identity fields.
- No database migration or artbox change.
- Commits: `977cff35a5bc82afc593a5fa40b34312ae7c80f5`, `9baa8902bf88f70f025b37b81e8b794058de6bac`.
- CI remains blocked/pending.

### Round 10 — chat search query correctness
Status: FIXED / TEST ADDED / CI BLOCKED

- Audited `ChatSearchRepository`.
- Found that `%`, `_`, and `\\` in user search text could be interpreted as ILIKE wildcards.
- Hardened search escaping while preserving substring matching and added dedicated tests.
- Verified the live chat-context constraint before changing the query contract; no DB migration was necessary.
- No artboxes or stored image data were touched.
- Commits: `989b26240992cca70a30e94f4e307ea73e161392`, `d43c16d6c7cc7d05c6a5f05970961bf437695e7a`.
- CI remains blocked/pending.

### Round 11 — suggestion model integrity hardening
Status: FIXED / TEST ADDED / CI BLOCKED

- Audited the stored `WorldSuggestion` parsing contract more deeply after Round 10.
- Found that missing/null or whitespace-only required identity fields could be converted into apparently valid strings by interpolation.
- Hardened `WorldSuggestion.fromMap`: id, source, content type, external id, title, status, and submitter must be usable after trimming; blank image URLs normalize to null.
- Added regression coverage for whitespace normalization and rejection of malformed required identity fields.
- No database rows, schema, artboxes, or stored images were modified.
- Commits: `8a9a0b1b5bdba8949b2bde492842aff8a3e7a009`, `6f78d2aa01797beca101a57f4f00bf8b1ab46709`.
- CI remains blocked/pending.

### Round 12 — content navigation ordering consistency
Status: FIXED / TEST ADDED / CI BLOCKED

- Audited `ContentRepository` beyond the existing franchise-navigation tests.
- Found a subtle ordering mismatch: the database query explicitly places NULL release dates last, while the in-memory fallback previously treated missing dates as empty strings, which sorted them first.
- Corrected the in-memory comparator so missing release dates stay after dated content, matching the database contract.
- Also normalized optional type/asset-type filters and made empty content ids return safely instead of issuing meaningless queries.
- Added regression coverage proving undated content stays after dated content.
- No database migration and no artbox/storage-image modification.
- Commit: `f3b3eadb8948e2f28ff18ff2d58097d381897de2` (implementation), `5e08ed32052f95ce9713954d6c5a6a5a103281f8` (test).
- CI remains blocked/pending.

### Round 13 — deep live database foundation/security audit
Status: VERIFIED / OPEN FOLLOW-UP

- Audited the live public schema at table, RLS, policy, grant, constraint, index, and namespace level instead of only checking the previously known critical tables.
- Confirmed all current public base tables have RLS enabled.
- Confirmed exposed public catalog tables have read policies matching their intended public/authenticated read grants; authenticated user-owned surfaces have own-user policies.
- Confirmed chat context constraints still enforce the intended games/movies/series/music/marathon combinations.
- Confirmed `darkestworld_content` required identity columns are NOT NULL and its content type constraint is active.
- Confirmed current `storage_assets` count is 948 total, 947 `snes_sealed`, and 862 with public URLs; existing artbox data was untouched.
- No new security vulnerability or correctness regression was found in this live pass, so no speculative migration was created.
- Important follow-up discovered: `WorldStatusRepository` currently loads full `id` result sets client-side for counts. With 948 storage assets this is still below the common 1000-row API ceiling, but it is a scalability/correctness risk as the collection grows. This is queued for a dedicated count-contract round rather than being changed speculatively here.
- No artboxes or stored image data were touched.

### Round 14 — exact world-status counting contract
Status: FIXED / VERIFIED / CI BLOCKED

- Revisited the Round 13 follow-up instead of starting a new unrelated feature.
- Confirmed `supabase_flutter ^2.8.0` supports exact database counts through `.count(CountOption.exact)`.
- Replaced all seven client-side full-row count queries in `WorldStatusRepository` with exact database count queries, including filtered SNES and public-URL counts.
- The dashboard/status layer no longer depends on the API returning every matching row just to calculate a count, removing the row-ceiling correctness risk identified in Round 13.
- Verified the live asset totals used by the status contract remain 948 total assets, 947 SNES sealed assets, and 862 public assets.
- No database schema/data migration was required.
- No artboxes or stored image data were touched.
- Commit: `e66697e9cec702d9a350619a742ab820ac83a842`.
- CI remains blocked/pending because no workflow run is exposed for the current repository commit; the implementation was cross-checked against the current Supabase Dart API documentation.

### Round 15 — chat message model integrity contract
Status: FIXED / TEST ADDED / CI BLOCKED

- Continued directly with Current next queue #1 and audited the remaining core Chat model contract instead of repeating earlier auth/RLS work.
- Found that `ChatMessage.fromMap` previously interpolated null/malformed values into strings and silently mapped an unknown `chat_scope` to `ChatScope.games`.
- Hardened parsing so required `id`, `message`, `chat_scope`, and `created_at` fields must be nonblank after trimming; unknown scopes now throw instead of changing meaning; malformed timestamps now throw a `FormatException` instead of leaking a parse implementation error.
- Optional author/content/marathon ids are normalized so whitespace-only values become null.
- Added `test/chat_repository_model_test.dart` covering normalization, malformed required fields, unknown scope rejection, malformed timestamps, and optional-id normalization.
- Rechecked the live chat table constraints: the database still restricts chat scopes to games/movies/series/music/marathon and enforces the context combination check; no schema change was necessary.
- Re-fetched both implementation and regression test from `main` after commit to verify the intended source is present.
- GitHub CI lookup for commit `4a86ae2e3ffb7ae6733e431a83b120ce6aa1ff70` returned no workflow runs, so CI is still blocked/pending rather than claimed passed.
- No database rows, migrations, artboxes, or stored image data were modified.
- Commits: `80042c9639c9bf1c02dceac4b8ceb6f554c47a75` (implementation), `4a86ae2e3ffb7ae6733e431a83b120ce6aa1ff70` (test).

## Current next queue

1. Recheck auth/session behavior across any remaining authenticated or future write surfaces.
2. Recheck CI execution/coverage when a workflow run becomes available.
3. Final foundation stabilization audit before feature expansion.

## Latest known repository state

- Main app: Flutter PC-first foundation.
- Supabase project: `abmqcbfwdwzgapvgqifk`.
- Database sections currently: 12.
- SNES sealed assets currently: 947.
- Required SNES minimum: 890.
- Total storage assets currently: 948.
- Public storage assets currently: 862.
- Content rows currently: 0, so production franchise navigation has no populated content sequence yet.
- Content-browser boundary tests are present.
- Explicit world-navigation contract and tests are present.
- World-section parsing rejects malformed required identity fields.
- Music category parsing rejects malformed required identity fields.
- Suggestion parsing rejects malformed required identity fields.
- Chat message parsing rejects malformed required identity fields and unknown scopes instead of silently defaulting to games.
- Chat search treats ILIKE wildcard characters in user input literally.
- Franchise navigation has deterministic timeline/fallback ordering with database-compatible NULL-date handling.
- Content detail Related and Previous/CURRENT/Next loading are independent.
- Chat auth state is lifecycle-aware and the Realtime publication/RLS contract is verified.
- Suggestions auth state is lifecycle-aware and submission is visibly gated by the live session.
- Viewer recommendation tables have row-scoped authenticated read policies matching their authenticated read grants.
- World status counts now use exact database counts rather than loading full id sets.
- Database security regression test suite contains 18 assertions; pgTAP is not installed, so those assertions are not claimed as executed through pgTAP.

## Rule for the next `go`

Start at **Current next queue #1**, not at the beginning of this log. Move the queue forward after completing an item.
