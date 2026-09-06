begin;

select plan(18);

-- Critical exposed tables must have RLS enabled.
select results_eq(
  $$select count(*)::bigint from pg_class c join pg_namespace n on n.oid = c.relnamespace where n.nspname = 'public' and c.relname in ('darkestworld_chat_messages','darkestworld_suggestions','storage_assets','darkestworld_content') and c.relrowsecurity$$,
  $$values (4::bigint)$$,
  'critical public tables have RLS enabled'
);

-- The internal memory table must stay protected by RLS and have no client grants.
select results_eq(
  $$select count(*)::bigint from pg_class c join pg_namespace n on n.oid = c.relnamespace where n.nspname = 'private' and c.relname = 'darkestworld_memory_notes' and c.relrowsecurity$$,
  $$values (1::bigint)$$,
  'private memory table has RLS enabled'
);

select results_eq(
  $$select count(*)::bigint from information_schema.role_table_grants where table_schema='private' and table_name='darkestworld_memory_notes' and grantee in ('anon','authenticated')$$,
  $$values (0::bigint)$$,
  'private memory table has no client grants'
);

-- Read-only catalog tables: client roles must not receive write grants.
select results_eq(
  $$select count(*)::bigint from information_schema.role_table_grants where table_schema='public' and table_name in ('darkestworld_content','darkestworld_sections','storage_assets','game_world_platforms','music_world_categories') and grantee in ('anon','authenticated') and privilege_type in ('INSERT','UPDATE','DELETE','TRUNCATE','REFERENCES','TRIGGER')$$,
  $$values (0::bigint)$$,
  'catalog tables have no client write grants'
);

-- Chat: authenticated can read/write new messages, but cannot mutate/delete existing messages through grants.
select results_eq(
  $$select count(*)::bigint from information_schema.role_table_grants where table_schema='public' and table_name='darkestworld_chat_messages' and grantee='authenticated' and privilege_type in ('SELECT','INSERT')$$,
  $$values (2::bigint)$$,
  'authenticated chat grants are select and insert'
);

select results_eq(
  $$select count(*)::bigint from information_schema.role_table_grants where table_schema='public' and table_name='darkestworld_chat_messages' and grantee='authenticated' and privilege_type in ('UPDATE','DELETE','TRUNCATE','REFERENCES','TRIGGER')$$,
  $$values (0::bigint)$$,
  'authenticated chat has no mutation grants'
);

select results_eq(
  $$select count(*)::bigint from information_schema.role_table_grants where table_schema='public' and table_name='darkestworld_chat_messages' and grantee='anon'$$,
  $$values (0::bigint)$$,
  'anon has no chat grants'
);

-- Suggestions: authenticated can submit/read, but cannot alter/delete them directly.
select results_eq(
  $$select count(*)::bigint from information_schema.role_table_grants where table_schema='public' and table_name='darkestworld_suggestions' and grantee='authenticated' and privilege_type in ('SELECT','INSERT')$$,
  $$values (2::bigint)$$,
  'authenticated suggestion grants are select and insert'
);

select results_eq(
  $$select count(*)::bigint from information_schema.role_table_grants where table_schema='public' and table_name='darkestworld_suggestions' and grantee='authenticated' and privilege_type in ('UPDATE','DELETE','TRUNCATE','REFERENCES','TRIGGER')$$,
  $$values (0::bigint)$$,
  'authenticated suggestions have no mutation grants'
);

select results_eq(
  $$select count(*)::bigint from information_schema.role_table_grants where table_schema='public' and table_name='darkestworld_suggestions' and grantee='anon'$$,
  $$values (0::bigint)$$,
  'anon has no suggestion grants'
);

-- Internal recommendation tables are authenticated read-only and row-scoped to the viewer.
select results_eq(
  $$select count(*)::bigint from information_schema.role_table_grants where table_schema='public' and table_name in ('darkestworld_viewer_recommendations','darkestworld_viewer_recommendation_ranking') and grantee='anon'$$,
  $$values (0::bigint)$$,
  'anon has no recommendation grants'
);

select results_eq(
  $$select count(*)::bigint from information_schema.role_table_grants where table_schema='public' and table_name in ('darkestworld_viewer_recommendations','darkestworld_viewer_recommendation_ranking') and grantee='authenticated' and privilege_type <> 'SELECT'$$,
  $$values (0::bigint)$$,
  'authenticated recommendations are read-only'
);

select results_eq(
  $$select count(*)::bigint from pg_policies where schemaname='public' and tablename='darkestworld_viewer_recommendations' and policyname='authenticated users can read own viewer recommendations' and roles='{authenticated}' and cmd='SELECT' and qual like '%auth.uid()%viewer_id%'$$,
  $$values (1::bigint)$$,
  'recommendations have an authenticated own-viewer read policy'
);

select results_eq(
  $$select count(*)::bigint from pg_policies where schemaname='public' and tablename='darkestworld_viewer_recommendation_ranking' and policyname='authenticated users can read own viewer recommendation ranking' and roles='{authenticated}' and cmd='SELECT' and qual like '%auth.uid()%viewer_id%'$$,
  $$values (1::bigint)$$,
  'recommendation ranking has an authenticated own-viewer read policy'
);

-- Scoped chat schema invariants exist.
select results_eq(
  $$select count(*)::bigint from information_schema.columns where table_schema='public' and table_name='darkestworld_chat_messages' and column_name in ('chat_scope','content_id','marathon_id')$$,
  $$values (3::bigint)$$,
  'chat context columns exist'
);

select results_eq(
  $$select count(*)::bigint from pg_constraint pc join pg_class c on c.oid=pc.conrelid join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and c.relname='darkestworld_chat_messages' and pg_get_constraintdef(pc.oid) like '%chat_scope%'$$,
  $$values (1::bigint)$$,
  'chat scope consistency constraint exists'
);

-- Suggestion integrity constraints.
select results_eq(
  $$select count(*)::bigint from pg_constraint pc join pg_class c on c.oid=pc.conrelid join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and c.relname='darkestworld_suggestions' and pg_get_constraintdef(pc.oid) like '%soul_points%'$$,
  $$values (1::bigint)$$,
  'suggestion soul-points constraint exists'
);

select results_eq(
  $$select count(*)::bigint from pg_constraint pc join pg_class c on c.oid=pc.conrelid join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and c.relname='darkestworld_suggestions' and pg_get_constraintdef(pc.oid) like '%source%'$$,
  $$values (2::bigint)$$,
  'suggestion source constraints exist'
);

select * from finish();
rollback;
