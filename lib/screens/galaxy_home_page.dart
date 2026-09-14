import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'galaxy_navigation_session.dart';

class GalaxyHomePage extends StatefulWidget {
  const GalaxyHomePage({super.key});
  @override State<GalaxyHomePage> createState() => _GalaxyHomePageState();
}

class _GalaxyHomePageState extends State<GalaxyHomePage> {
  final repository = WorldSectionsRepository();
  late Future<List<WorldSection>> sections = repository.load();
  final session = GalaxyNavigationSession.instance;
  bool atlasOpen = false;

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

  void _select(GalaxyWorld world) => session.select(world.kind);

  void _moveRoute(int delta, List<GalaxyWorld> worlds) {
    if (session.targetLocked) return;
    if (session.selected == null) {
      _select(worlds[delta < 0 ? worlds.length - 1 : 0]);
      return;
    }
    final index = worlds.indexWhere((w) => w.kind == session.selected);
    _select(worlds[(index + delta + worlds.length) % worlds.length]);
  }

  void _openSelected(List<GalaxyWorld> worlds) {
    final kind = session.selected;
    if (kind == null) return;
    _openWorld(worlds.firstWhere((w) => w.kind == kind));
  }

  void _openWorld(GalaxyWorld world) {
    session.visit(world.kind);
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

  void _push(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  KeyEventResult _handleKey(FocusNode node, KeyEvent event, List<GalaxyWorld> worlds) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) { _moveRoute(-1, worlds); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) { _moveRoute(1, worlds); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.keyL) { session.toggleTargetLock(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.keyM) { setState(() => atlasOpen = !atlasOpen); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.escape && atlasOpen) { setState(() => atlasOpen = false); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.enter) { _openSelected(worlds); return KeyEventResult.handled; }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    session.removeListener(_sessionChanged);
    super.dispose();
  }

  void _sessionChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    session.addListener(_sessionChanged);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<WorldSection>>(
        future: sections,
        builder: (context, snapshot) {
          final worlds = _mapWorlds(snapshot.data ?? const []);
          return Scaffold(
            backgroundColor: const Color(0xFF010107),
            body: Focus(
              autofocus: true,
              onKeyEvent: (node, event) => _handleKey(node, event, worlds),
              child: Stack(fit: StackFit.expand, children: [
                DarkestWorldUniverse(worlds: worlds, onWorldTap: _openWorld),
                Positioned(top: 16, left: 16, right: 16, child: _GalaxyStatus(session: session, onAtlas: () => setState(() => atlasOpen = !atlasOpen))),
                if (session.selected != null)
                  Positioned(left: 16, right: 16, bottom: 16, child: _RouteBar(
                    worlds: worlds, selected: session.selected!, locked: session.targetLocked,
                    onPrevious: () => _moveRoute(-1, worlds), onCurrent: () => _openSelected(worlds), onNext: () => _moveRoute(1, worlds),
                    onLock: session.toggleTargetLock,
                  )),
                if (atlasOpen)
                  Positioned(top: 54, right: 16, bottom: session.selected == null ? 16 : 76, width: 360, child: _GalaxyAtlas(
                    worlds: worlds,
                    session: session,
                    onSelect: _select,
                    onVisit: _openWorld,
                  )),
              ]),
            ),
          );
        },
      );
}

class _GalaxyStatus extends StatelessWidget {
  final GalaxyNavigationSession session;
  final VoidCallback onAtlas;
  const _GalaxyStatus({required this.session, required this.onAtlas});
  @override Widget build(BuildContext context) => Row(children: [
        const Text('GALAXY', style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 8, letterSpacing: 2.2)), const SizedBox(width: 10),
        Text(session.selected == null ? 'SCANNING' : session.targetLocked ? 'TARGET LOCKED' : 'TARGET FOCUSED', style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 6, letterSpacing: 1)),
        const Spacer(), _TinyInfo(text: 'MAPPED ${session.mapped.length}'), const SizedBox(width: 6), _TinyInfo(text: 'VISITED ${session.visited.length}'), const SizedBox(width: 6), _TinyInfo(text: 'ROUTE ${session.routeHistory.length}'), const SizedBox(width: 6),
        InkWell(onTap: onAtlas, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xB805060D), border: Border.all(color: const Color(0x2AFFFFFF))), child: const Text('ATLAS  M', style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 5.5, letterSpacing: 1.2)))),
      ]);
}

class _TinyInfo extends StatelessWidget {
  final String text;
  const _TinyInfo({required this.text});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: const Color(0xB805060D), border: Border.all(color: const Color(0x1AFFFFFF))), child: Text(text, style: const TextStyle(color: Color(0x59FFFFFF), fontSize: 5, letterSpacing: 1)));
}

