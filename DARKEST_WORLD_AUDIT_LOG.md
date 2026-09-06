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
- GitHub commits for this round: `11c4f89ea7176e73c7ea2ebf754d31c066858561`, `a7727c43255966fe166dc07a267785aedfeefb29`, `3d3bc5ef3069134246f30611c660048ccf042bab`.
- CI lookup for the latest commit returned no workflow run, so this round is not marked CI-passed yet.

### Round 4 — fallback-world foundation/data contract
Status: FIXED / TEST ADDED / CI PENDING

- Audited `BasicSectionPage` and the world-section model used by the fallback worlds.
- Confirmed fallback pages are intentionally generic and do not fabricate data when their `items` collection is empty.
- Found that `WorldSection.fromMap` silently converted missing/blank required identity fields into an apparently valid section. That could create a broken world entry instead of surfacing malformed data through the existing home-page error state.
- Tightened the model contract: `id`, `name`, and `slug` must now contain usable values; optional `description` is normalized to an empty string; `sort_order` keeps the existing numeric/default behavior.
- Added `test/world_sections_repository_test.dart` covering valid parsing, nullable description, numeric sort-order conversion, and rejection of missing/blank required fields.
- No dedicated feature pages were added; this round stayed within the foundation scope.
- No artboxes or stored image data were changed.
- Commits: `3a644ba512c886fd133ca45421faff1ce98e8ae8`, `939475c3c8eaa587edf0bd8797b884c9067b3ad9`.
- CI workflow is configured for pushes to `main`, but lookup for commit `939475c3c8eaa587edf0bd8797b884c9067b3ad9` returned no workflow run. CI therefore remains **pending**, not green.

### Round 5 — world → browser → detail navigation contract
Status: FIXED / TEST ADDED / CI PENDING

- Audited `content_browser_page.dart`, `content_detail_page.dart`, and `content_repository.dart` as one navigation chain.
- Confirmed browser cards hand the selected content row directly into the detail page, and detail Previous/CURRENT/Next and Related entries reopen the same detail contract.
- Found a correctness coupling in the detail page: Related and Previous/CURRENT/Next were loaded through one `Future.wait`, so a failure in either query caused both UI sections to enter the error state even when the other query succeeded.
- Split Related and franchise-navigation loading into independent operations with independent loading/error state. A failure in one navigation contract no longer hides a successful result from the other.
- Hardened franchise navigation around a trimmed current id and extracted the deterministic ordering/selection logic into `ContentRepository.buildFranchiseNavigation` so the core Previous/CURRENT/Next contract can be tested without requiring a live database.
- Preserved the intended ordering: timeline wins when it identifies the current item; otherwise release date → title → id is the deterministic fallback. If a populated timeline does not contain the current item, fallback ordering remains available.
- Added `test/content_repository_navigation_test.dart` covering fallback ordering, timeline ordering, timeline-miss fallback, and malformed current-item rejection.
- Existing artboxes and stored image data were not touched.
- Commits: `c9d0a28266234be1a67049195779607b02afe90c`, `9a95e364073f4fd3b9f00e333c2e88cb73727e8d`, `1fb5c0a60c2942b8fb693839ba4d31cd5c4e0fbd`.
- CI lookup for the latest commit `1fb5c0a60c2942b8fb693839ba4d31cd5c4e0fbd` returned no workflow run, so this round is **CI pending**, not CI-passed.

### Round 6 — realtime lifecycle and authenticated chat session behavior
Status: FIXED / VERIFIED / CI PENDING

- Audited `ChatWorldPage` and `ChatRepository` for Realtime subscription lifecycle and auth-session behavior.
- Found that the chat UI only checked `currentUser` at send time. The screen itself did not react to login/logout changes, so the input could remain apparently usable after a session transition until a send attempt failed.
- Added an explicit `onAuthStateChange` subscription in `ChatWorldPage` and cancel it in `dispose`, so the UI now tracks the live auth session and cannot keep an active send control after logout.
- Chat remains readable while signed out, while message creation is visibly disabled until an authenticated session exists. The repository still keeps the server-side auth/RLS check as the authoritative protection.
- Verified the live database contract: `darkestworld_chat_messages` is in the `supabase_realtime` publication and has RLS enabled. Its current policies allow authenticated SELECT and authenticated INSERT only when `auth.uid()` matches `author_id`.
- No Realtime schema objects were modified. This matters because Supabase locked the managed `realtime` schema against direct structural changes in July 2026; the existing publication-based setup is left intact.
- No artboxes or stored image data were touched.
- Commit: `b9e3ba7353f0df3c32b1b7b8d42938b013372fd9`.
- CI lookup for `b9e3ba7353f0df3c32b1b7b8d42938b013372fd9` has not produced a workflow run, so CI remains **pending**, not green.

## Current next queue

1. Audit CI/test coverage gaps and add only foundation tests that prove real behavior.
2. Re-run security/data integrity checks after any backend change.
3. Audit auth/session behavior across the remaining authenticated surfaces (suggestions and any future write surfaces).
4. Recheck world → browser → detail navigation only if a new change/regression/dependency requires it.

## Latest known repository state

- Main app: Flutter PC-first foundation.
- Supabase project: `abmqcbfwdwzgapvgqifk`.
- Database sections currently: 12.
- SNES sealed assets currently documented at: 947.
- Required SNES minimum: 890.
- Content rows currently: 0, so production franchise navigation has no populated content sequence yet.
- Content-browser boundary tests are present.
- Explicit world-navigation contract and tests are present.
- World-section parsing contract now rejects malformed required identity fields and has dedicated tests.
- Franchise navigation now has a directly testable deterministic contract.
- Content detail Related and Previous/CURRENT/Next loading are independent.
- Chat auth state is now lifecycle-aware and the Realtime publication/RLS contract was verified.

## Rule for the next `go`

Start at **Current next queue #1**, not at the beginning of this log. Move the queue forward after completing an item.
