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
import 'galaxy_command_center_page.dart';

class GalaxyHomePage extends StatefulWidget {
  const GalaxyHomePage({super.key});
  @override State<GalaxyHomePage> createState() => _GalaxyHomePageState();
}

class _GalaxyHomePageState extends State<GalaxyHomePage> with WidgetsBindingObserver {
  final _repository = WorldSectionsRepository();
  late Future<List<WorldSection>> _sections;
  bool _active = true;
  bool _atlas = false;
  bool _command = false;
  int _visits = 0;
  GalaxyWorldKind? _selected;
  final Set<GalaxyWorldKind> _visited = {};

  static const worlds = <GalaxyWorld>[
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

  @override void initState() { super.initState(); _sections = _repository.load(); WidgetsBinding.instance.addObserver(this); }
  @override void dispose() { WidgetsBinding.instance.removeObserver(this); super.dispose(); }
  @override void didChangeAppLifecycleState(AppLifecycleState state) { final active = state == AppLifecycleState.resumed; if (mounted && active != _active) setState(() => _active = active); }

  List<GalaxyWorld> _mappedWorlds(List<WorldSection> source) => worlds.map((fallback) {
    for (final section in source) {
      final text = '${section.name} ${section.slug}'.toLowerCase();
      if (text.contains(fallback.title.toLowerCase().split('-').first)) return GalaxyWorld(kind: fallback.kind, title: fallback.title, description: section.description);
    }
    return fallback;
  }).toList();

  void _openWorld(GalaxyWorld world) {
    setState(() { _selected = world.kind; _visits++; _visited.add(world.kind); });
    late Widget page;
    switch (world.kind) {
      case GalaxyWorldKind.vegeta: page = DarkCorePage(title: world.title, description: world.description); break;
      case GalaxyWorldKind.game: page = const GameWorldPlanetPage(); break;
      case GalaxyWorldKind.music: page = MusicWorldPage(title: world.title, description: world.description); break;
      case GalaxyWorldKind.identity: page = IdentityWorldPage(title: world.title, description: world.description); break;
      case GalaxyWorldKind.family: page = FamilyWorldPage(title: world.title, description: world.description); break;
      case GalaxyWorldKind.cinema: page = CinemaWorldPage(title: world.title, description: world.description); break;
      case GalaxyWorldKind.creation: page = const CreationWorldPage(); break;
      case GalaxyWorldKind.archive: page = const ArchiveWorldPage(); break;
      case GalaxyWorldKind.comingSoon: page = const ComingSoonWorldPage(); break;
    }
    Navigator.of(context).push(PageRouteBuilder(pageBuilder: (_, __, ___) => page, transitionDuration: const Duration(milliseconds: 300), transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child)));
  }

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.keyG) { _commandOpen ? _closeCommand() : _openCommand(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.keyA) { setState(() => _atlas = !_atlas); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.escape && (_atlas || _command)) { setState(() { _atlas = false; _command = false; }); return KeyEventResult.handled; }
    return KeyEventResult.ignored;
  }

  @override Widget build(BuildContext context) => FutureBuilder<List<WorldSection>>(
    future: _sections,
    builder: (context, snapshot) {
      final list = _mappedWorlds(snapshot.data ?? const []);
      final compact = MediaQuery.sizeOf(context).width < 900;
      final selected = _selected == null ? null : list.where((w) => w.kind == _selected).isEmpty ? null : list.firstWhere((w) => w.kind == _selected);
      return Focus(autofocus: true, onKeyEvent: _key, child: Stack(fit: StackFit.expand, children: [
        TickerMode(enabled: _active, child: DarkestWorldUniverse(worlds: list, onWorldTap: _openWorld)),
        Positioned(top: compact ? 12 : 24, left: 12, right: 12, child: Row(children: [
          _Hud(label: 'GALAXY', value: snapshot.hasError ? 'FALLBACK' : 'ONLINE'), const Spacer(), _Hud(label: 'GATES', value: '${list.length}'), const SizedBox(width: 6), _Hud(label: 'MAPPED', value: '${_visited.length}/${list.length}'), const SizedBox(width: 6), _Action(label: 'ATLAS', onTap: () => setState(() => _atlas = true)), const SizedBox(width: 6), _Action(label: 'COMMAND', onTap: () => setState(() => _command = true)),
        ])),
        if (!compact && selected != null) Positioned(left: 24, bottom: 24, child: _Target(world: selected, visits: _visits)),
        if (!compact) Positioned(left: 24, top: 80, child: _Discovery(list: list, visited: _visited, onOpen: _openWorld)),
        Positioned(right: 12, bottom: 12, child: _Hud(label: 'VISITS', value: '$_visits')),
        if (_atlas) _Atlas(worlds: list, visited: _visited, selected: _selected, onClose: () => setState(() => _atlas = false), onOpen: _openWorld),
        if (_command) Positioned.fill(child: Material(color: const Color(0xEE020308), child: GalaxyCommandCenterPage(worlds: list, selected: _selected, visited: _visited, onOpen: (world) { setState(() => _command = false); _openWorld(world); }))),
      ]));
    },
  );
}

