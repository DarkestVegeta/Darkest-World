import 'package:flutter/material.dart';
import '../core/chat_scope.dart';
import '../core/content_models.dart';
import '../core/content_repository.dart';
import '../core/darkest_world_navigation_state.dart';
import '../widgets/archive_signal_telemetry_lens.dart';
import '../widgets/darkest_world_artbox.dart';
import 'chatbox.dart';

class ContentDetailPage extends StatefulWidget {
  final ContentItem item;
  const ContentDetailPage({super.key, required this.item});
  @override State<ContentDetailPage> createState() => _ContentDetailPageState();
}

class _ContentDetailPageState extends State<ContentDetailPage> with SingleTickerProviderStateMixin {
  final repository = ContentRepository();
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 70))..repeat();
  List<ContentItem> related = const [];
  TypedFranchiseNavigation? navigation;
  bool relatedLoading = true;
  bool navigationLoading = true;

  bool get external => widget.item.externalSource != null && widget.item.externalId != null;

  String? get artUrl {
    for (final key in ['transparent_artbox_url', 'artbox_url', 'public_url', 'image_url', 'artwork_url', 'cover_url']) {
      final value = widget.item.metadata[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  DarkestWorldNavigationState? get archiveState {
    final nav = navigation;
    if (nav == null) return null;
    return DarkestWorldNavigationState(
      previous: nav.previous,
      current: widget.item,
      next: nav.next,
      related: related,
      source: 'content_detail',
      entryPoint: 'detail',
      originId: widget.item.id,
    );
  }

  @override
  void initState() {
    super.initState();
    if (external) {
      relatedLoading = false;
      navigationLoading = false;
    } else {
      _loadRelated();
      _loadNavigation();
    }
  }

  @override
  void dispose() {
    clock.dispose();
    super.dispose();
  }

  Future<void> _loadRelated() async {
    try {
      final result = await repository.getRelatedContentItems(widget.item.id);
      if (!mounted) return;
      setState(() { related = result; relatedLoading = false; });
    } catch (_) {
      if (mounted) setState(() => relatedLoading = false);
    }
  }

  Future<void> _loadNavigation() async {
    try {
      final result = await repository.getTypedFranchiseNavigation(widget.item);
      if (!mounted) return;
      setState(() { navigation = result; navigationLoading = false; });
    } catch (_) {
      if (mounted) setState(() => navigationLoading = false);
    }
  }

  void _open(ContentItem item) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContentDetailPage(item: item)));

  ChatContext? get chatContext {
    if (external) return null;
    final scope = switch (widget.item.type) {
      ContentType.game => ChatScope.games,
      ContentType.movie => ChatScope.movies,
      ContentType.series => ChatScope.series,
      ContentType.unknown => null,
    };
    return scope == null ? null : ChatContext(scope: scope, contentId: widget.item.id, contentTitle: widget.item.title);
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 850;
    final state = archiveState;
    final year = widget.item.releaseYear?.toString() ?? '${widget.item.metadata['year'] ?? 'ARCHIVE'}';
    return Scaffold(
      backgroundColor: const Color(0xFF020208),
      body: AnimatedBuilder(
        animation: clock,
        builder: (_, __) => ListView(
          padding: EdgeInsets.fromLTRB(compact ? 12 : 34, 14, compact ? 12 : 34, 50),
          children: [
            Row(children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, size: 15)),
              Expanded(child: Text(widget.item.title.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, letterSpacing: 2.2))),
              Text(year, style: const TextStyle(fontSize: 7, letterSpacing: 1.3, color: Color(0x667F8AA2))),
            ]),
            const SizedBox(height: 18),
            Container(
              height: compact ? 500 : 560,
              decoration: BoxDecoration(color: const Color(0xD6070711), border: Border.all(color: const Color(0x507F70B0)), boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 35)]),
              child: compact
                  ? Column(children: [Expanded(child: DarkestWorldArtbox(imageUrl: artUrl, title: widget.item.title, phase: clock.value, compact: true)), _HeroInfo(item: widget.item, compact: true)])
                  : Row(children: [Expanded(flex: 7, child: DarkestWorldArtbox(imageUrl: artUrl, title: widget.item.title, phase: clock.value)), Expanded(flex: 5, child: _HeroInfo(item: widget.item, compact: false))]),
            ),
            const SizedBox(height: 24),
            _Panel(title: 'ARCHIVE INTEL', child: Wrap(spacing: 8, runSpacing: 8, children: [
              _Chip('TYPE', widget.item.type.name.toUpperCase()),
              if (widget.item.franchise?.isNotEmpty ?? false) _Chip('FRANCHISE', widget.item.franchise!.toUpperCase()),
              _Chip('RELEASE', year),
              _Chip('ARTBOX', artUrl == null ? 'PENDING' : 'READY'),
            ])),
            if (widget.item.description?.isNotEmpty ?? false) ...[
              const SizedBox(height: 18),
              _Panel(title: 'DESCRIPTION', child: Text(widget.item.description!, style: const TextStyle(fontSize: 10, height: 1.5, color: Color(0xAAFFFFFF)))),
            ],
            if (state != null) ...[
              const SizedBox(height: 24),
              _Panel(title: 'ARCHIVE SIGNAL', child: ArchiveSignalTelemetryLens(state: state, phase: clock.value, compact: compact, onPreviousTap: navigation?.previous == null ? null : _open, onNextTap: navigation?.next == null ? null : _open, onRelatedTap: _open)),
            ],
            const SizedBox(height: 24),
            _Panel(
              title: 'NAVIGATION',
              child: navigationLoading
                  ? const LinearProgressIndicator()
                  : navigation == null
                      ? const Text('NO FRANCHISE ORDER AVAILABLE')
                      : Row(children: [
                          Expanded(child: _NavButton(label: 'PREVIOUS', item: navigation!.previous, onTap: navigation!.previous == null ? null : () => _open(navigation!.previous!))),
                          const SizedBox(width: 8),
                          Expanded(child: _NavButton(label: 'CURRENT', item: widget.item, onTap: null, active: true)),
                          const SizedBox(width: 8),
                          Expanded(child: _NavButton(label: 'NEXT', item: navigation!.next, onTap: navigation!.next == null ? null : () => _open(navigation!.next!))),
                        ]),
            ),
            const SizedBox(height: 24),
            _Panel(
              title: 'RELATED',
              child: relatedLoading
                  ? const LinearProgressIndicator()
                  : related.isEmpty
                      ? const Text('NO RELATED WORLDS YET')
                      : Wrap(spacing: 8, runSpacing: 8, children: [for (final item in related.take(12)) ActionChip(label: Text(item.title), onPressed: () => _open(item))]),
            ),
          ],
        ),
      ),
      floatingActionButton: chatContext == null ? null : Chatbox(contextData: chatContext!),
    );
  }
}

