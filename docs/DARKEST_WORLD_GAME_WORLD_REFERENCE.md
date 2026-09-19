# Darkest-World Visual Reference Registry

## GAME WORLD — permanent reference set

These two chat-supplied images are the canonical visual references for the Game World build.

### REF-GAME-PLANET
- Role: the Game World planet seen before entering the world.
- Visual target: dark realistic sphere, purple/violet and deep-blue surface, organic luminous terrain, turquoise/violet atmospheric accents, cinematic space.
- Source filename in the original chat: `Schermafbeelding 2026-09-19 024115(1).png`
- Original dimensions: 292 × 724 RGBA
- SHA-256: `a601f16f633190a8d35fa4208d81879221aa4bf50270078fc97cd950d94cdb5c`

### REF-GAME-ISLANDS
- Role: the environment revealed when entering Game World.
- Visual target: large floating islands in a dark atmospheric sky/ocean space; cinematic depth; each island has its own terrain identity.
- Source filename in the original chat: `downloaden (3)(1).png`
- Original dimensions: 1294 × 722 RGBA
- SHA-256: `8df2a3a3e43f5a61d4b850a133cb4023226f8eb4dccbf2ae223c10be705fa916`

## Fixed design rules

1. Game World is one living planet at the Galaxy level.
2. Entering Game World transitions into the floating-island atlas.
3. Islands must be substantially larger than the first half-example.
4. Keep the number of major realms low and visually readable.
5. Use platform identity through landscape, lighting, materials and architecture.
6. Avoid famous game characters, mascots and recognizable game scenes on the islands.
7. Nintendo is Nintendo Land / Nintendo identity, not individual famous game worlds.
8. Sega is Sega Realm; never Sonic Land.
9. PlayStation, Xbox and PC are platform territories, not collections of famous franchises.
10. Xbox may lean colder and more technological; Sega may lean older/weathered and mythic.
11. No character standing on a bridge, posing or looking at the camera.
12. No cyberpunk control panel, spaceship cockpit or normal dashboard.
13. Keep the visual language: dark, cinematic, elegant, mysterious, purple/deep-blue atmosphere.
14. UI remains a thin 2D layer over a 3D-looking world.
15. Content and game lists remain database-driven; visual placeholders must not become fake game content.

## Implementation anchor

The active Game World entry screen is:
`lib/screens/game_world_planet_page.dart`

The Galaxy routes into this page for `GalaxyWorldKind.game`.

The next layer after selecting an island routes into:
`lib/screens/game_platform_page.dart`

Do not replace the reference set with a newly generated image unless explicitly requested.