class _Hud extends StatelessWidget { final String label, value; const _Hud({required this.label, required this.value}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: const Color(0xB805060D), border: Border.all(color: Colors.white10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.white30, fontSize: 5, letterSpacing: 1.4)), const SizedBox(height: 2), Text(value, style: const TextStyle(color: Colors.white70, fontSize: 7, letterSpacing: 1.1))])); }
class _Action extends StatelessWidget { final String label; final VoidCallback onTap; const _Action({required this.label, required this.onTap}); @override Widget build(BuildContext context) => Semantics(button: true, label: label, child: InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9), decoration: BoxDecoration(color: const Color(0xB805060D), border: Border.all(color: Colors.white18)), child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 6, letterSpacing: 1.2))))); }
class _Discovery extends StatelessWidget { final List<GalaxyWorld> list; final Set<GalaxyWorldKind> visited; final ValueChanged<GalaxyWorld> onOpen; const _Discovery({required this.list, required this.visited, required this.onOpen}); @override Widget build(BuildContext context) { final next = list.where((w) => !visited.contains(w.kind)).take(4).toList(); return Container(width: 245, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xCC05060D), border: Border.all(color: Colors.white10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('DISCOVERY', style: TextStyle(color: Colors.white40, fontSize: 6, letterSpacing: 1.8)), const SizedBox(height: 6), Text('${visited.length}/${list.length} GATES MAPPED', style: const TextStyle(color: Colors.white70, fontSize: 8)), const SizedBox(height: 7), for (final world in next) InkWell(onTap: () => onOpen(world), child: Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [const Text('○', style: TextStyle(color: Colors.white24)), const SizedBox(width: 7), Expanded(child: Text(world.title, style: const TextStyle(color: Colors.white45, fontSize: 6))), const Text('OPEN', style: TextStyle(color: Colors.white20, fontSize: 5))]))) ])); } }
class _Target extends StatelessWidget { final GalaxyWorld world; final int visits; const _Target({required this.world, required this.visits}); @override Widget build(BuildContext context) => Container(width: 300, padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: const Color(0xD905060D), border: Border.all(color: Colors.white18)), child: Row(children: [Container(width: 3, height: 38, color: Colors.white38), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('TARGET WORLD', style: TextStyle(color: Colors.white24, fontSize: 5, letterSpacing: 1.2)), const SizedBox(height: 3), Text(world.title, style: const TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 1.1)), Text(world.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white30, fontSize: 5.5))])), Text('$visits', style: const TextStyle(color: Colors.white38, fontSize: 7))])); }
class _Atlas extends StatelessWidget { final List<GalaxyWorld> worlds; final Set<GalaxyWorldKind> visited; final GalaxyWorldKind? selected; final VoidCallback onClose; final ValueChanged<GalaxyWorld> onOpen; const _Atlas({required this.worlds, required this.visited, required this.selected, required this.onClose, required this.onOpen}); @override Widget build(BuildContext context) => Positioned.fill(child: Material(color: const Color(0xF0020308), child: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [Row(children: [const Expanded(child: Text('GALAXY ATLAS', style: TextStyle(color: Colors.white, fontSize: 19, letterSpacing: 5))), _Action(label: 'CLOSE ×', onTap: onClose)]), const SizedBox(height: 14), Expanded(child: GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: MediaQuery.sizeOf(context).width < 760 ? 2 : 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.2), itemCount: worlds.length, itemBuilder: (_, i) { final w = worlds[i]; final active = w.kind == selected; return Semantics(button: true, label: 'Open ${w.title}', child: InkWell(onTap: () => onOpen(w), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: active ? Colors.white.withOpacity(.07) : Colors.white.withOpacity(.02), border: Border.all(color: active ? Colors.white38 : Colors.white10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(w.title, style: const TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 1.2)), const SizedBox(height: 5), Text(visited.contains(w.kind) ? 'MAPPED' : 'UNMAPPED', style: const TextStyle(color: Colors.white30, fontSize: 5)), const SizedBox(height: 5), Text(w.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white30, fontSize: 6))]))); })), ]))));
}

class _CommandButton extends StatelessWidget { final VoidCallback onTap; const _CommandButton({required this.onTap}); @override Widget build(BuildContext context) => Semantics(button: true, label: 'Open galaxy command center', child: Material(color: const Color(0xD905060D), child: InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), decoration: BoxDecoration(border: Border.all(color: Colors.white18)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('COMMAND', style: TextStyle(color: Colors.white65, fontSize: 7, letterSpacing: 1.6)), SizedBox(width: 7), Text('G', style: TextStyle(color: Colors.white25, fontSize: 6))]))))); }