class _HeroInfo extends StatelessWidget {
  final ContentItem item;
  final bool compact;
  const _HeroInfo({required this.item, required this.compact});
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.all(compact ? 16 : 28),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('CURRENT GAME WORLD', style: TextStyle(fontSize: 7, letterSpacing: 2.6, color: Color(0x778F82A9))),
          const SizedBox(height: 12),
          Text(item.title.toUpperCase(), maxLines: compact ? 2 : 4, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: compact ? 20 : 29, fontWeight: FontWeight.w300, height: 1.03, letterSpacing: 1.8)),
          const SizedBox(height: 16),
          Text(item.type.name.toUpperCase(), style: const TextStyle(fontSize: 7, letterSpacing: 1.8, color: Color(0x8897A8BE))),
        ]),
      );
}

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;
  const _Panel({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0x99070810), border: Border.all(color: const Color(0x287F70B0))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 7, letterSpacing: 2.1, color: Color(0x778F8AA2))), const SizedBox(height: 12), child]));
}

class _Chip extends StatelessWidget {
  final String label;
  final String value;
  const _Chip(this.label, this.value);
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: const Color(0x0C7F70B0), border: Border.all(color: const Color(0x247F70B0))), child: Text('$label  $value', style: const TextStyle(fontSize: 6.5, letterSpacing: 1.0)));
}

class _NavButton extends StatelessWidget {
  final String label;
  final ContentItem? item;
  final VoidCallback? onTap;
  final bool active;
  const _NavButton({required this.label, required this.item, required this.onTap, this.active = false});
  @override
  Widget build(BuildContext context) => OutlinedButton(onPressed: onTap, child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(children: [Text(label, style: const TextStyle(fontSize: 5.5, letterSpacing: 1.4)), const SizedBox(height: 4), Text(item?.title ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: active ? 8 : 7))])));
}
