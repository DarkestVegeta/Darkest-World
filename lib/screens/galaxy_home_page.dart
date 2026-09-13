import 'package:flutter/material.dart';
import '../core/world_sections_repository.dart';
import '../widgets/darkest_world_universe.dart';
import 'archive_world_page.dart';
import 'cinema_world_page.dart';
import 'coming_soon_world_page.dart';
import 'creation_world_page.dart';
import 'dark_core_page.dart';
import 'family_world_page.dart';
import 'game_world_planet_page.dart';
import 'identity_world_page.dart';
import 'music_world_page.dart';

class GalaxyHomePage extends StatefulWidget {
  const GalaxyHomePage({super.key});
  @override
  State<GalaxyHomePage> createState() => _GalaxyHomePageState();
}

class _GalaxyHomePageState extends State<GalaxyHomePage> with WidgetsBindingObserver {
  final repository = WorldSectionsRepository();
  late Future<List<WorldSection>> sections = repository.load();
  bool _appActive = true;

  static const _fallback = <GalaxyWorld>[
    GalaxyWorld(kind: GalaxyWorldKind.vegeta, title: 'VEGETA', description: 'The darker heart of DarkestWorld.'),
    GalaxyWorld(kind: GalaxyWorldKind.game, title: 'GAME-WORLD', description: 'Games you have played and what comes next.'),
    GalaxyWorld(kind: GalaxyWorldKind.music, title: 'MUSIC-WORLD', description: 'Music, sound and the worlds they create.'),
    GalaxyWorld(kind: GalaxyWorldKind.identity, title: 'DARKEST-IDENTITY', description: 'The identity behind DarkestWorld.'),
    GalaxyWorld(kind: GalaxyWorldKind.family, title: 'DARKESTFAMILY', description: 'Personas, people and stories.'),
    GalaxyWorld(kind: GalaxyWorldKind.cinema, title: 'CINEMA-WORLD', description: 'Films and series.'),
    GalaxyWorld(kind: GalaxyWorldKind.creation, title: 'CREATION', description: 'Art, projects and experiments.'),
    GalaxyWorld(kind: GalaxyWorldKind.archive, title: 'ARCHIVE', description: 'Things worth keeping.'),
    GalaxyWorld(kind: GalaxyWorldKind.comingSoon, title: 'COMING SOON', description: 'What DarkestWorld can become.'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final active = state == AppLifecycleState.resumed;
    if (active != _appActive && mounted) setState(() => _appActive = active);
  }

  void _reload() {
    setState(() => sections = repository.load());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WorldSection>>(
      future: sections,
      builder: (context, snapshot) {
        final worlds = _mapWorlds(snapshot.data ?? const []);
        final synced = snapshot.connectionState == ConnectionState.done && !snapshot.hasError;
        return Stack(
          fit: StackFit.expand,
          children: [
            TickerMode(
              enabled: _appActive,
              child: DarkestWorldUniverse(
                worlds: worlds,
                onWorldTap: _openWorld,
              ),
            ),
            Positioned(
              left: 30,
              bottom: 28,
              child: _GalaxyStatus(
                synced: synced,
                loading: snapshot.connectionState == ConnectionState.waiting,
                error: snapshot.hasError,
                count: worlds.length,
                onReload: _reload,
              ),
            ),
          ],
        );
      },
    );
  }

  List<GalaxyWorld> _mapWorlds(List<WorldSection> source) {
    return _fallback.map((fallback) {
      final matches = source.where((s) => _matches(s, fallback));
      final section = matches.isEmpty ? null : matches.first;
      if (section == null) return fallback;
      return GalaxyWorld(
        kind: fallback.kind,
        title: fallback.title,
        description: section.description,
      );
    }).toList();
  }

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
        _push(const GameWorldPlanetPage());
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
        _push(const CreationWorldPage());
        return;
      case GalaxyWorldKind.archive:
        _push(const ArchiveWorldPage());
        return;
      case GalaxyWorldKind.comingSoon:
        _push(const ComingSoonWorldPage());
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

class _GalaxyStatus extends StatelessWidget {
  final bool synced;
  final bool loading;
  final bool error;
  final int count;
  final VoidCallback onReload;

  const _GalaxyStatus({
    required this.synced,
    required this.loading,
    required this.error,
    required this.count,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final status = error
        ? 'SYNC / FALLBACK'
        : loading
            ? 'SYNC / LOADING'
            : synced
                ? 'SYNC / CONNECTED'
                : 'SYNC / FALLBACK';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.62),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: error ? Colors.redAccent : Colors.white54)),
          const SizedBox(width: 8),
          Text('$status  •  $count WORLDS', style: const TextStyle(color: Colors.white54, fontSize: 7, letterSpacing: 1.4)),
          const SizedBox(width: 8),
          InkWell(
            onTap: onReload,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: Text('↻', style: TextStyle(color: Colors.white38, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
