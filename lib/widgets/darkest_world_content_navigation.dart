import 'package:flutter/material.dart';

import '../core/content_models.dart';
import '../core/darkest_world_navigation_state.dart';
import '../screens/content_detail_page.dart';
import '../screens/galaxy_navigation_session.dart';

/// Global projection of the shared content navigation contract.
/// Route mechanics remain owned by Navigator; this widget only exposes the
/// active content snapshot consistently across archive/world surfaces.
class DarkestWorldContentNavigation extends StatelessWidget {
  const DarkestWorldContentNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GalaxyNavigationSession.instance,
      builder: (context, _) {
        final state = GalaxyNavigationSession.instance.contentNavigation;
        if (state == null) return const SizedBox.shrink();
        final compact = MediaQuery.sizeOf(context).width < 760;
        return Positioned(
          left: compact ? 10 : 28,
          right: compact ? 10 : 28,
          bottom: compact ? 104 : 116,
          child: _ContentRibbon(state: state, compact: compact),
        );
      },
    );
  }
}

class _ContentRibbon extends StatelessWidget {
  final DarkestWorldNavigationState state;
  final bool compact;
  const _ContentRibbon({required this.state, required this.compact});

  void _open(BuildContext context, ContentItem item) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContentDetailPage(item: item)));
  }

  void _showRelated(BuildContext context) {
    if (state.related.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xF0070810),
      barrierColor: const Color(0xB8000005),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('RELATED WORLDS', style: TextStyle(fontSize: 8, letterSpacing: 2.2, color: Color(0xAAFFFFFF))),
              const SizedBox(height: 12),
              ...state.related.take(8).map((item) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.link, size: 14, color: Color(0x778F82A9)),
                    title: Text(item.title, style: const TextStyle(fontSize: 9, color: Color(0xCCFFFFFF))),
                    onTap: () {
                      Navigator.of(context).pop();
                      _open(context, item);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = state.current;
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1180),
        decoration: BoxDecoration(
          color: const Color(0xF0070810),
          border: Border.all(color: const Color(0x327F70B0)),
          boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 26, spreadRadius: 1)],
        ),
        padding: EdgeInsets.symmetric(horizontal: compact ? 9 : 14, vertical: compact ? 8 : 10),
        child: compact
            ? _CompactContent(state: state, current: current, onOpen: (item) => _open(context, item), onRelated: () => _showRelated(context))
            : Row(
                children: [
                  const _Label('CONTENT NAVIGATION'),
                  const SizedBox(width: 14),
                  Expanded(child: _Slot(label: 'PREVIOUS', item: state.previous, onTap: state.previous == null ? null : () => _open(context, state.previous!))),
                  const SizedBox(width: 8),
                  Expanded(flex: 2, child: _Slot(label: 'CURRENT', item: current, active: true, onTap: () => _open(context, current))),
                  const SizedBox(width: 8),
                  Expanded(child: _Slot(label: 'NEXT', item: state.next, onTap: state.next == null ? null : () => _open(context, state.next!))),
                  if (state.related.isNotEmpty) ...[
                    const SizedBox(width: 14),
                    _RelatedCount(count: state.related.length, onTap: () => _showRelated(context)),
                  ],
                ],
              ),
      ),
    );
  }
}

class _CompactContent extends StatelessWidget {
  final DarkestWorldNavigationState state;
  final ContentItem current;
  final ValueChanged<ContentItem> onOpen;
  final VoidCallback onRelated;
  const _CompactContent({required this.state, required this.current, required this.onOpen, required this.onRelated});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const _Label('NAV'),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () => onOpen(current),
              child: Text(current.title.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 7, letterSpacing: 1.2, color: Color(0xCCFFFFFF))),
            ),
          ),
          if (state.previous != null) _Direction('←', () => onOpen(state.previous!)),
          if (state.next != null) _Direction('→', () => onOpen(state.next!)),
          if (state.related.isNotEmpty) _RelatedCount(count: state.related.length, onTap: onRelated),
        ],
      );
}

class _Slot extends StatelessWidget {
  final String label;
  final ContentItem? item;
  final bool active;
  final VoidCallback? onTap;
  const _Slot({required this.label, required this.item, this.active = false, this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            decoration: BoxDecoration(
              color: active ? const Color(0x18151A2D) : const Color(0x0BFFFFFF),
              border: Border.all(color: active ? const Color(0x5B8A78B5) : const Color(0x187F70B0)),
            ),
            child: Row(
              children: [
                Text(label, style: const TextStyle(fontSize: 4.5, letterSpacing: 1.5, color: Color(0x557F8AA2))),
                const SizedBox(width: 8),
                Expanded(child: Text(item?.title ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: active ? 7 : 6, letterSpacing: .7, color: item == null ? const Color(0x3DFFFFFF) : const Color(0xBBFFFFFF)))),
              ],
            ),
          ),
        ),
      );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 5, letterSpacing: 1.7, color: Color(0x667F8AA2)));
}

class _Direction extends StatelessWidget {
  final String value;
  final VoidCallback onTap;
  const _Direction(this.value, this.onTap);
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.only(left: 7), child: Text(value, style: const TextStyle(fontSize: 10, color: Color(0x778F82A9))));
}

class _RelatedCount extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _RelatedCount({required this.count, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          decoration: BoxDecoration(color: const Color(0x101F163B), border: Border.all(color: const Color(0x287F70B0))),
          child: Text('RELATED $count', style: const TextStyle(fontSize: 4.5, letterSpacing: 1.2, color: Color(0x778F82A9))),
        ),
      );
}
