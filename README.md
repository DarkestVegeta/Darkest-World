# Darkest-World

DarkestWorld ecosystem frontend and backend foundation.

## Architecture

- **Flutter** — PC-first frontend and world navigation.
- **Supabase** — database, Row Level Security, Storage integration and Realtime.
- **GitHub** — source control and CI.
- **Dropbox** — source asset ingestion.
- **Vision** — image analysis pipeline for imported assets.
- **IGDB/TMDB** — external viewer search and preview sources; Darkest-World does not mirror their catalogs.

## Current worlds

The home navigation is database-driven through `darkestworld_sections`.

- Game World
- Cinema World
- Series World
- Music World
- Identity World
- Dark Core
- Chat
- Events
- Marathons
- Social Media
- Chatbox
- Create Your World

## Chat architecture

Chatbox is a reusable interface inside relevant worlds. Chat World is the full community environment with these scopes:

- Games
- Movies
- Series
- Music
- Marathon

Game, movie and series content can open a content-specific chat context. Music has a world-level chat context. Marathon Chat is based on chat presence/context and is **not tied to Twitch or streaming status**.

Chat messages use Supabase Realtime and are protected by RLS. Only authenticated users can read/send chat messages.

## Suggestions

Viewers can search externally on IGDB/TMDB and submit a minimal Darkest-World suggestion containing title, image, type and external ID. Suggestions also record Zielenpunten and review status. External catalogs are not bulk-imported into Darkest-World.

## Content navigation

Content detail pages support the intended `Previous | CURRENT | Next` structure. Timeline data is authoritative when populated; otherwise franchise content falls back to release-date ordering. `Related` remains separate from the main sequence.

## Asset safety

SNES sealed assets are never removed as part of frontend/system work. The current Supabase project contains 947 `snes_sealed` assets and the required minimum is 890.

## Quality gate

Every meaningful frontend change is checked through GitHub Actions with:

```text
flutter pub get
flutter analyze
flutter test
```
