import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/darkest_world_universe.dart';

class GalaxyCommandCenterPage extends StatefulWidget {
  final List<GalaxyWorld> worlds;
  final GalaxyWorldKind? selected;
  final Set<GalaxyWorldKind> mapped;
  final Set<GalaxyWorldKind> visited;
  final List<GalaxyWorldKind> routeHistory;
  final VoidCallback onHistoryPrevious;
  final VoidCallback onHistoryNext;
  final ValueChanged<GalaxyWorld> onOpen;
  final VoidCallback onClose;
  const GalaxyCommandCenterPage({super.key, required this.worlds, required this.selected, required this.mapped, required this.visited, required this.routeHistory, required this.onHistoryPrevious, required this.onHistoryNext, required this.onOpen, required this.onClose});
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

  @override void initState() { super.initState(); _syncCursor(); }
  @override void didUpdateWidget(covariant GalaxyCommandCenterPage oldWidget) { super.didUpdateWidget(oldWidget); _syncCursor(); }
  @override void dispose() { search.dispose(); super.dispose(); }

  void _syncCursor() {
    final list = items;
    if (list.isEmpty) { cursor = 0; return; }
    if (widget.selected != null) {
      final index = list.indexWhere((w) => w.kind == widget.selected);
      if (index >= 0) { cursor = index; return; }
    }
    cursor = cursor.clamp(0, list.length - 1);
  }
  void move(int delta) { final list = items; if (list.isEmpty) return; setState(() => cursor = (cursor + delta + list.length) % list.length); }
  void openSelected() { final list = items; if (list.isNotEmpty) widget.onOpen(list[cursor.clamp(0, list.length - 1)]); }

  KeyEventResult key(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) { widget.onClose(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown || event.logicalKey == LogicalKeyboardKey.keyJ) { move(1); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp || event.logicalKey == LogicalKeyboardKey.keyK) { move(-1); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) { widget.onHistoryPrevious(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) { widget.onHistoryNext(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.enter) { openSelected(); return KeyEventResult.handled; }
    return KeyEventResult.ignored;
  }

  @override Widget build(BuildContext context) {
    final list = items;
    final compact = MediaQuery.sizeOf(context).width < 760;
    final current = list.isEmpty ? null : list[cursor.clamp(0, list.length - 1)];
    final previous = list.isEmpty ? null : list[(cursor - 1 + list.length) % list.length];
    final next = list.isEmpty ? null : list[(cursor + 1) % list.length];
    final history = widget.routeHistory.length > 8 ? widget.routeHistory.sublist(widget.routeHistory.length - 8) : widget.routeHistory;
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
              Text('${widget.visited.length} VISITED / ${widget.routeHistory.length} ROUTE EVENTS', style: const TextStyle(color: Color(0x38FFFFFF), fontSize: 5)),
            ]),
            const SizedBox(width: 12), TextButton(onPressed: widget.onClose, child: const Text('CLOSE')),
          ]),
          const SizedBox(height: 12),
          SessionRoute(history: history, selected: widget.selected, worlds: widget.worlds, onPrevious: widget.onHistoryPrevious, onNext: widget.onHistoryNext),
          const SizedBox(height: 10),
          if (current != null) Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), decoration: BoxDecoration(color: const Color(0x0CFFFFFF), border: Border.all(color: const Color(0x24FFFFFF))), child: Row(children: [
            const Text('TARGET LOCK', style: TextStyle(color: Color(0x55FFFFFF), fontSize: 5, letterSpacing: 1.4)), const SizedBox(width: 12),
            Expanded(child: Text(current.title, style: const TextStyle(color: Colors.white, fontSize: 10, letterSpacing: 1.5))),
            Text(widget.visited.contains(current.kind) ? 'VISITED' : widget.mapped.contains(current.kind) ? 'MAPPED' : 'UNMAPPED', style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 5)),
          ])),
          const SizedBox(height: 10),
          if (current != null) RouteControls(previous: previous, current: current, next: next, onPrevious: () => move(-1), onCurrent: openSelected, onNext: () => move(1)),
          const SizedBox(height: 12),
          TextField(controller: search, onChanged: (_) => setState(() { cursor = 0; _syncCursor(); }), style: const TextStyle(color: Colors.white70, fontSize: 9), decoration: const InputDecoration(hintText: 'SEARCH GATES', hintStyle: TextStyle(color: Color(0x33FFFFFF), fontSize: 7), prefixIcon: Icon(Icons.search, color: Color(0x33FFFFFF), size: 15), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0x1AFFFFFF))), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0x40FFFFFF))))),
          const SizedBox(height: 10),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
            FilterButton(label: 'ALL', active: filter == 0, onTap: () => setState(() { filter = 0; _syncCursor(); })), const SizedBox(width: 6),
            FilterButton(label: 'MAPPED', active: filter == 1, onTap: () => setState(() { filter = 1; _syncCursor(); })), const SizedBox(width: 6),
            FilterButton(label: 'UNMAPPED', active: filter == 2, onTap: () => setState(() { filter = 2; _syncCursor(); })), const SizedBox(width: 6),
            FilterButton(label: 'DISCOVERED', active: filter == 3, onTap: () => setState(() { filter = 3; _syncCursor(); })), const SizedBox(width: 6),
            FilterButton(label: 'VISITED', active: filter == 4, onTap: () => setState(() { filter = 4; _syncCursor(); })), const SizedBox(width: 12),
            Text('${list.length} VISIBLE', style: const TextStyle(color: Color(0x33FFFFFF), fontSize: 6)),
          ])),
          const SizedBox(height: 12),
          Expanded(child: list.isEmpty ? const Center(child: Text('NO GATES MATCH', style: TextStyle(color: Color(0x40FFFFFF), fontSize: 8, letterSpacing: 1.5))) : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: compact ? 1 : 2, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: compact ? 3.2 : 2.3),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final world = list[i];
              final active = i == cursor;
              final isMapped = widget.mapped.contains(world.kind);
              final isVisited = widget.visited.contains(world.kind);
              final status = isVisited ? 'VISITED / MAPPED' : isMapped ? 'MAPPED / UNVISITED' : 'UNMAPPED';
              return InkWell(onTap: () { setState(() => cursor = i); widget.onOpen(world); }, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: active ? const Color(0x221A1D2A) : const Color(0x120A0C14), border: Border.all(color: active ? const Color(0x66FFFFFF) : const Color(0x1AFFFFFF))), child: Row(children: [
                Text('${i + 1}'.padLeft(2, '0'), style: const TextStyle(color: Color(0x33FFFFFF), fontSize: 7)), const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(world.title, style: TextStyle(color: active ? Colors.white : const Color(0xA6FFFFFF), fontSize: 10, letterSpacing: 1.3)), const SizedBox(height: 5), Text(world.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0x47FFFFFF), fontSize: 6.2))])),
                Text(status, textAlign: TextAlign.right, style: TextStyle(color: isVisited ? const Color(0x70FFFFFF) : isMapped ? const Color(0x58FFFFFF) : const Color(0x30FFFFFF), fontSize: 5)),
              ])));
            },
          )),
          const SizedBox(height: 8),
          const Text('↑ ↓  TARGET LIST    ← →  ROUTE HISTORY    ENTER  OPEN TARGET    ESC  CLOSE', style: TextStyle(color: Color(0x2EFFFFFF), fontSize: 5.5, letterSpacing: 1.1)),
        ]),
      ))),
    );
  }
}

