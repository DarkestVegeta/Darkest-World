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
  @override State<GalaxyHomePage> createState() => _GalaxyHomePageState();
}

class _GalaxyHomePageState extends State<GalaxyHomePage> with WidgetsBindingObserver {
  final repository = WorldSectionsRepository();
  late Future<List<WorldSection>> sections = repository.load();
  bool _appActive = true;
  String? _lastVisited;
  int _visitCount = 0;
  GalaxyWorldKind? _commandSelection;
  final List<GalaxyWorldKind> _history = <GalaxyWorldKind>[];

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

  @override void initState() { super.initState(); WidgetsBinding.instance.addObserver(this); }
  @override void dispose() { WidgetsBinding.instance.removeObserver(this); super.dispose(); }
  @override void didChangeAppLifecycleState(AppLifecycleState state) {
    final active = state == AppLifecycleState.resumed;
    if (active != _appActive && mounted) setState(() => _appActive = active);
  }
  void _reload() { setState(() => sections = repository.load()); }

  @override Widget build(BuildContext context) {
    return FutureBuilder<List<WorldSection>>(
      future: sections,
      builder: (context, snapshot) {
        final worlds = _mapWorlds(snapshot.data ?? const []);
        final synced = snapshot.connectionState == ConnectionState.done && !snapshot.hasError;
        final compact = MediaQuery.sizeOf(context).width < 900;
        GalaxyWorld? selected;
        for (final world in worlds) { if (world.kind == _commandSelection) { selected = world; break; } }
        final recent = <GalaxyWorld>[];
        for (final kind in _history.reversed) {
          for (final world in worlds) { if (world.kind == kind) { recent.add(world); break; } }
        }
        return Stack(fit: StackFit.expand, children: [
          TickerMode(enabled: _appActive, child: DarkestWorldUniverse(worlds: worlds, onWorldTap: _openWorld)),
          Positioned(left: compact ? 12 : 30, bottom: compact ? 12 : 28, child: _GalaxyStatus(synced: synced, loading: snapshot.connectionState == ConnectionState.waiting, error: snapshot.hasError, count: worlds.length, onReload: _reload)),
          Positioned(right: compact ? 12 : 26, bottom: compact ? 12 : 28, child: _GalaxyIndex(worlds: worlds, selected: _commandSelection, loading: snapshot.connectionState == ConnectionState.waiting, compact: compact, onSelect: (world) { setState(() => _commandSelection = world.kind); _openWorld(world); })),
          if (selected != null && !compact) Positioned(left: 30, bottom: 86, child: _GalaxyCommandTarget(world: selected, onOpen: () => _openWorld(selected!))),
          if (!compact) Positioned(top: 28, left: 0, right: 0, child: Center(child: _GalaxyModeStrip(worldCount: worlds.length, synced: synced))),
          if (!compact && recent.isNotEmpty) Positioned(right: 26, top: 118, child: _GalaxyRecent(recent: recent.take(4).toList(), onSelect: (world) => setState(() => _commandSelection = world.kind))),
          if (!compact) Positioned(right: 26, top: recent.isEmpty ? 118 : 252, child: _GalaxyTelemetry(synced: synced, loading: snapshot.connectionState == ConnectionState.waiting, worldCount: worlds.length, lastVisited: _lastVisited, visitCount: _visitCount)),
        ]);
      },
    );
  }

  List<GalaxyWorld> _mapWorlds(List<WorldSection> source) => _fallback.map((fallback) {
    final matches = source.where((s) => _matches(s, fallback));
    final section = matches.isEmpty ? null : matches.first;
    return section == null ? fallback : GalaxyWorld(kind: fallback.kind, title: fallback.title, description: section.description);
  }).toList();

  bool _matches(WorldSection section, GalaxyWorld world) {
    final text = '${section.name} ${section.slug}'.toLowerCase();
    switch (world.kind) {
      case GalaxyWorldKind.vegeta: return text.contains('vegeta');
      case GalaxyWorldKind.game: return text.contains('game');
      case GalaxyWorldKind.music: return text.contains('music');
      case GalaxyWorldKind.identity: return text.contains('identity');
      case GalaxyWorldKind.family: return text.contains('family');
      case GalaxyWorldKind.cinema: return text.contains('cinema');
      case GalaxyWorldKind.creation: return text.contains('creation');
      case GalaxyWorldKind.archive: return text.contains('archive');
      case GalaxyWorldKind.comingSoon: return text.contains('coming');
    }
  }

