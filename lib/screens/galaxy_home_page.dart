import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'galaxy_navigation_session.dart';

class GalaxyHomePage extends StatefulWidget {
  const GalaxyHomePage({super.key});
  @override
  State<GalaxyHomePage> createState() => _GalaxyHomePageState();
}

class _GalaxyHomePageState extends State<GalaxyHomePage> {
  bool atlas = false;
  bool command = false;
  final session = GalaxyNavigationSession();

  static const worlds = <GalaxyWorld>[
    GalaxyWorld(kind: GalaxyWorldKind.vegeta, title: 'VEGETA', description: 'The darker heart of DarkestWorld.'),
    GalaxyWorld(kind: GalaxyWorldKind.game, title: 'GAME-WORLD', description: 'Games, platforms and marathons.'),
    GalaxyWorld(kind: GalaxyWorldKind.music, title: 'MUSIC-WORLD', description: 'Music, sound and atmosphere.'),
    GalaxyWorld(kind: GalaxyWorldKind.identity, title: 'DARKEST-IDENTITY', description: 'The identity behind DarkestWorld.'),
    GalaxyWorld(kind: GalaxyWorldKind.family, title: 'DARKESTFAMILY', description: 'Personas, people and stories.'),
    GalaxyWorld(kind: GalaxyWorldKind.cinema, title: 'CINEMA-WORLD', description: 'Films and series.'),
    GalaxyWorld(kind: GalaxyWorldKind.creation, title: 'CREATION', description: 'Art, projects and experiments.'),
    GalaxyWorld(kind: GalaxyWorldKind.archive, title: 'ARCHIVE', description: 'Things worth keeping.'),
    GalaxyWorld(kind: GalaxyWorldKind.comingSoon, title: 'COMING SOON', description: 'What DarkestWorld can become.'),
  ];

  GalaxyWorld worldFor(GalaxyWorldKind kind) => worlds.firstWhere((w) => w.kind == kind);

  void selectWorld(GalaxyWorld world) => setState(() => session.select(world.kind));

  void openWorld(GalaxyWorld world) {
    setState(() => session.visit(world.kind));
    late final Widget page;
    switch (world.kind) {
      case GalaxyWorldKind.vegeta: page = DarkCorePage(title: 'VEGETA WORLD', description: world.description);
      case GalaxyWorldKind.game: page = const GameWorldPlanetPage();
      case GalaxyWorldKind.music: page = MusicWorldPage(title: world.title, description: world.description);
      case GalaxyWorldKind.identity: page = IdentityWorldPage(title: world.title, description: world.description);
      case GalaxyWorldKind.family: page = FamilyWorldPage(title: world.title, description: world.description);
      case GalaxyWorldKind.cinema: page = CinemaWorldPage(title: world.title, description: world.description);
      case GalaxyWorldKind.creation: page = const CreationWorldPage();
      case GalaxyWorldKind.archive: page = const ArchiveWorldPage();
      case GalaxyWorldKind.comingSoon: page = const ComingSoonWorldPage();
    }
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void routeMove(int delta) {
    if (session.selected == null) {
      selectWorld(worlds[delta < 0 ? worlds.length - 1 : 0]);
      return;
    }
    final index = worlds.indexWhere((w) => w.kind == session.selected);
    selectWorld(worlds[(index + delta + worlds.length) % worlds.length]);
  }

  void historyMove(int delta) {
    setState(() => session.moveHistory(delta));
  }

  void revisitLastGate() {
    final kind = session.lastGate();
    if (kind != null) openWorld(worldFor(kind));
  }

  KeyEventResult handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.keyG) { setState(() => command = !command); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.keyA) { setState(() => atlas = !atlas); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) { routeMove(-1); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) { routeMove(1); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.keyR) { revisitLastGate(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.escape && (atlas || command)) { setState(() { atlas = false; command = false; }); return KeyEventResult.handled; }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF010207),
    body: Focus(
      autofocus: true,
      onKeyEvent: handleKey,
      child: Stack(fit: StackFit.expand, children: [
        DarkestWorldUniverse(worlds: worlds, onWorldTap: openWorld, onWorldSelect: selectWorld),
        Positioned(top: 18, left: 18, right: 18, child: Row(children: [
          const Text('GALAXY', style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 8, letterSpacing: 2.2)), const SizedBox(width: 10),
          Text('ONLINE / ${session.mapped.length} MAPPED', style: const TextStyle(color: Color(0x4DFFFFFF), fontSize: 6)), const Spacer(),
          HudButton(label: 'GATES ${worlds.length}', onTap: () => setState(() => atlas = true)), const SizedBox(width: 6),
          HudButton(label: 'ATLAS', onTap: () => setState(() => atlas = true)), const SizedBox(width: 6),
          HudButton(label: 'COMMAND', onTap: () => setState(() => command = true)),
        ])),
        Positioned(left: 18, bottom: 18, child: Info(text: session.selected == null ? 'SCANNING / SELECT A WORLD' : 'TARGET ${session.selected.toString().split('.').last.toUpperCase()} / LOCKED')),
        Positioned(right: 18, bottom: 18, child: Info(text: 'VISITS ${session.visits} / MAPPED ${session.mapped.length}/${worlds.length} / VISITED ${session.visited.length} / ROUTE ${session.routeHistory.length}')),
        if (session.selected != null) Positioned(left: 18, bottom: 58, right: 18, child: RouteBar(worlds: worlds, selected: session.selected!, onPrevious: () => routeMove(-1), onNext: () => routeMove(1), onCurrent: () => openWorld(worldFor(session.selected!)))),
        if (atlas) Atlas(worlds: worlds, mapped: session.mapped, visited: session.visited, selected: session.selected, discoveryOrder: session.discoveryOrder, gateHistory: session.gateHistory, close: () => setState(() => atlas = false), open: openWorld, revisit: revisitLastGate),
        if (command) Positioned.fill(child: Material(color: const Color(0xF0020308), child: GalaxyCommandCenterPage(worlds: worlds, selected: session.selected, mapped: session.mapped, visited: session.visited, routeHistory: session.routeHistory, onHistoryPrevious: () => historyMove(-1), onHistoryNext: () => historyMove(1), onOpen: (world) { setState(() => command = false); openWorld(world); }, onClose: () => setState(() => command = false)))),
      ]),
    ),
  );
}

