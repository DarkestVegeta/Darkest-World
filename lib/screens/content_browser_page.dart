import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/chat_scope.dart';
import '../core/content_models.dart';
import '../core/content_repository.dart';
import '../core/supabase_client.dart';
import 'chatbox.dart';
import 'content_detail_page.dart';

class ContentBrowserPage extends StatefulWidget {
  final String? contentType;
  final String title;
  final List<int> platformIds;

  const ContentBrowserPage({super.key, required this.title, this.contentType, this.platformIds = const []});

  @override
  State<ContentBrowserPage> createState() => _ContentBrowserPageState();
}

class _ContentBrowserPageState extends State<ContentBrowserPage> {
  final _repository = ContentRepository();
  final _search = TextEditingController();
  final _scroll = ScrollController();
  final _items = <ContentItem>[];
  bool _loading = false, _searching = false, _hasMore = true;
  int _page = 0;
  int _focus = 0;
  String? _error;

  bool get _external => ['game', 'movie', 'series'].contains(widget.contentType);
  String get _source => widget.contentType == 'game' ? 'igdb' : widget.contentType == 'movie' ? 'tmdb_movie' : 'tmdb_tv';

  @override
  void initState() { super.initState(); _scroll.addListener(_onScroll); _load(); }
  @override
  void dispose() { _search.dispose(); _scroll.dispose(); super.dispose(); }

  void _onScroll() {
    if (!_scroll.hasClients || _searching) return;
    if (_scroll.position.maxScrollExtent - _scroll.position.pixels < 900) _load();
  }

  Future<void> _load() async {
    if (_loading || !_hasMore || _searching) return;
    setState(() { _loading = true; _error = null; });
    try {
      final rows = await _repository.getContentItemsPage(type: widget.contentType, page: _page);
      if (!mounted) return;
      setState(() { _items.addAll(rows); _page++; _hasMore = rows.length == ContentRepository.pageSize; _loading = false; });
    } catch (e) { if (mounted) setState(() { _loading = false; _error = '$e'; }); }
  }

  Future<void> _searchExternal() async {
    final query = _search.text.trim();
    if (query.isEmpty || !_external) return;
    FocusScope.of(context).unfocus();
    setState(() { _searching = true; _loading = true; _error = null; _items.clear(); _focus = 0; });
    if (_scroll.hasClients) _scroll.jumpTo(0);
    try {
      final response = await supabase.functions.invoke('darkestworld-content-import', body: {'source': _source, 'query': query, 'platformIds': widget.platformIds});
      final data = Map<String, dynamic>.from(response.data as Map);
      if (data['ok'] != true) throw Exception('${data['error'] ?? 'Zoeken mislukt.'}');
      final results = <ContentItem>[];
      for (final raw in (data['items'] is List ? data['items'] as List : const [])) {
        if (raw is! Map) continue;
        final row = Map<String, dynamic>.from(raw);
        final src = '${row['external_source'] ?? _source}';
        final id = '${row['external_id'] ?? ''}';
        row['id'] = '$src:$id';
        row['slug'] = '${row['slug'] ?? row['title'] ?? '$src-$id'}';
        try { results.add(ContentItem.fromRow(row)); } catch (_) {}
      }
      if (mounted) setState(() { _items.addAll(results); _loading = false; });
    } catch (e) { if (mounted) setState(() { _loading = false; _error = '$e'; }); }
  }

  Future<void> _refresh() async {
    _search.clear();
    setState(() { _items.clear(); _page = 0; _focus = 0; _hasMore = true; _searching = false; _error = null; });
    if (_scroll.hasClients) _scroll.jumpTo(0);
    await _load();
  }

  void _open(ContentItem item) => Navigator.push(context, MaterialPageRoute(builder: (_) => ContentDetailPage(item: item)));

