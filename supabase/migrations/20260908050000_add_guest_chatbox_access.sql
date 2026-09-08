alter table public.darkestworld_chat_messages
  add column guest_name text;

alter table public.darkestworld_chat_messages
  drop constraint if exists darkestworld_chat_messages_chat_scope_check;

alter table public.darkestworld_chat_messages
  add constraint darkestworld_chat_messages_chat_scope_check
  check (chat_scope = any (array[
    'games'::text,
    'movies'::text,
    'series'::text,
    'music'::text,
    'marathon'::text,
    'chatbox'::text
  ]));

alter table public.darkestworld_chat_messages
  add constraint darkestworld_chat_messages_guest_name_check
  check (guest_name is null or guest_name ~ '^Guest[0-9]{3}$');

create policy "anonymous read guest chatbox"
on public.darkestworld_chat_messages
for select
to anon
using (
  chat_scope = 'chatbox'
  and author_id is null
  and guest_name is not null
);

create policy "anonymous send guest chatbox"
on public.darkestworld_chat_messages
for insert
to anon
with check (
  chat_scope = 'chatbox'
  and author_id is null
  and guest_name is not null
  and guest_name ~ '^Guest[0-9]{3}$'
);
