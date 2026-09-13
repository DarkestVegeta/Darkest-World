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

class GalaxyHomePage extends StatefulWidget {
  const GalaxyHomePage({super.key});
  @override State<GalaxyHomePage> createState() => _GalaxyHomePageState();
}

class _GalaxyHomePageState extends State<GalaxyHomePage> {
  bool atlas = false, command = false;
  GalaxyWorldKind? selected;
  int visits = 0;
  final visited = <GalaxyWorldKind>{};
  final mapped = <GalaxyWorldKind>{};
  final discoveryOrder = <GalaxyWorldKind>[];
  final routeHistory = <GalaxyWorldKind>[];
  final gateHistory = <GalaxyWorldKind>[];

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

  GalaxyWorld _world(GalaxyWorldKind kind) => worlds.firstWhere((world) => world.kind == kind);

  void selectWorld(GalaxyWorld world) {
    setState(() {
      selected = world.kind;
      mapped.add(world.kind);
      if (!discoveryOrder.contains(world.kind)) discoveryOrder.add(world.kind);
      if (routeHistory.isEmpty || routeHistory.last != world.kind) routeHistory.add(world.kind);
      if (routeHistory.length > 16) routeHistory.removeAt(0);
    });
  }

  void openWorld(GalaxyWorld world) {
    selectWorld(world);
    setState(() {
      visited.add(world.kind);
      visits++;
      gateHistory.remove(world.kind);
      gateHistory.add(world.kind);
      if (gateHistory.length > 6) gateHistory.removeAt(0);
    });
    late final Widget page;
    switch (world.kind) {
      case GalaxyWorldKind.vegeta: page = DarkCorePage(title: 'VEGETA WORLD', description: world.description); break;
      case GalaxyWorldKind.game: page = const GameWorldPlanetPage(); break;
      case GalaxyWorldKind.music: page = MusicWorldPage(title: world.title, description: world.description); break;
      case GalaxyWorldKind.identity: page = IdentityWorldPage(title: world.title, description: world.description); break;
      case GalaxyWorldKind.family: page = FamilyWorldPage(title: world.title, description: world.description); break;
      case GalaxyWorldKind.cinema: page = CinemaWorldPage(title: world.title, description: world.description); break;
      case GalaxyWorldKind.creation: page = const CreationWorldPage(); break;
      case GalaxyWorldKind.archive: page = const ArchiveWorldPage(); break;
      case GalaxyWorldKind.comingSoon: page = const ComingSoonWorldPage(); break;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void routeMove(int delta) {
    if (selected == null) {
      selectWorld(worlds[delta < 0 ? worlds.length - 1 : 0]);
      return;
    }
    final index = worlds.indexWhere((world) => world.kind == selected);
    final next = (index + delta + worlds.length) % worlds.length;
    selectWorld(worlds[next]);
  }

  void revisitLastGate() {
    if (gateHistory.isEmpty) return;
    openWorld(_world(gateHistory.last));
  }

  KeyEventResult handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.keyG) {
      setState(() => command = !command);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyA) {
      setState(() => atlas = !atlas);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      routeMove(-1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      routeMove(1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyR) {
      revisitLastGate();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape && (atlas || command)) {
      setState(() { atlas = false; command = false; });
      return KeyEventResult.handled;
    }
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
          const Text('GALAXY', style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 8, letterSpacing: 2.2)),
          Text('ONLINE / ${mapped.length} MAPPED', style: const TextStyle(color: Color(0x4DFFFFFF), fontSize: 6)),
          const Spacer(),
          HudButton(label: 'GATES ${worlds.length}', onTap: () => setState(() => atlas = true)),
          const SizedBox(width: 6),
          HudButton(label: 'ATLAS', onTap: () => setState(() => atlas = true)),
          const SizedBox(width: 6),
          HudButton(label: 'COMMAND', onTap: () => setState(() => command = true)),
        ])),
        Positioned(left: 18, bottom: 18, child: Info(text: selected == null ? 'SCANNING / SELECT A WORLD' : 'TARGET ${selected.toString().split('.').last.toUpperCase()} / LOCKED')),
        Positioned(right: 18, bottom: 18, child: Info(text: 'VISITS $visits / MAPPED ${mapped.length}/${worlds.length} / VISITED ${visited.length} / ROUTE ${routeHistory.length}')),
        if (selected != null)
          Positioned(left: 18, bottom: 58, right: 18, child: RouteBar(
            worlds: worlds,
            selected: selected!,
            mapped: mapped,
            visited: visited,
            onPrevious: () => routeMove(-1),
            onNext: () => routeMove(1),
            onCurrent: () => openWorld(_world(selected!)),
          )),
        if (atlas) Atlas(worlds: worlds, mapped: mapped, visited: visited, selected: selected, discoveryOrder: discoveryOrder, gateHistory: gateHistory, close: () => setState(() => atlas = false), open: openWorld, revisit: revisitLastGate),
        if (command) Positioned.fill(child: Material(color: const Color(0xF0020308), child: GalaxyCommandCenterPage(
          worlds: worlds,
          selected: selected,
          mapped: mapped,
          visited: visited,
          onOpen: (world) { setState(() => command = false); openWorld(world); },
          onClose: () => setState(() => command = false),
        ))),
      ]),
    ),
  );
}

class HudButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const HudButton({super.key, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(onTap: onTap, child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    decoration: BoxDecoration(color: const Color(0xB805060D), border: Border.all(color: const Color(0x2EFFFFFF))),
    child: Text(label, style: const TextStyle(color: Color(0x8AFFFFFF), fontSize: 5.5, letterSpacing: 1)),
  )));
}

class Info extends StatelessWidget {
  final String text;
  const Info({super.key, required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(color: const Color(0xB805060D), border: Border.all(color: const Color(0x1AFFFFFF))),
    child: Text(text, style: const TextStyle(color: Color(0x59FFFFFF), fontSize: 5.5, letterSpacing: 1)),
  );
}

class RouteBar extends StatelessWidget {
  final List<GalaxyWorld> worlds;
  final GalaxyWorldKind selected;
  final Set<GalaxyWorldKind> mapped, visited;
  final VoidCallback onPrevious, onNext, onCurrent;
  const RouteBar({super.key, required this.worlds, required this.selected, required this.mapped, required this.visited, required this.onPrevious, required this.onNext, required this.onCurrent});
  @override
  Widget build(BuildContext context) {
    final index = worlds.indexWhere((world) => world.kind == selected);
    final previous = worlds[(index - 1 + worlds.length) % worlds.length];
    final current = worlds[index];
    final next = worlds[(index + 1) % worlds.length];
    return Container(height: 48, decoration: BoxDecoration(color: const Color(0xE805060D), border: Border.all(color: const Color(0x24FFFFFF))), child: Row(children: [
      RouteCell(label: 'PREVIOUS', world: previous, onTap: onPrevious),
      RouteCell(label: 'CURRENT', world: current, active: true, onTap: onCurrent),
      RouteCell(label: 'NEXT', world: next, onTap: onNext),
    ]));
  }
}

class RouteCell extends StatelessWidget {
  final String label; final GalaxyWorld world; final bool active; final VoidCallback onTap;
  const RouteCell({super.key, required this.label, required this.world, this.active = false, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(child: InkWell(onTap: onTap, child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(border: Border(right: BorderSide(color: const Color(0x1AFFFFFF))), color: active ? const Color(0x0FFFFFFF) : Colors.transparent),
    child: Row(children: [
      Text(label, style: TextStyle(color: active ? const Color(0xAAFFFFFF) : const Color(0x4DFFFFFF), fontSize: 5, letterSpacing: 1.2)),
      const SizedBox(width: 10),
      Expanded(child: Text(world.title, overflow: TextOverflow.ellipsis, style: TextStyle(color: active ? Colors.white : const Color(0x70FFFFFF), fontSize: 7, letterSpacing: 1))),
    ]),
  )));
}

class Atlas extends StatelessWidget {
  final List<GalaxyWorld> worlds;
  final Set<GalaxyWorldKind> mapped, visited;
  final GalaxyWorldKind? selected;
  final List<GalaxyWorldKind> discoveryOrder, gateHistory;
  final VoidCallback close, revisit;
  final ValueChanged<GalaxyWorld> open;
  const Atlas({super.key, required this.worlds, required this.mapped, required this.visited, required this.selected, required this.discoveryOrder, required this.gateHistory, required this.close, required this.open, required this.revisit});
  @override
  Widget build(BuildContext context) {
    final columns = MediaQuery.sizeOf(context).width < 760 ? 2 : 3;
    return Positioned.fill(child: Material(color: const Color(0xF0020308), child: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
      Row(children: [
        const Expanded(child: Text('GALAXY ATLAS', style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 4))),
        Text('${discoveryOrder.length}/${worlds.length} DISCOVERED', style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 6, letterSpacing: 1)),
        const SizedBox(width: 14),
        HudButton(label: 'LAST GATE', onTap: revisit),
        const SizedBox(width: 6),
        HudButton(label: 'CLOSE', onTap: close),
      ]),
      const SizedBox(height: 14),
      Expanded(child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.2),
        itemCount: worlds.length,
        itemBuilder: (_, index) {
          final world = worlds[index];
          final active = selected == world.kind;
          final discovery = discoveryOrder.indexOf(world.kind);
          final gate = gateHistory.indexOf(world.kind);
          final state = visited.contains(world.kind) ? 'VISITED / MAPPED' : mapped.contains(world.kind) ? 'MAPPED / UNVISITED' : 'UNMAPPED';
          return InkWell(onTap: () => open(world), child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: active ? const Color(0x12FFFFFF) : const Color(0x05FFFFFF), border: Border.all(color: active ? const Color(0x66FFFFFF) : const Color(0x1AFFFFFF))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(children: [Expanded(child: Text(world.title, style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 9, letterSpacing: 1.2))), Text(discovery < 0 ? '—' : '#${discovery + 1}', style: const TextStyle(color: Color(0x55FFFFFF), fontSize: 5))]),
              const SizedBox(height: 5),
              Text('$state${gate < 0 ? '' : ' / GATE ${gate + 1}'}', style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 5)),
              const SizedBox(height: 5),
              Text(world.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0x4DFFFFFF), fontSize: 6)),
            ]),
          ));
        },
      )),
    ])))));
  }
}
