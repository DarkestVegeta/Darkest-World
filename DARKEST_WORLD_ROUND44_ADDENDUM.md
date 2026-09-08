# Darkest-World Round 44 Addendum

## Status
GUEST MODE IMPLEMENTED / CI PENDING

## Pre-change full control
- The round began from the verified Round 43 head `a46b02ca6b15326dff74f804954cc6062eda5026`.
- Round 43 CI run #243 was verified completed successfully before Round 44 changes.
- The current Supabase public schema was rechecked before changes: all exposed public tables retain RLS; `darkestworld_content` remains empty by design; existing storage and world data were not altered.
- Supabase Security Advisor was clean with 0 findings before the Round 44 database change.
- Live `darkestworld-content-import` remains version 3, active, `verify_jwt=false`, and unchanged.
- Existing home navigation, LivingWorldScene, ChatWorldPage, ChatRepository, ChatScope, chat search, and current access/auth checks were re-read before implementation.

## Product rule implemented
Visitor Mode is now explicitly separated from Member Mode:
- Signed-out visitors see the Galaxy background but cannot enter or move through the Galaxy.
- The visitor foreground exposes exactly three choices: Games, Films, and Chatbox.
- Signed-in users continue to receive the existing full home/World navigation.
- The central access policy records the visitor destinations and member/visitor Galaxy rule.

## Guest Chatbox
- Added a dedicated `chatbox` chat scope instead of mixing Guest traffic into Games Chat.
- Guests receive an automatic `Guest000`–`Guest999` style display name, for example `Guest020`.
- Guest Chatbox has a client-side session counter of 100 messages.
- Reloading the site creates a fresh Guest session/counter, so the visitor starts again with 100 messages.
- Guest messages have no `author_id`; they are stored with a validated `guest_name`.
- Anonymous RLS is restricted to Chatbox rows only and requires the guest row shape; authenticated chat policies remain unchanged.
- The existing authenticated chat path remains authenticated-only.

## Database
Applied migration:
- `20260908191810_add_guest_chatbox_access`

It adds `guest_name`, adds `chatbox` to the chat-scope constraint, validates Guest names, and adds narrowly scoped anonymous SELECT/INSERT policies for Guest Chatbox traffic.

No existing chat, content, suggestion, storage, Dropbox, or artbox rows were changed.

## Repository changes
- Added `lib/core/access_policy.dart`.
- Added `lib/screens/guest_mode_page.dart` with the blurred Galaxy visitor presentation.
- Extended `ChatScope` and `ChatAccessPolicy` with the dedicated Chatbox scope.
- Extended `ChatRepository` and `ChatMessage` for Guest messages/names.
- Added Guest Mode handling to `ChatWorldPage`.
- Kept Chatbox outside content-search behavior.
- Added visitor access-policy and Chatbox regression coverage.
- Tracked the exact applied Supabase migration under `supabase/migrations/20260908191810_add_guest_chatbox_access.sql`.

## Explicitly not changed
- No login method was invented or implemented.
- No automatic IGDB/TMDB content import was added.
- No DarkestWorld content was automatically created.
- No Galaxy movement implementation was invented; this round establishes the visitor/member access boundary around the existing home scene.
- No SNES Dropbox import, Storage assets, artboxes, or unrelated worlds were touched.

## Security verification after database change
- RLS remains enabled on the affected chat table.
- Anonymous Chatbox policies are restricted to `chat_scope = 'chatbox'`, `author_id IS NULL`, and validated Guest names.
- Supabase Security Advisor was rechecked after the migration and returned 0 findings.

## CI
Round 44 CI was triggered by the repository commits and must be rechecked before this round is called fully green.
