import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/darkest_world_universe.dart';

class GalaxyCommandCenterPage extends StatefulWidget {
  final List<GalaxyWorld> worlds;
  final GalaxyWorldKind? selected;
  final Set<GalaxyWorldKind> mapped;
  final Set<GalaxyWorldKind> visited;
  final ValueChanged<GalaxyWorld> onOpen;
  final VoidCallback onClose;
  const GalaxyCommandCenterPage({super.key, required this.worlds, required this.selected, required this.mapped, required this.visited, required this.onOpen, required this.onClose});
  @override State<GalaxyCommandCenterPage> createState() => _GalaxyCommandCenterPageState();
}

class _GalaxyCommandCenterPageState extends State<GalaxyCommandCenterPage> {
  final search = TextEditingController();
  int filter = 0;
  int cursor = 0;
  List<GalaxyWorld> get items {
    final q = search.text.trim().toLowerCase();
    return widget.worlds.where((w) {
      final isMapped = widget.mapped.contains(w.kind);
      final isVisited = widget.visited.contains(w.kind);
      final filterOk = filter == 0 || (filter == 1 && isMapped) || (filter == 2 && !isMapped) || (filter == 3 && isMapped && !isVisited) || (filter == 4 && isVisited);
      final text = '${w.title} ${w.description}'.toLowerCase();
      return filterOk && (q.isEmpty || text.contains(q));
    }).toList();
  }
  @override void dispose() { search.dispose(); super.dispose(); }
  void move(int delta) { final list = items; if (list.isEmpty) return; setState(() => cursor = (cursor + delta + list.length) % list.length); }
  void openSelected() { final list = items; if (list.isNotEmpty) widget.onOpen(list[cursor.clamp(0, list.length - 1)]); }
  KeyEventResult key(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) { widget.onClose(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown || event.logicalKey == LogicalKeyboardKey.keyJ) { move(1); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp || event.logicalKey == LogicalKeyboardKey.keyK) { move(-1); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) { widget.onClose(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.enter) { openSelected(); return KeyEventResult.handled; }
    return KeyEventResult.ignored;
  }
  @override Widget build(BuildContext context) {
    final list = items;
    final compact = MediaQuery.sizeOf(context).width < 760;
    return Scaffold(
      backgroundColor: const Color(0xFF020308),
      body: SafeArea(child: Focus(autofocus: true, onKeyEvent: key, child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('GALAXY COMMAND CENTER', style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 4)),
              SizedBox(height: 5), Text('NAVIGATION / DISCOVERY / GATE CONTROL', style: TextStyle(color: Color(0x4DFFFFFF), fontSize: 7, letterSpacing: 1.5)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${widget.mapped.length}/${widget.worlds.length} MAPPED', style: const TextStyle(color: Color(0x59FFFFFF), fontSize: 7)),
              Text('${widget.visited.length} VISITED', style: const TextStyle(color: Color(0x38FFFFFF), fontSize: 5)),
            ]),
            const SizedBox(width: 12), TextButton(onPressed: widget.onClose, child: const Text('CLOSE')),
          ]),
          const SizedBox(height: 16),
          TextField(controller: search, onChanged: (_) => setState(() => cursor = 0), style: const TextStyle(color: Colors.white70, fontSize: 9), decoration: const InputDecoration(hintText: 'SEARCH GATES', hintStyle: TextStyle(color: Color(0x33FFFFFF), fontSize: 7), prefixIcon: Icon(Icons.search, color: Color(0x33FFFFFF), size: 15), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0x1AFFFFFF))), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0x40FFFFFF))))),
          const SizedBox(height: 10),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
            FilterButton(label: 'ALL', active: filter == 0, onTap: () => setState(() { filter = 0; cursor = 0; })),
            const SizedBox(width: 6), FilterButton(label: 'MAPPED', active: filter == 1, onTap: () => setState(() { filter = 1; cursor = 0; })),
            const SizedBox(width: 6), FilterButton(label: 'UNMAPPED', active: filter == 2, onTap: () => setState(() { filter = 2; cursor = 0; })),
            const SizedBox(width: 6), FilterButton(label: 'DISCOVERED', active: filter == 3, onTap: () => setState(() { filter = 3; cursor = 0; })),
            const SizedBox(width: 6), FilterButton(label: 'VISITED', active: filter == 4, onTap: () => setState(() { filter = 4; cursor = 0; })),
            const SizedBox(width: 12), Text('${list.length} VISIBLE', style: const TextStyle(color: Color(0x33FFFFFF), fontSize: 6)),
          ])),
          const SizedBox(height: 12),
          Expanded(child: list.isEmpty ? const Center(child: Text('NO GATES MATCH', style: TextStyle(color: Color(0x40FFFFFF), fontSize: 8, letterSpacing: 1.5))) : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: compact ? 1 : 2, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: compact ? 3.2 : 2.3),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final world = list[i]; final active = i == cursor; final isMapped = widget.mapped.contains(world.kind); final isVisited = widget.visited.contains(world.kind);
              final status = isVisited ? 'VISITED / MAPPED' : isMapped ? 'MAPPED / UNVISITED' : 'UNMAPPED';
              return InkWell(onTap: () => widget.onOpen(world), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: active ? const Color(0x221A1D2A) : const Color(0x120A0C14), border: Border.all(color: active ? const Color(0x66FFFFFF) : const Color(0x1AFFFFFF))), child: Row(children: [
                Text('${i + 1}'.padLeft(2, '0'), style: const TextStyle(color: Color(0x33FFFFFF), fontSize: 7)), const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(world.title, style: TextStyle(color: active ? Colors.white : const Color(0xA6FFFFFF), fontSize: 10, letterSpacing: 1.3)), const SizedBox(height: 5), Text(world.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0x47FFFFFF), fontSize: 6.2))])),
                Text(status, textAlign: TextAlign.right, style: TextStyle(color: isVisited ? const Color(0x70FFFFFF) : isMapped ? const Color(0x58FFFFFF) : const Color(0x30FFFFFF), fontSize: 5)),
              ])));
            },
          )),
          const SizedBox(height: 8),
          const Text('↑ ↓ / J K  NAVIGATE    ENTER  OPEN    ←  RETURN    ESC  CLOSE', style: TextStyle(color: Color(0x2EFFFFFF), fontSize: 5.5, letterSpacing: 1.1)),
        ]),
      ))),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label; final bool active; final VoidCallback onTap;
  const FilterButton({super.key, required this.label, required this.active, required this.onTap});
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7), decoration: BoxDecoration(color: active ? const Color(0x22FFFFFF) : Colors.transparent, border: Border.all(color: active ? const Color(0x3DFFFFFF) : const Color(0x14FFFFFF))), child: Text(label, style: TextStyle(color: active ? const Color(0x99FFFFFF) : const Color(0x3DFFFFFF), fontSize: 5.5, letterSpacing: 1))));
}