  void _openWorld(GalaxyWorld world) {
    setState(() {
      _commandSelection = world.kind;
      _lastVisited = world.title;
      _visitCount++;
      _history.remove(world.kind);
      _history.add(world.kind);
      while (_history.length > 8) { _history.removeAt(0); }
    });
    switch (world.kind) {
      case GalaxyWorldKind.game: _push(const GameWorldPlanetPage()); return;
      case GalaxyWorldKind.music: _push(MusicWorldPage(title: 'MUSIC-WORLD', description: world.description)); return;
      case GalaxyWorldKind.identity: _push(IdentityWorldPage(title: 'DARKEST-IDENTITY', description: world.description)); return;
      case GalaxyWorldKind.family: _push(FamilyWorldPage(title: 'DARKESTFAMILY', description: world.description)); return;
      case GalaxyWorldKind.cinema: _push(CinemaWorldPage(title: 'CINEMA-WORLD', description: world.description)); return;
      case GalaxyWorldKind.creation: _push(const CreationWorldPage()); return;
      case GalaxyWorldKind.archive: _push(const ArchiveWorldPage()); return;
      case GalaxyWorldKind.comingSoon: _push(const ComingSoonWorldPage()); return;
      case GalaxyWorldKind.vegeta: _push(DarkCorePage(title: 'VEGETA WORLD', description: world.description)); return;
    }
  }

  void _push(Widget page) {
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: ScaleTransition(scale: Tween<double>(begin: .985, end: 1).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)), child: child),
      ),
    ));
  }
}

class _GalaxyStatus extends StatelessWidget {
  final bool synced, loading, error; final int count; final VoidCallback onReload;
  const _GalaxyStatus({required this.synced, required this.loading, required this.error, required this.count, required this.onReload});
  @override Widget build(BuildContext context) {
    final status = error ? 'SYNC / FALLBACK' : loading ? 'SYNC / LOADING' : synced ? 'SYNC / CONNECTED' : 'SYNC / FALLBACK';
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), decoration: BoxDecoration(color: Colors.black.withOpacity(.62), border: Border.all(color: Colors.white12)), child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: error ? Colors.redAccent : Colors.white54)), const SizedBox(width: 8),
      Text('$status  •  $count WORLDS', style: const TextStyle(color: Colors.white54, fontSize: 7, letterSpacing: 1.4)), const SizedBox(width: 8),
      InkWell(onTap: onReload, child: const Padding(padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2), child: Text('↻', style: TextStyle(color: Colors.white38, fontSize: 13)))),
    ]));
  }
}

class _GalaxyModeStrip extends StatelessWidget {
  final int worldCount; final bool synced;
  const _GalaxyModeStrip({required this.worldCount, required this.synced});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7), decoration: BoxDecoration(color: const Color(0x9905060C), border: Border.all(color: Colors.white10)), child: Row(mainAxisSize: MainAxisSize.min, children: [
    const Text('GALAXY', style: TextStyle(color: Colors.white60, fontSize: 6.5, letterSpacing: 2.2)), const SizedBox(width: 12), const Text('DEEP ORBIT', style: TextStyle(color: Colors.white24, fontSize: 5.5, letterSpacing: 1.4)), const SizedBox(width: 10), Container(width: 3, height: 3, decoration: BoxDecoration(shape: BoxShape.circle, color: synced ? Colors.white54 : Colors.white20)), const SizedBox(width: 7), Text('$worldCount GATES', style: const TextStyle(color: Colors.white24, fontSize: 5.5, letterSpacing: 1.2)),
  ]));
}

class _GalaxyRecent extends StatelessWidget {
  final List<GalaxyWorld> recent; final ValueChanged<GalaxyWorld> onSelect;
  const _GalaxyRecent({required this.recent, required this.onSelect});
  @override Widget build(BuildContext context) => Container(width: 190, padding: const EdgeInsets.fromLTRB(11, 9, 11, 10), decoration: BoxDecoration(color: const Color(0xA805060C), border: Border.all(color: Colors.white10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('RECENT GATES', style: TextStyle(color: Colors.white28, fontSize: 5.5, letterSpacing: 1.6)), const SizedBox(height: 6),
    for (var i = 0; i < recent.length; i++) InkWell(onTap: () => onSelect(recent[i]), child: Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [Text('${i + 1}'.padLeft(2, '0'), style: const TextStyle(color: Colors.white14, fontSize: 5)), const SizedBox(width: 8), Expanded(child: Text(recent[i].title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white48, fontSize: 6.2, letterSpacing: 1.0))), const Icon(Icons.chevron_right, size: 9, color: Colors.white12)]))),
  ]));
}