class HudButton extends StatelessWidget {
  final String label; final VoidCallback onTap;
  const HudButton({super.key, required this.label, required this.onTap});
  @override Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7), decoration: BoxDecoration(color: const Color(0xB805060D), border: Border.all(color: const Color(0x2EFFFFFF))), child: Text(label, style: const TextStyle(color: Color(0x8AFFFFFF), fontSize: 5.5, letterSpacing: 1)))));
}
class Info extends StatelessWidget {
  final String text;
  const Info({super.key, required this.text});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: const Color(0xB805060D), border: Border.all(color: const Color(0x1AFFFFFF))), child: Text(text, style: const TextStyle(color: Color(0x59FFFFFF), fontSize: 5.5, letterSpacing: 1)));
}
class RouteBar extends StatelessWidget {
  final List<GalaxyWorld> worlds; final GalaxyWorldKind selected; final VoidCallback onPrevious, onNext, onCurrent;
  const RouteBar({super.key, required this.worlds, required this.selected, required this.onPrevious, required this.onNext, required this.onCurrent});
  @override Widget build(BuildContext context) {
    final i = worlds.indexWhere((w) => w.kind == selected);
    return Container(height: 48, decoration: BoxDecoration(color: const Color(0xE805060D), border: Border.all(color: const Color(0x24FFFFFF))), child: Row(children: [
      RouteCell(label: 'PREVIOUS', world: worlds[(i - 1 + worlds.length) % worlds.length], onTap: onPrevious), RouteCell(label: 'CURRENT', world: worlds[i], active: true, onTap: onCurrent), RouteCell(label: 'NEXT', world: worlds[(i + 1) % worlds.length], onTap: onNext),
    ]));
  }
}
class RouteCell extends StatelessWidget {
  final String label; final GalaxyWorld world; final bool active; final VoidCallback onTap;
  const RouteCell({super.key, required this.label, required this.world, required this.onTap, this.active = false});
  @override Widget build(BuildContext context) => Expanded(child: InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(border: const Border(right: BorderSide(color: Color(0x1AFFFFFF))), color: active ? const Color(0x0FFFFFFF) : Colors.transparent), child: Row(children: [Text(label, style: TextStyle(color: active ? const Color(0xAAFFFFFF) : const Color(0x4DFFFFFF), fontSize: 5, letterSpacing: 1.2)), const SizedBox(width: 10), Expanded(child: Text(world.title, overflow: TextOverflow.ellipsis, style: TextStyle(color: active ? Colors.white : const Color(0x70FFFFFF), fontSize: 7, letterSpacing: 1)))]))));
}
class Atlas extends StatelessWidget {
  final List<GalaxyWorld> worlds; final Set<GalaxyWorldKind> mapped, visited; final GalaxyWorldKind? selected; final List<GalaxyWorldKind> discoveryOrder, gateHistory; final VoidCallback close, revisit; final ValueChanged<GalaxyWorld> open;
  const Atlas({super.key, required this.worlds, required this.mapped, required this.visited, required this.selected, required this.discoveryOrder, required this.gateHistory, required this.close, required this.open, required this.revisit});
  @override Widget build(BuildContext context) {
    final columns = MediaQuery.sizeOf(context).width < 760 ? 2 : 3;
    return Positioned.fill(child: Material(color: const Color(0xF0020308), child: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
      Row(children: [const Expanded(child: Text('GALAXY ATLAS', style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 4))), Text('${discoveryOrder.length}/${worlds.length} DISCOVERED', style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 6, letterSpacing: 1)), const SizedBox(width: 14), HudButton(label: 'LAST GATE', onTap: revisit), const SizedBox(width: 6), HudButton(label: 'CLOSE', onTap: close)]),
      const SizedBox(height: 14),
      Expanded(child: GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.2), itemCount: worlds.length, itemBuilder: (_, index) {
        final world = worlds[index]; final active = selected == world.kind; final discovery = discoveryOrder.indexOf(world.kind); final gate = gateHistory.indexOf(world.kind); final state = visited.contains(world.kind) ? 'VISITED / MAPPED' : mapped.contains(world.kind) ? 'MAPPED / UNVISITED' : 'UNMAPPED';
        return InkWell(onTap: () => open(world), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: active ? const Color(0x12FFFFFF) : const Color(0x05FFFFFF), border: Border.all(color: active ? const Color(0x66FFFFFF) : const Color(0x1AFFFFFF))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(children: [Expanded(child: Text(world.title, style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 9, letterSpacing: 1.2))), Text(discovery < 0 ? '—' : '#${discovery + 1}', style: const TextStyle(color: Color(0x55FFFFFF), fontSize: 5))]), const SizedBox(height: 5),
          Text('$state${gate < 0 ? '' : ' / GATE ${gate + 1}'}', style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 5)), const SizedBox(height: 5), Text(world.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0x4DFFFFFF), fontSize: 6)),
        ])));
      }),
    ]))));
  }
}