class SessionRoute extends StatelessWidget {
  final List<GalaxyWorldKind> history;
  final GalaxyWorldKind? selected;
  final List<GalaxyWorld> worlds;
  final VoidCallback onPrevious, onNext;
  const SessionRoute({super.key, required this.history, required this.selected, required this.worlds, required this.onPrevious, required this.onNext});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(color: const Color(0x080FFFFFF), border: Border.all(color: const Color(0x1AFFFFFF))),
    child: Row(children: [
      const Text('SESSION ROUTE', style: TextStyle(color: Color(0x66FFFFFF), fontSize: 5, letterSpacing: 1.3)),
      const SizedBox(width: 10),
      Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: history.asMap().entries.map((entry) {
        final world = worlds.firstWhere((w) => w.kind == entry.value);
        final active = entry.value == selected;
        return Padding(padding: const EdgeInsets.only(right: 5), child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5), decoration: BoxDecoration(color: active ? const Color(0x18FFFFFF) : Colors.transparent, border: Border.all(color: active ? const Color(0x45FFFFFF) : const Color(0x12FFFFFF))), child: Text('${entry.key + 1} ${world.title}', style: TextStyle(color: active ? Colors.white : const Color(0x55FFFFFF), fontSize: 5))));
      }).toList())),
      IconButton(onPressed: onPrevious, tooltip: 'Previous route state', icon: const Icon(Icons.chevron_left, size: 16, color: Color(0x88FFFFFF))),
      IconButton(onPressed: onNext, tooltip: 'Next route state', icon: const Icon(Icons.chevron_right, size: 16, color: Color(0x88FFFFFF))),
    ]),
  );
}

class RouteControls extends StatelessWidget {
  final GalaxyWorld? previous, current, next; final VoidCallback onPrevious, onCurrent, onNext;
  const RouteControls({super.key, required this.previous, required this.current, required this.next, required this.onPrevious, required this.onCurrent, required this.onNext});
  @override Widget build(BuildContext context) => Container(height: 48, decoration: BoxDecoration(color: const Color(0x0AFFFFFF), border: Border.all(color: const Color(0x1Fffffff))), child: Row(children: [_RouteCell(label: 'PREVIOUS', world: previous, onTap: onPrevious), _RouteCell(label: 'CURRENT', world: current, active: true, onTap: onCurrent), _RouteCell(label: 'NEXT', world: next, onTap: onNext)]));
}
class _RouteCell extends StatelessWidget {
  final String label; final GalaxyWorld? world; final bool active; final VoidCallback onTap;
  const _RouteCell({required this.label, required this.world, required this.onTap, this.active = false});
  @override Widget build(BuildContext context) => Expanded(child: InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: active ? const Color(0x12FFFFFF) : Colors.transparent, border: Border(right: BorderSide(color: const Color(0x16FFFFFF)))), child: Row(children: [Text(label, style: TextStyle(color: active ? const Color(0x99FFFFFF) : const Color(0x40FFFFFF), fontSize: 5, letterSpacing: 1)), const SizedBox(width: 8), Expanded(child: Text(world?.title ?? '—', overflow: TextOverflow.ellipsis, style: TextStyle(color: active ? Colors.white : const Color(0x66FFFFFF), fontSize: 7, letterSpacing: .8)))]))));
}
class FilterButton extends StatelessWidget {
  final String label; final bool active; final VoidCallback onTap;
  const FilterButton({super.key, required this.label, required this.active, required this.onTap});
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7), decoration: BoxDecoration(color: active ? const Color(0x22FFFFFF) : Colors.transparent, border: Border.all(color: active ? const Color(0x3DFFFFFF) : const Color(0x14FFFFFF))), child: Text(label, style: TextStyle(color: active ? const Color(0x99FFFFFF) : const Color(0x3DFFFFFF), fontSize: 5.5, letterSpacing: 1))));
}
