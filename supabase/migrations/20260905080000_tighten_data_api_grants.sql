-- Defense in depth for the internal schema. It is not exposed to anon/authenticated,
-- but RLS prevents accidental future grants from exposing the internal memory table.
alter table private.darkestworld_memory_notes enable row level security;

-- Public read-only catalog/config tables.
revoke insert, update, delete, truncate, references, trigger on
  public.darkestworld_content,
  public.darkestworld_content_relations,
  public.darkestworld_sections,
  public.darkestworld_timeline,
  public.darkestworld_void_lore,
  public.darkestworld_world_creatures,
  public.game_content_types,
  public.game_world_platforms,
  public.music_world_categories,
  public.pc_platforms,
  public.playstation_consoles,
  public.sega_consoles,
  public.storage_assets,
  public.xbox_consoles
  from anon, authenticated;

grant select on
  public.darkestworld_content,
  public.darkestworld_content_relations,
  public.darkestworld_sections,
  public.darkestworld_timeline,
  public.darkestworld_void_lore,
  public.darkestworld_world_creatures,
  public.game_content_types,
  public.game_world_platforms,
  public.music_world_categories,
  public.pc_platforms,
  public.playstation_consoles,
  public.sega_consoles,
  public.storage_assets,
  public.xbox_consoles
  to anon, authenticated;

-- Authenticated read-only world data.
revoke all on
  public.create_your_world_system,
  public.darkestworld_events,
  public.darkestworld_marathons,
  public.darkestworld_social_posts,
  public.darkestworld_social_profiles,
  public.darkestworld_viewer_recommendation_ranking,
  public.darkestworld_viewer_recommendations
  from anon;

revoke insert, update, delete, truncate, references, trigger on
  public.create_your_world_system,
  public.darkestworld_events,
  public.darkestworld_marathons,
  public.darkestworld_social_posts,
  public.darkestworld_social_profiles,
  public.darkestworld_viewer_recommendation_ranking,
  public.darkestworld_viewer_recommendations
  from authenticated;

grant select on
  public.create_your_world_system,
  public.darkestworld_events,
  public.darkestworld_marathons,
  public.darkestworld_social_posts,
  public.darkestworld_social_profiles,
  public.darkestworld_viewer_recommendation_ranking,
  public.darkestworld_viewer_recommendations
  to authenticated;

-- Chat: authenticated users can read and insert; RLS controls who may insert/read rows.
revoke all on public.darkestworld_chat_messages from anon;
revoke update, delete, truncate, references, trigger on public.darkestworld_chat_messages from authenticated;
grant select, insert on public.darkestworld_chat_messages to authenticated;

-- Suggestions: authenticated users can read and insert; RLS controls ownership.
revoke all on public.darkestworld_suggestions from anon;
revoke update, delete, truncate, references, trigger on public.darkestworld_suggestions from authenticated;
grant select, insert on public.darkestworld_suggestions to authenticated;
