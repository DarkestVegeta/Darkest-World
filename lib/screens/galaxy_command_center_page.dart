import 'package:flutter/material.dart';

import '../widgets/darkest_world_universe.dart';

/// A focused navigation surface for the Galaxy.
///
/// This is intentionally UI-only: it keeps navigation cheap on low-end GPUs
/// while giving the Galaxy a dedicated command-center experience.
class GalaxyCommandCenterPage extends StatefulWidget {
  final List<GalaxyWorld> worlds;
  final GalaxyWorldKind? selected;
  final Set<GalaxyWorldKind> visited;
  final ValueChanged<GalaxyWorld> onOpen;

  const GalaxyCommandCenterPage({
    super.key,
    required this.worlds,
    required this.selected,
    required this.visited,
    required this.onOpen,
  });

  @override
  State<GalaxyCommandCenterPage> createState() => _GalaxyCommandCenterPageState();
}

class _GalaxyCommandCenterPageState extends State<GalaxyCommandCenterPage> {
  final _search = TextEditingController();
  int _cursor = 0;
  String _filter = 'ALL';

  List<GalaxyWorld> get _items {
    final q = _search.text.trim().toLowerCase();
    return widget.worlds.where((world) {
      final matchesText = q.isEmpty ||
          '${world.title} ${world.description}'.toLowerCase().contains(q);
      final mapped = widget.visited.contains(world.kind);
      final matchesFilter = _filter == 'ALL' ||
          (_filter == 'MAPPED' && mapped) ||
          (_filter == 'UNMAPPED' && !mapped);
      return matchesText && matchesFilter;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _syncCursor();
  }

  @override
  void didUpdateWidget(covariant GalaxyCommandCenterPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncCursor();
  }

  void _syncCursor() {
    final items = _items;
    if (items.isEmpty) {
      _cursor = 0;
      return;
    }
    final selectedIndex = items.indexWhere((w) => w.kind == widget.selected);
    _cursor = selectedIndex >= 0 ? selectedIndex : _cursor.clamp(0, items.length - 1);
  }

  void _move(int delta) {
    final items = _items;
    if (items.isEmpty) return;
    setState(() {
      _cursor = (_cursor + delta) % items.length;
      if (_cursor < 0) _cursor = items.length - 1;
    });
  }

  void _openCursor() {
    final items = _items;
    if (items.isNotEmpty) widget.onOpen(items[_cursor.clamp(0, items.length - 1)]);
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final mapped = widget.visited.length;
    final compact = MediaQuery.sizeOf(context).width < 760;
    return Scaffold(
      backgroundColor: const Color(0xFF020308),
      body: SafeArea(
        child: Focus(
          autofocus: true,
          onKeyEvent: (_, event) {
            if (event is! KeyDownEvent) return KeyEventResult.ignored;
            if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
                event.logicalKey == LogicalKeyboardKey.keyJ) {
              _move(1);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
                event.logicalKey == LogicalKeyboardKey.keyK) {
              _move(-1);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              _openCursor();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: Padding(
            padding: EdgeInsets.all(compact ? 14 : 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GALAXY COMMAND CENTER',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              letterSpacing: 4.5,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'NAVIGATION / DISCOVERY / GATE CONTROL',
                            style: TextStyle(
                              color: Colors.white30,
                              fontSize: 7,
                              letterSpacing: 1.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$mapped / ${widget.worlds.length} MAPPED',
                      style: const TextStyle(color: Colors.white35, fontSize: 7, letterSpacing: 1.2),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _search,
                        onChanged: (_) => setState(_syncCursor),
                        style: const TextStyle(color: Colors.white70, fontSize: 9),
                        decoration: const InputDecoration(
                          hintText: 'SEARCH GATES',
                          hintStyle: TextStyle(color: Colors.white20, fontSize: 7, letterSpacing: 1.4),
                          prefixIcon: Icon(Icons.search, color: Colors.white20, size: 15),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white25)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _Filter(label: 'ALL', active: _filter == 'ALL', onTap: () => setState(() => _filter = 'ALL')),
                    const SizedBox(width: 5),
                    _Filter(label: 'MAPPED', active: _filter == 'MAPPED', onTap: () => setState(() => _filter = 'MAPPED')),
                    const SizedBox(width: 5),
                    _Filter(label: 'UNMAPPED', active: _filter == 'UNMAPPED', onTap: () => setState(() => _filter = 'UNMAPPED')),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: items.isEmpty
                      ? const Center(child: Text('NO GATES MATCH', style: TextStyle(color: Colors.white25, fontSize: 8, letterSpacing: 1.5)))
                      : GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: compact ? 1 : 2,
                            crossAxisSpacing: 9,
                            mainAxisSpacing: 9,
                            childAspectRatio: compact ? 2.8 : 2.15,
                          ),
                          itemCount: items.length,
                          itemBuilder: (_, index) {
                            final world = items[index];
                            final active = index == _cursor;
                            final mappedGate = widget.visited.contains(world.kind);
                            return Semantics(
                              button: true,
                              label: 'Command center gate ${world.title}',
                              child: InkWell(
                                onTap: () {
                                  setState(() => _cursor = index);
                                  widget.onOpen(world);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 140),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: active ? Colors.white.withOpacity(.07) : Colors.white.withOpacity(.018),
                                    border: Border.all(color: active ? Colors.white38 : Colors.white10),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${(widget.worlds.indexOf(world) + 1).toString().padLeft(2, '0')}',
                                        style: const TextStyle(color: Colors.white20, fontSize: 7),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(world.title, style: TextStyle(color: active ? Colors.white : Colors.white65, fontSize: 10, letterSpacing: 1.4)),
                                            const SizedBox(height: 5),
                                            Text(world.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white28, fontSize: 6.2, height: 1.35)),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(mappedGate ? 'MAPPED' : 'UNMAPPED', style: const TextStyle(color: Colors.white25, fontSize: 5)),
                                          const SizedBox(height: 8),
                                          Text(active ? 'ENTER  ↵' : 'OPEN  →', style: const TextStyle(color: Colors.white35, fontSize: 5.5, letterSpacing: .8)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('↑ ↓ / J K  NAVIGATE', style: TextStyle(color: Colors.white18, fontSize: 5.5, letterSpacing: 1.2)),
                    const SizedBox(width: 14),
                    const Text('ENTER  OPEN GATE', style: TextStyle(color: Colors.white18, fontSize: 5.5, letterSpacing: 1.2)),
                    const Spacer(),
                    Text('${items.length} VISIBLE GATES', style: const TextStyle(color: Colors.white18, fontSize: 5.5, letterSpacing: 1.2)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Filter extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Filter({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Filter $label',
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11),
            decoration: BoxDecoration(
              color: active ? Colors.white.withOpacity(.06) : Colors.transparent,
              border: Border.all(color: active ? Colors.white24 : Colors.white08),
            ),
            child: Text(label, style: TextStyle(color: active ? Colors.white60 : Colors.white24, fontSize: 5.5, letterSpacing: 1)),
          ),
        ),
      );
}