class _RouteBar extends StatelessWidget {
  final List<GalaxyWorld> worlds; final GalaxyWorldKind selected; final bool locked;
  final VoidCallback onPrevious, onCurrent, onNext, onLock;
  const _RouteBar({required this.worlds, required this.selected, required this.locked, required this.onPrevious, required this.onCurrent, required this.onNext, required this.onLock});
  @override Widget build(BuildContext context) {
    final i = worlds.indexWhere((w) => w.kind == selected);
    return Container(height: 48, decoration: BoxDecoration(color: const Color(0xE805060D), border: Border.all(color: const Color(0x24FFFFFF))), child: Row(children: [
      _RouteCell(label: 'PREVIOUS', world: worlds[(i - 1 + worlds.length) % worlds.length], onTap: onPrevious),
      _RouteCell(label: 'CURRENT', world: worlds[i], active: true, onTap: onCurrent),
      _RouteCell(label: 'NEXT', world: worlds[(i + 1) % worlds.length], onTap: onNext),
      InkWell(onTap: onLock, child: Container(width: 92, alignment: Alignment.center, decoration: const BoxDecoration(border: Border(left: BorderSide(color: Color(0x1AFFFFFF)))), child: Text(locked ? 'UNLOCK L' : 'LOCK L', style: TextStyle(color: locked ? const Color(0xAAFFFFFF) : const Color(0x59FFFFFF), fontSize: 5.5, letterSpacing: 1)))),
    ]));
  }
}

class _RouteCell extends StatelessWidget {
  final String label; final GalaxyWorld world; final bool active; final VoidCallback onTap;
  const _RouteCell({required this.label, required this.world, required this.onTap, this.active = false});
  @override Widget build(BuildContext context) => Expanded(child: InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: active ? const Color(0x0FFFFFFF) : Colors.transparent, border: const Border(right: BorderSide(color: Color(0x1AFFFFFF)))), child: Row(children: [
        Text(label, style: TextStyle(color: active ? const Color(0xAAFFFFFF) : const Color(0x4DFFFFFF), fontSize: 5, letterSpacing: 1.2)), const SizedBox(width: 10), Expanded(child: Text(world.title, overflow: TextOverflow.ellipsis, style: TextStyle(color: active ? Colors.white : const Color(0x70FFFFFF), fontSize: 7, letterSpacing: 1))),
      ]))));
}

class _GalaxyAtlas extends StatelessWidget {
  final List<GalaxyWorld> worlds;
  final GalaxyNavigationSession session;
  final ValueChanged<GalaxyWorld> onSelect;
  final ValueChanged<GalaxyWorld> onVisit;

  const _GalaxyAtlas({required this.worlds, required this.session, required this.onSelect, required this.onVisit});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xF0080910),
          border: Border.all(color: const Color(0x30FFFFFF)),
          boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 36)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(children: [
              const Expanded(child: Text('GALAXY ATLAS', style: TextStyle(color: Colors.white, fontSize: 9, letterSpacing: 2.2))),
              Text('${session.mapped.length}/${worlds.length} MAPPED', style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 5.5, letterSpacing: 1)),
            ]),
          ),
          const Divider(height: 1, color: Color(0x18FFFFFF)),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: worlds.length,
            itemBuilder: (context, index) {
              final world = worlds[index];
              final selected = world.kind == session.selected;
              final mapped = session.isMapped(world.kind);
              final visited = session.isVisited(world.kind);
              final number = session.discoveryIndex(world.kind);
              return InkWell(
                onTap: () => onSelect(world),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0x16FFFFFF) : Colors.transparent,
                    border: Border.all(color: selected ? const Color(0x35FFFFFF) : const Color(0x0FFFFFFF)),
                  ),
                  child: Row(children: [
                    SizedBox(width: 28, child: Text(mapped ? '#${number.toString().padLeft(2, '0')}' : '—', style: TextStyle(color: mapped ? const Color(0x99FFFFFF) : const Color(0x38FFFFFF), fontSize: 6, letterSpacing: 1))),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(world.title, style: TextStyle(color: selected ? Colors.white : const Color(0xB3FFFFFF), fontSize: 7, letterSpacing: 1.1)),
                      const SizedBox(height: 3),
                      Text(world.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0x4DFFFFFF), fontSize: 5.5)),
                    ])),
                    const SizedBox(width: 8),
                    Text(visited ? 'VISITED' : mapped ? 'MAPPED' : 'UNKNOWN', style: TextStyle(color: visited ? const Color(0xAAFFFFFF) : mapped ? const Color(0x70FFFFFF) : const Color(0x38FFFFFF), fontSize: 5, letterSpacing: 1)),
                    const SizedBox(width: 8),
                    if (selected) InkWell(onTap: () => onVisit(world), child: const Text('ENTER', style: TextStyle(color: Colors.white, fontSize: 5.5, letterSpacing: 1))),
                  ]),
                ),
              );
            },
          )),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x18FFFFFF)))),
            child: Row(children: [
              const Expanded(child: Text('M = ATLAS   L = TARGET LOCK   ENTER = VISIT', style: TextStyle(color: Color(0x45FFFFFF), fontSize: 5, letterSpacing: .8))),
              Text('GATES ${session.gateHistory.length}', style: const TextStyle(color: Color(0x45FFFFFF), fontSize: 5, letterSpacing: 1)),
            ]),
          ),
        ]),
      ),
    );
  }
}
