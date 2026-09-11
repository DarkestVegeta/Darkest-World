import 'package:flutter/material.dart';
import '../core/world_sections_repository.dart';
import '../widgets/darkest_world_universe.dart';
import 'basic_section_page.dart';
import 'cinema_world_page.dart';
import 'dark_core_page.dart';
import 'family_world_page.dart';
import 'game_world_page.dart';
import 'identity_world_page.dart';
import 'music_world_page.dart';

class GalaxyHomePage extends StatefulWidget {
  const GalaxyHomePage({super.key});

  @override
  State<GalaxyHomePage> createState() => _GalaxyHomePageState();
}

class _GalaxyHomePageState extends State<GalaxyHomePage> {
  final repository = WorldSectionsRepository();
  late Future<List<WorldSection>> sections = repository.load();

  static const _fallback = <GalaxyWorld>[
    GalaxyWorld('VEGETA', 'The darker heart of DarkestWorld.', GalaxyWorldKind.vegeta),
    GalaxyWorld('GAME-WORLD', 'Games you have played and what comes next.', GalaxyWorldKind.game),
    GalaxyWorld('MUSIC-WORLD', 'Music, sound and the worlds they create.', GalaxyWorldKind.music),
    GalaxyWorld('DARKEST-IDENTITY', 'The identity behind DarkestWorld.', GalaxyWorldKind.identity),
    GalaxyWorld('DARKESTFAMILY', 'Personas, people and stories.', GalaxyWorldKind.family),
    GalaxyWorld('CINEMA-WORLD', 'Films and series.', GalaxyWorldKind.cinema),
    GalaxyWorld('CREATION', 'Art, projects and experiments.', GalaxyWorldKind.creation),
    GalaxyWorld('ARCHIVE', 'Things worth keeping.', GalaxyWorldKind.archive),
    GalaxyWorld('COMING SOON', 'What DarkestWorld can become.', GalaxyWorldKind.comingSoon),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010105),
      body: FutureBuilder<List<WorldSection>>(
        future: sections,
        builder: (context, snapshot) {
          return DarkestWorldUniverse(
            worlds: _mapWorlds(snapshot.data ?? const []),
            onWorldTap: _openWorld,
          );
        },
      ),
    );
  }

  List<GalaxyWorld> _mapWorlds(List<WorldSection> source) => _fallback.map((fallback) {
        final matches = source.where((s) => _matches(s, fallback));
        final section = matches.isEmpty ? null : matches.first;
        return section == null
            ? fallback
            : GalaxyWorld(fallback.title, section.description, fallback.kind);
      }).toList();

  bool _matches(WorldSection section, GalaxyWorld world) {
    final text = '${section.name} ${section.slug}'.toLowerCase();
    switch (world.kind) {
      case GalaxyWorldKind.vegeta:
        return text.contains('vegeta');
      case GalaxyWorldKind.game:
        return text.contains('game');
      case GalaxyWorldKind.music:
        return text.contains('music');
      case GalaxyWorldKind.identity:
        return text.contains('identity');
      case GalaxyWorldKind.family:
        return text.contains('family');
      case GalaxyWorldKind.cinema:
        return text.contains('cinema');
      case GalaxyWorldKind.creation:
        return text.contains('creation');
      case GalaxyWorldKind.archive:
        return text.contains('archive');
      case GalaxyWorldKind.comingSoon:
        return text.contains('coming');
    }
  }

  void _openWorld(GalaxyWorld world) {
    switch (world.kind) {
      case GalaxyWorldKind.game:
        _push(const GameWorldPage());
        return;
      case GalaxyWorldKind.music:
        _push(MusicWorldPage(title: 'MUSIC-WORLD', description: world.description));
        return;
      case GalaxyWorldKind.identity:
        _push(IdentityWorldPage(title: 'DARKEST-IDENTITY', description: world.description));
        return;
      case GalaxyWorldKind.family:
        _push(FamilyWorldPage(title: 'DARKESTFAMILY', description: world.description));
        return;
      case GalaxyWorldKind.cinema:
        _push(CinemaWorldPage(title: 'CINEMA-WORLD', description: world.description));
        return;
      case GalaxyWorldKind.creation:
        _push(BasicSectionPage(title: 'CREATION-WORLD', description: world.description));
        return;
      case GalaxyWorldKind.archive:
        _push(BasicSectionPage(title: 'ARCHIVE-WORLD', description: world.description));
        return;
      case GalaxyWorldKind.comingSoon:
        _push(BasicSectionPage(title: 'COMING SOON', description: world.description));
        return;
      case GalaxyWorldKind.vegeta:
        _push(DarkCorePage(title: 'VEGETA WORLD', description: world.description));
        return;
    }
  }

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}
