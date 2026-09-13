import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/darkest_world_universe.dart';

class GalaxyCommandCenterPage extends StatefulWidget {
  final List<GalaxyWorld> worlds;
  final GalaxyWorldKind? selected;
  final Set<GalaxyWorldKind> visited;
  final ValueChanged<GalaxyWorld> onOpen;
  const GalaxyCommandCenterPage({super.key, required this.worlds, required this.selected, required this.visited, required this.onOpen});
  @override State<GalaxyCommandCenterPage> createState() => _GalaxyCommandCenterPageState();
}

class _GalaxyCommandCenterPageState extends State<GalaxyCommandCenterPage> {
  final _search = TextEditingController();
  String _filter = 'ALL';
  int _cursor = 0;

  List<GalaxyWorld> get _items {
    final q = _search.text.trim().toLowerCase();
    return widget.worlds.where((w) {
      final text = '${w.title} ${w.description}'.toLowerCase();
      final mapped = widget.visited.contains(w.kind);
      final filter = _filter == 'ALL' || (_filter == 'MAPPED' && mapped) || (_filter == 'UNMAPPED' && !mapped);
      return (q.isEmpty || text.contains(q)) && filter;
    }).toList();
  }

  @override void dispose() { _search.dispose(); super.dispose(); }
  void _move(int delta) { final items = _items; if (items.isEmpty) return; setState(() => _cursor = (_cursor + delta + items.length) % items.length); }
  void _open() { final items = _items; if (items.isNotEmpty) widget.onOpen(items[_cursor.clamp(0, items.length - 1)]); }
  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) { Navigator.of(context).pop(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown || event.logicalKey == LogicalKeyboardKey.keyJ) { _move(1); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp || event.logicalKey == LogicalKeyboardKey.keyK) { _move(-1); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.enter) { _open(); return KeyEventResult.handled; }
    return KeyEventResult.ignored;
  }

  @override Widget build(BuildContext context) {
    final items = _items;
    final compact = MediaQuery.sizeOf(context).width < 760;
    return Scaffold(
      backgroundColor: const Color(0xFF020308),
      body: SafeArea(child: Focus(autofocus: true, onKeyEvent: _key, child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 30),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('GALAXY COMMAND CENTER', style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 4.5)), SizedBox(height: 5), Text('NAVIGATION / DISCOVERY / GATE CONTROL', style: TextStyle(color: Color(0x4DFFFFFF), fontSize: 7, letterSpacing: 1.8))])),
            Text('${widget.visited.length}/${widget.worlds.length} MAPPED', style: const TextStyle(color: Color(0x59FFFFFF), fontSize: 7, letterSpacing: 1.2)),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: TextField(controller: _search, onChanged: (_) => setState(() => _cursor = 0), style: const TextStyle(color: Colors.white70, fontSize: 9), decoration: const InputDecoration(hintText: 'SEARCH GATES', hintStyle: TextStyle(color: Color(0x33FFFFFF), fontSize: 7, letterSpacing: 1.4), prefixIcon: Icon(Icons.search, color: Color(0x33FFFFFF), size: 15), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0x1AFFFFFF))), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0x40FFFFFF))))),
            const SizedBox(width: 8),
            for (final f in ['ALL', 'MAPPED', 'UNMAPPED']) Padding(padding: const EdgeInsets.only(left: 5), child: _Filter(label: f, active: _filter == f, onTap: () => setState(() { _filter = f; _cursor = 0; }))),
          ]),
          const SizedBox(height: 14),
          Expanded(child: items.isEmpty ? const Center(child: Text('NO GATES MATCH', style: TextStyle(color: Color(0x40FFFFFF), fontSize: 8, letterSpacing: 1.5))) : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: compact ? 1 : 2, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: compact ? 2.8 : 2.15),
            itemCount: items.length,
            itemBuilder: (_, index) {
              final world = items[index];
              final active = index == _cursor;
              final mapped = widget.visited.contains(world.kind);
              return Semantics(button: true, label: 'Open ${world.title}', child: InkWell(
                onTap: () { setState(() => _cursor = index); widget.onOpen(world); },
                child: AnimatedContainer(duration: const Duration(milliseconds: 140), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: active ? const Color(0x221A1D2A) : const Color(0x120A0C14), border: Border.all(color: active ? const Color(0x66FFFFFF) : const Color(0x1AFFFFFF))), child: Row(children: [
                  Text('${(widget.worlds.indexOf(world) + 1).toString().padLeft(2, '0')}', style: const TextStyle(color: Color(0x33FFFFFF), fontSize: 7)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(world.title, style: TextStyle(color: active ? Colors.white : const Color(0xA6FFFFFF), fontSize: 10, letterSpacing: 1.4)), const SizedBox(height: 5), Text(world.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0x47FFFFFF), fontSize: 6.2, height: 1.35))])),
                  Text(mapped ? 'MAPPED' : 'UNMAPPED', style: const TextStyle(color: Color(0x40FFFFFF), fontSize: 5)),
                ])),
              ));
            },
          )),
          const SizedBox(height: 10),
          Row(children: [const Text('↑ ↓ / J K  NAVIGATE', style: TextStyle(color: Color(0x2EFFFFFF), fontSize: 5.5, letterSpacing: 1.2)), const SizedBox(width: 14), const Text('ENTER  OPEN', style: TextStyle(color: Color(0x2EFFFFFF), fontSize: 5.5, letterSpacing: 1.2)), const Spacer(), Text('${items.length} VISIBLE GATES', style: const TextStyle(color: Color(0x2EFFFFFF), fontSize: 5.5, letterSpacing: 1.2))]),
        ]),
      ))),
    );
  }
}

class _Filter extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Filter({required this.label, required this.active, required this.onTap});
  @override Widget build(BuildContext context) => Semantics(button: true, label: 'Filter $label', child: InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11), decoration: BoxDecoration(color: active ? const Color(0x22FFFFFF) : Colors.transparent, border: Border.all(color: active ? const Color(0x3DFFFFFF) : const Color(0x14FFFFFF))), child: Text(label, style: TextStyle(color: active ? const Color(0x99FFFFFF) : const Color(0x3DFFFFFF), fontSize: 5.5, letterSpacing: 1)))));
}
