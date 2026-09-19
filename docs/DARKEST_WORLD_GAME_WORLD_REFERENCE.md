# Darkest-World Visual Reference Registry

## GAME WORLD — permanent reference set

These two chat-supplied images are the canonical visual references for the Game World build.

### REF-GAME-PLANET
- Role: Game World planet before entering the world.
- Source filename: `Schermafbeelding 2026-09-19 024115(1).png`
- Original dimensions: 292 × 724 RGBA
- SHA-256: `a601f16f6331900a8d35fa4208d81879221aa4bf50270078fc97cd950d94cdb5c`
- Target: dark realistic sphere, purple/violet and deep-blue surface, organic luminous terrain, turquoise/violet atmospheric accents, cinematic space.

### REF-GAME-ISLANDS
- Role: environment revealed when entering Game World.
- Source filename: `downloaden (3)(1).png`
- Original dimensions: 1294 × 722 RGBA
- SHA-256: `8df2a3a3e43f5a61d4b850a133cb4023226f8eb4dccbf2ae223c10be705fa916`
- Target: large floating islands, atmospheric depth, distinct terrain identities, cinematic composition.

## Fixed design rules

1. Game World is one living planet at the Galaxy level.
2. Entering Game World transitions into the floating-island atlas.
3. Islands are substantially larger than the original half-example.
4. Keep the number of major realms low and visually readable.
5. Platform identity comes from landscape, lighting, materials and architecture.
6. Avoid famous game characters, mascots and recognizable game scenes.
7. Nintendo is Nintendo Land / Nintendo identity, not individual famous game worlds.
8. Sega is Sega Realm; never Sonic Land.
9. PlayStation, Xbox and PC are platform territories, not famous franchise worlds.
10. Xbox may lean colder and technological; Sega may lean older/weathered and mythic.
11. No character standing on a bridge, posing or looking at the camera.
12. No cyberpunk control panel, spaceship cockpit or normal dashboard.
13. Visual language: dark, cinematic, elegant, mysterious, purple/deep-blue atmosphere.
14. UI is a thin 2D layer over a 3D-looking world.
15. Content and game lists remain database-driven; visual placeholders must not become fake game content.

## Implementation anchors

- Galaxy entry: `lib/screens/galaxy_home_page.dart`
- Active Game World entry/planet + island atlas: `lib/screens/game_world_planet_page.dart`
- Platform layer after selecting an island: `lib/screens/game_platform_page.dart`

Do not replace this reference set with a newly generated image unless explicitly requested.
