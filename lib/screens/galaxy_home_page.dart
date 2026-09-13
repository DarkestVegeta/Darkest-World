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

  void selectWorld(GalaxyWorld world) => setState(() { selected = world.kind; mapped.add(world.kind); });

  void openWorld(GalaxyWorld world) {
    setState(() { selected = world.kind; mapped.add(world.kind); visited.add(world.kind); visits++; });
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

  KeyEventResult handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.keyG) { setState(() => command = !command); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.keyG) { _commandOpen ? _closeCommand() : _openCommand(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.keyA) { setState(() => atlas = !atlas); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.escape && (atlas || command)) { setState(() { atlas = false; command = false; }); return KeyEventResult.handled; }
    return KeyEventResult.ignored;
  }

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF010207),
    body: Focus(
      autofocus: true,
      onKeyEvent: handleKey,
      child: Stack(fit: StackFit.expand, children: [
        DarkestWorldUniverse(worlds: worlds, onWorldTap: openWorld, onWorldSelect: selectWorld),
        Positioned(top: 18, left: 18, right: 18, child: Row(children: [
          const Text('GALAXY', style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 8, letterSpacing: 2.2)), const SizedBox(width: 10),
          const Text('ONLINE', style: TextStyle(color: Color(0x4DFFFFFF), fontSize: 6)), const Spacer(),
          HudButton(label: 'GATES ${worlds.length}', onTap: () => setState(() => atlas = true)), const SizedBox(width: 6),
          HudButton(label: 'ATLAS', onTap: () => setState(() => atlas = true)), const SizedBox(width: 6),
          HudButton(label: 'COMMAND', onTap: () => setState(() => command = true)),
        ])),
        Positioned(left: 18, bottom: 18, child: Info(text: selected == null ? 'SCANNING / SELECT A WORLD' : 'TARGET ${selected.toString().split('.').last.toUpperCase()} / LOCKED')),
        Positioned(right: 18, bottom: 18, child: Info(text: 'VISITS $visits / MAPPED ${mapped.length}/${worlds.length} / VISITED ${visited.length}')),
        if (atlas) Atlas(worlds: worlds, mapped: mapped, visited: visited, selected: selected, close: () => setState(() => atlas = false), open: openWorld),
        if (command) Positioned.fill(child: Material(color: const Color(0xF0020308), child: GalaxyCommandCenterPage(
          worlds: worlds, selected: selected, mapped: mapped, visited: visited,
          onOpen: (world) { setState(() => command = false); openWorld(world); },
          onClose: () => setState(() => command = false),
        ))),
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

class Atlas extends StatelessWidget {
  final List<GalaxyWorld> worlds; final Set<GalaxyWorldKind> mapped, visited; final GalaxyWorldKind? selected; final VoidCallback close; final ValueChanged<GalaxyWorld> open;
  const Atlas({super.key, required this.worlds, required this.mapped, required this.visited, required this.selected, required this.close, required this.open});
  @override Widget build(BuildContext context) {
    final columns = MediaQuery.sizeOf(context).width < 760 ? 2 : 3;
    return Positioned.fill(child: Material(color: const Color(0xF0020308), child: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
      Row(children: [const Expanded(child: Text('GALAXY ATLAS', style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 4))), HudButton(label: 'CLOSE', onTap: close)]),
      const SizedBox(height: 14),
      Expanded(child: GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.2), itemCount: worlds.length, itemBuilder: (_, index) {
        final world = worlds[index]; final active = selected == world.kind;
        return InkWell(onTap: () => open(world), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: active ? const Color(0x12FFFFFF) : const Color(0x05FFFFFF), border: Border.all(color: active ? const Color(0x66FFFFFF) : const Color(0x1AFFFFFF))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(world.title, style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 9, letterSpacing: 1.2)), const SizedBox(height: 5),
          Text(visited.contains(world.kind) ? 'VISITED / MAPPED' : mapped.contains(world.kind) ? 'MAPPED / UNVISITED' : 'UNMAPPED', style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 5)), const SizedBox(height: 5),
          Text(world.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0x4DFFFFFF), fontSize: 6)),
        ])));
      })),
    ]))));
  }
}

class _CommandButton extends StatelessWidget { final VoidCallback onTap; const _CommandButton({required this.onTap}); @override Widget build(BuildContext context) => Semantics(button: true, label: 'Open galaxy command center', child: Material(color: const Color(0xD905060D), child: InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), decoration: BoxDecoration(border: Border.all(color: Colors.white18)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('COMMAND', style: TextStyle(color: Colors.white65, fontSize: 7, letterSpacing: 1.6)), SizedBox(width: 7), Text('G', style: TextStyle(color: Colors.white25, fontSize: 6))]))))); }
