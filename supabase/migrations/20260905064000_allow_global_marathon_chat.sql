alter table public.darkestworld_chat_messages
  drop constraint if exists darkestworld_chat_messages_context_ck;

alter table public.darkestworld_chat_messages
  add constraint darkestworld_chat_messages_context_ck
  check (
    (chat_scope in ('games', 'movies', 'series') and marathon_id is null)
    or (chat_scope = 'music' and content_id is null and marathon_id is null)
    or (chat_scope = 'marathon' and content_id is null)
  );