  ChatContext? get _chatContext {
    if (_searching) return null;
    final scope = switch (widget.contentType) { 'game' => ChatScope.games, 'movie' => ChatScope.movies, 'series' => ChatScope.series, _ => null };
    if (scope == null) return null;
    final item = _items.isEmpty ? null : _items[_focus.clamp(0, _items.length - 1)];
    return ChatContext(scope: scope, contentId: item?.id, contentTitle: item?.title);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title), actions: [IconButton(onPressed: _loading ? null : _refresh, icon: const Icon(Icons.refresh))]),
    floatingActionButton: _chatContext == null ? null : Chatbox(contextData: _chatContext!),
    body: Column(children: [
      if (_external) Padding(padding: const EdgeInsets.fromLTRB(24,18,24,4), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: TextField(
        controller: _search, textInputAction: TextInputAction.search, onSubmitted: (_) => _searchExternal(),
        decoration: InputDecoration(hintText: widget.contentType == 'game' ? 'Zoek een game' : widget.contentType == 'movie' ? 'Zoek een film' : 'Zoek een serie', prefixIcon: const Icon(Icons.search), suffixIcon: IconButton(onPressed: _loading ? null : _searchExternal, icon: const Icon(Icons.arrow_forward)), border: const OutlineInputBorder()),
      ))),
      if (_searching) Padding(padding: const EdgeInsets.only(top:8), child: Text('Live ${_source.toUpperCase()} • niet opgeslagen', style: TextStyle(fontSize:11,color:Colors.white.withValues(alpha:.42)))),
      Expanded(child: _body()),
    ]),
  );

  Widget _body() {
    if (_error != null && _items.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Laden mislukt: $_error'), const SizedBox(height:12), OutlinedButton(onPressed: _searching ? _searchExternal : _load, child: const Text('Opnieuw'))]));
    if (_items.isEmpty) return Center(child: _loading ? const CircularProgressIndicator() : Text(_searching ? 'Geen resultaten gevonden.' : 'Geen content gevonden.'));
    return LayoutBuilder(builder: (context, c) {
      final pad = c.maxWidth > 1500 ? 56.0 : 36.0;
      final gap = c.maxWidth > 1500 ? 18.0 : 14.0;
      final width = math.max(150.0, (c.maxWidth - pad * 2 - gap * 4) / 5);
      final height = width * 1.42;
      return ListView.builder(controller:_scroll, scrollDirection:Axis.horizontal, padding:EdgeInsets.symmetric(horizontal:pad), itemCount:_items.length, itemBuilder:(context,i){
        final main=i==_focus; return SizedBox(width:width+gap,height:height+40,child:Center(child:MouseRegion(cursor:SystemMouseCursors.click,onEnter:(_)=>setState(()=>_focus=i),child:GestureDetector(onTap:()=>_open(_items[i]),child:AnimatedScale(scale:main?1.10:1.0,duration:const Duration(milliseconds:140),child:_Card(item:_items[i],width:width,height:height,main:main))))));
      });
    });
  }
}

class _Card extends StatelessWidget {
  final ContentItem item; final double width,height; final bool main;
  const _Card({required this.item,required this.width,required this.height,required this.main});
  @override Widget build(BuildContext context){
    final url='${item.metadata['public_url'] ?? item.metadata['image_url'] ?? ''}'.trim();
    return Container(width:width,height:height,clipBehavior:Clip.antiAlias,decoration:BoxDecoration(borderRadius:BorderRadius.circular(14),border:Border.all(width:main?2:1,color:main?Theme.of(context).colorScheme.primary:Theme.of(context).colorScheme.outlineVariant)),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Expanded(child:url.isEmpty?_Placeholder(title:item.title):Image.network(url,fit:BoxFit.cover,errorBuilder:(_,__,___)=>_Placeholder(title:item.title))),Padding(padding:const EdgeInsets.fromLTRB(12,10,12,11),child:Text(item.title,maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(fontWeight:main?FontWeight.w700:FontWeight.w500))) ]));
  }
}
class _Placeholder extends StatelessWidget { final String title; const _Placeholder({required this.title}); @override Widget build(BuildContext context)=>Center(child:Padding(padding:const EdgeInsets.all(18),child:Text(title,textAlign:TextAlign.center,maxLines:4,overflow:TextOverflow.ellipsis))); }