class _GalaxyTelemetry extends StatelessWidget {
  final bool synced, loading; final int worldCount, visitCount; final String? lastVisited;
  const _GalaxyTelemetry({required this.synced, required this.loading, required this.worldCount, required this.lastVisited, required this.visitCount});
  @override Widget build(BuildContext context) {
    final state = loading ? 'SYNCING' : synced ? 'ONLINE' : 'FALLBACK';
    return Container(width: 190, padding: const EdgeInsets.fromLTRB(11, 10, 11, 11), decoration: BoxDecoration(color: const Color(0xB805060C), border: Border.all(color: Colors.white10), boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Text('GALAXY TELEMETRY', style: TextStyle(color: Colors.white54, fontSize: 6.5, letterSpacing: 1.7)), const Spacer(), Text(state, style: const TextStyle(color: Colors.white30, fontSize: 5.5, letterSpacing: 1.1))]), const SizedBox(height: 8), Row(children: [Expanded(child: _Metric(label: 'GATES', value: '$worldCount')), Expanded(child: _Metric(label: 'VISITS', value: '$visitCount'))]), const SizedBox(height: 8), const Text('LAST GATE', style: TextStyle(color: Colors.white20, fontSize: 5.5, letterSpacing: 1.2)), const SizedBox(height: 3), Text(lastVisited?.toUpperCase() ?? 'NO GATE VISITED', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 7, letterSpacing: 1.1)),
    ]));
  }
}

class _Metric extends StatelessWidget {
  final String label, value;
  const _Metric({required this.label, required this.value});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.white20, fontSize: 5.5, letterSpacing: 1.1)), const SizedBox(height: 2), Text(value, style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.2))]);
}

class _GalaxyIndex extends StatelessWidget {
  final List<GalaxyWorld> worlds; final GalaxyWorldKind? selected; final bool loading, compact; final ValueChanged<GalaxyWorld> onSelect;
  const _GalaxyIndex({required this.worlds, required this.selected, required this.loading, required this.compact, required this.onSelect});
  @override Widget build(BuildContext context) => Container(width: compact ? 184 : 220, constraints: BoxConstraints(maxHeight: compact ? 190 : 320), padding: const EdgeInsets.fromLTRB(12, 10, 12, 11), decoration: BoxDecoration(color: const Color(0xCC05060D), border: Border.all(color: selected != null ? Colors.white24 : Colors.white10), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 24)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [const Text('GALAXY INDEX', style: TextStyle(color: Colors.white70, fontSize: 7, letterSpacing: 2.1)), const Spacer(), Text(loading ? 'SYNC' : '${worlds.length} WORLDS', style: const TextStyle(color: Colors.white24, fontSize: 5.5, letterSpacing: 1.1))]), const SizedBox(height: 7),
    for (var i = 0; i < worlds.length; i++) InkWell(onTap: () => onSelect(worlds[i]), child: AnimatedContainer(duration: const Duration(milliseconds: 160), padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), margin: const EdgeInsets.only(bottom: 1), decoration: BoxDecoration(color: selected == worlds[i].kind ? Colors.white.withOpacity(.07) : Colors.transparent, border: Border(left: BorderSide(color: selected == worlds[i].kind ? Colors.white38 : Colors.transparent, width: 1))), child: Row(children: [
      SizedBox(width: 20, child: Text('${(i + 1).toString().padLeft(2, '0')}', style: TextStyle(color: selected == worlds[i].kind ? Colors.white54 : Colors.white18, fontSize: 5.5))), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(worlds[i].title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: selected == worlds[i].kind ? Colors.white70 : Colors.white45, fontSize: 6.5, letterSpacing: 1.0)), if (!compact) Text(worlds[i].description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white16, fontSize: 5))])), const Icon(Icons.chevron_right, size: 10, color: Colors.white12),
    ]))),
  ]));
}

class _GalaxyCommandTarget extends StatelessWidget {
  final GalaxyWorld world; final VoidCallback onOpen;
  const _GalaxyCommandTarget({required this.world, required this.onOpen});
  @override Widget build(BuildContext context) => Container(width: 290, padding: const EdgeInsets.fromLTRB(13, 10, 10, 10), decoration: BoxDecoration(color: const Color(0xD905060D), border: Border.all(color: Colors.white12), boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20)]), child: Row(children: [
    Container(width: 3, height: 34, color: Colors.white38), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('TARGET WORLD', style: TextStyle(color: Colors.white24, fontSize: 5, letterSpacing: 1.6)), const SizedBox(height: 3), Text(world.title, style: const TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 1.5)), const SizedBox(height: 2), Text(world.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white30, fontSize: 5.5))])), InkWell(onTap: onOpen, child: const Padding(padding: EdgeInsets.all(7), child: Text('OPEN', style: TextStyle(color: Colors.white54, fontSize: 6, letterSpacing: 1.2)))),
  ]));
}
