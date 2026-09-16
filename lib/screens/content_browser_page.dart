import 'package:flutter/material.dart';
import '../core/content_models.dart';
import '../core/content_repository.dart';
import '../core/darkest_world_navigation_state.dart';
import '../core/supabase_client.dart';
import 'content_detail_page.dart';
import 'galaxy_navigation_session.dart';

class ContentBrowserPage extends StatefulWidget {
  final String? contentType;
  final String title;
  final List<int> platformIds;
  const ContentBrowserPage({super.key, required this.title, this.contentType, this.platformIds = const []});
  @override State<ContentBrowserPage> createState() => _ContentBrowserPageState();
}

class _ContentBrowserPageState extends State<ContentBrowserPage> {
  final repository = ContentRepository();
  final navigation = GalaxyNavigationSession.instance;
  final items = <ContentItem>[];
  bool loading = true;
  String query = '';
  int selected = 0;

  bool get snes => widget.contentType == 'game' && (widget.platformIds.contains(19) || widget.title.toUpperCase().contains('SNES'));
  List<ContentItem> get visible => items.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList(growable: false);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      List<ContentItem> result;
      if (snes) {
        final rows = await supabase.from('storage_assets').select('id,title,public_url,metadata').eq('asset_type', 'snes_sealed').not('public_url', 'is', null).neq('public_url', '').order('title').limit(1000);
        result = [for (final row in rows) _asset(Map<String, dynamic>.from(row))];
      } else {
        result = await repository.getContentItemsPage(type: widget.contentType, page: 0);
      }
      if (!mounted) return;
      setState(() {
        items
          ..clear()
          ..addAll(result);
        loading = false;
        selected = 0;
      });
      _publish();
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  ContentItem _asset(Map<String, dynamic> row) {
    final metadata = row['metadata'] is Map ? Map<String, dynamic>.from(row['metadata']) : <String, dynamic>{};
    metadata['public_url'] = row['public_url'];
    return ContentItem.fromRow({
      'id': 'snes:${row['id']}',
      'content_type': 'game',
      'title': '${row['title'] ?? 'Untitled'}',
      'slug': 'snes-${row['id']}',
      'metadata': metadata,
    });
  }

  void _publish() {
    final list = visible;
    if (list.isEmpty) {
      navigation.clearContentNavigation();
      return;
    }
    selected = selected.clamp(0, list.length - 1);
    navigation.publishContentNavigation(DarkestWorldNavigationState(
      previous: selected > 0 ? list[selected - 1] : null,
      current: list[selected],
      next: selected + 1 < list.length ? list[selected + 1] : null,
      related: const [],
      source: 'archive',
      entryPoint: 'archive_browser',
    ));
  }

  void _select(int index) {
    if (visible.isEmpty) return;
    setState(() => selected = index.clamp(0, visible.length - 1));
    _publish();
  }

  void _open(ContentItem item) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContentDetailPage(item: item)));

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 850;
    final list = visible;
    return Scaffold(
      backgroundColor: const Color(0xFF020208),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 28),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, size: 15)),
                  Expanded(child: Text(widget.title.toUpperCase(), style: const TextStyle(fontSize: 13, letterSpacing: 2.4))),
                  SizedBox(
                    width: compact ? 150 : 280,
                    height: 36,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          query = value;
                          selected = 0;
                        });
                        _publish();
                      },
                      decoration: const InputDecoration(hintText: 'SEARCH ARCHIVE', prefixIcon: Icon(Icons.search, size: 15), filled: true, fillColor: Color(0x660A0B14)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : list.isEmpty
                        ? const Center(child: Text('GEEN CONTENT', style: TextStyle(letterSpacing: 3)))
                        : GridView.builder(
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: compact ? 180 : 230,
                              mainAxisExtent: compact ? 250 : 300,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: list.length,
                            itemBuilder: (_, index) {
                              final item = list[index];
                              final active = index == selected;
                              final url = '${item.metadata['public_url'] ?? item.metadata['image_url'] ?? ''}';
                              return InkWell(
                                onTap: () => _select(index),
                                onDoubleTap: () => _open(item),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: active ? const Color(0xE50B0A16) : const Color(0xB9070810),
                                    border: Border.all(color: active ? const Color(0x8F8A78B5) : const Color(0x247F70B0)),
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: url.isEmpty
                                            ? Center(child: Text(item.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, letterSpacing: 1.2)))
                                            : Image.network(url, fit: BoxFit.contain, filterQuality: FilterQuality.high, errorBuilder: (_, __, ___) => Center(child: Text(item.title, textAlign: TextAlign.center))),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(item.title.toUpperCase(), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontSize: active ? 9 : 7, letterSpacing: 1.2)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
