# Darkest-World — Game World Visual Source of Truth

## Purpose

This file is the permanent visual contract for the **Game World**. The AI reference images supplied for this project are not optional inspiration: they define the visual direction that the Flutter implementation must reproduce.

**Do not replace these references with a newly generated image unless explicitly requested.**

## Canonical reference images

### REF-GAME-ISLANDS — primary environment reference
- Source filename: `downloaden (3)(1).png`
- Original dimensions: **1294 × 722 RGBA**
- SHA-256: `a601f16f6331900a8d35fa4208d81879221aa4bf50270078fc97cd950d94cdb5c`
- Role: the visual reference for the environment revealed after entering Game World.
- Read as: a cinematic aerial/floating-island world, substantial land masses, atmospheric depth, water, mountains, cliffs and distinct regional identities.
- Important: this is a **style/composition reference**, not a request to copy famous game worlds.

### REF-GAME-PLANET — Game World planet reference
- Source filename: `Schermafbeelding 2026-09-19 024115(1).png`
- Original dimensions: **292 × 724 RGBA**
- SHA-256: `8df2a3a3e43f5a61d4b850a133cb4023226f8eb4dccbf2ae223c10be705fa916`
- Role: the Game World planet shown at Galaxy level before entering the world.
- Read as: dark realistic sphere, purple/violet and deep-blue surface, organic luminous terrain, turquoise/violet atmospheric accents, cinematic space.

## Fixed Game World hierarchy

1. Galaxy → **Game World planet**
2. Enter planet → **large floating-island atlas**
3. Select a major island/realm → **platform world**
4. Select a platform → **game archive/list**
5. Game/content data comes from the database; visual artwork must never be invented as fake catalogue content.

## Island-world rules

The island reference is deliberately being adapted rather than copied literally.

- Major islands must be **larger and more substantial** than the example.
- Keep the number of major realms low enough that the world remains readable.
- Avoid filling islands with recognizable famous-game locations, characters, mascots or scenes.
- No Sonic Land: use **SEGA REALM** / Sega identity.
- Use **NINTENDO LAND**, **SEGA REALM**, **PLAYSTATION GALAXY**, **XBOX TERRITORY**, and **PC DIMENSION** as platform territories.
- Platform identity comes from terrain, architecture, materials, lighting, vegetation, geology and atmosphere.
- Nintendo should feel like Nintendo without turning into Mario/Zelda/etc. worlds.
- Sega can lean older, weathered and mythic.
- Xbox can lean colder, mineral, frontier and technological.
- PlayStation can lean crystalline, cliff-based and atmospheric.
- PC can lean darker, strange and geometrically varied.
- No character standing on a bridge, posing or looking at the camera.
- No cyberpunk control panel, spaceship cockpit or normal dashboard.

## Global visual language

- cinematic
- dark
- elegant
- mysterious
- realistic 3D-looking worlds
- 2D Flutter interface layered over 3D-looking environments
- purple / violet / deep blue as the Darkest-World family
- atmospheric fog, depth, shadows and restrained glow
- visual hierarchy first; UI stays subordinate to the world

## Implementation anchors

- Galaxy entry: `lib/screens/galaxy_home_page.dart`
- Game World planet + island atlas: `lib/screens/game_world_planet_page.dart`
- Platform layer: `lib/screens/game_platform_page.dart`

## Build rule

Before changing Game World visuals, compare the implementation against **REF-GAME-PLANET** and **REF-GAME-ISLANDS**. New visual decisions must extend the same language rather than drifting into a different style.

The other Darkest-World planets will receive their own visual reference sets later. Do not invent their final visual identity yet.
