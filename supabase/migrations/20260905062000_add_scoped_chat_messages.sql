alter table public.darkestworld_chat_messages
  add column if not exists chat_scope text not null default 'games'
    check (chat_scope in ('games', 'movies', 'series', 'music', 'marathon')),
  add column if not exists content_id uuid,
  add column if not exists marathon_id uuid;

alter table public.darkestworld_chat_messages
  add constraint darkestworld_chat_messages_content_fk
  foreign key (content_id)
  references public.darkestworld_content(id)
  on delete set null;

alter table public.darkestworld_chat_messages
  add constraint darkestworld_chat_messages_marathon_fk
  foreign key (marathon_id)
  references public.darkestworld_marathons(id)
  on delete set null;

alter table public.darkestworld_chat_messages
  add constraint darkestworld_chat_messages_context_ck
  check (
    (chat_scope in ('games', 'movies', 'series') and content_id is not null and marathon_id is null)
    or (chat_scope in ('music', 'games', 'movies', 'series') and content_id is null and marathon_id is null)
    or (chat_scope = 'marathon' and marathon_id is not null and content_id is null)
  );

create index if not exists darkestworld_chat_messages_scope_created_idx
  on public.darkestworld_chat_messages (chat_scope, created_at desc);

create index if not exists darkestworld_chat_messages_content_created_idx
  on public.darkestworld_chat_messages (content_id, created_at desc)
  where content_id is not null;

create index if not exists darkestworld_chat_messages_marathon_created_idx
  on public.darkestworld_chat_messages (marathon_id, created_at desc)
  where marathon_id is not null;
