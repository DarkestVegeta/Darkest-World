create table if not exists public.darkestworld_suggestions (
  id uuid primary key default gen_random_uuid(),
  submitted_by uuid not null references auth.users(id) on delete cascade,
  source text not null check (source in ('igdb', 'tmdb')),
  content_type text not null check (content_type in ('game', 'movie', 'series')),
  external_id text not null,
  title text not null,
  image_url text,
  soul_points integer not null default 0 check (soul_points >= 0),
  status text not null default 'pending' check (status in ('pending', 'accepted', 'rejected', 'later')),
  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz,
  unique (source, external_id, submitted_by)
);

create index if not exists darkestworld_suggestions_status_idx
  on public.darkestworld_suggestions (status, submitted_at desc);

create index if not exists darkestworld_suggestions_submitted_by_idx
  on public.darkestworld_suggestions (submitted_by, submitted_at desc);

alter table public.darkestworld_suggestions enable row level security;

create policy "authenticated users can create own suggestions"
  on public.darkestworld_suggestions
  for insert
  to authenticated
  with check ((select auth.uid()) = submitted_by);

create policy "authenticated users can read own suggestions"
  on public.darkestworld_suggestions
  for select
  to authenticated
  using ((select auth.uid()) = submitted_by);
