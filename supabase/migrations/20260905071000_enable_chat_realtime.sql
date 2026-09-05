do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'darkestworld_chat_messages'
  ) then
    alter publication supabase_realtime add table public.darkestworld_chat_messages;
  end if;
end
$$;
