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
  @override State<ContentBrowserPage> createState() => _ContentBrowserPageState();
}

class _ContentBrowserPageState extends State<ContentBrowserPage> {
  final _repository = ContentRepository();
  final _search = TextEditingController();
  final _scroll = ScrollController();
  final _items = <ContentItem>[];
  bool _loading = false, _searching = false, _hasMore = true;
  int _page = 0, _focus = 2;
  String? _error;

  bool get _external => ['game','movie','series'].contains(widget.contentType);
  bool get _gameBrowser => widget.contentType == 'game';
  String get _source => widget.contentType == 'game' ? 'igdb' : widget.contentType == 'movie' ? 'tmdb_movie' : 'tmdb_tv';
  String get _displayTitle => widget.title.replaceFirst(RegExp(r'\s*•\s*GAMES\s*$', caseSensitive: false), '').trim();
  List<int> get _platformIds {
    if (widget.platformIds.isNotEmpty) return widget.platformIds;
    final t = widget.title.toUpperCase();
    if (t.contains('NINTENDO')) return [18,19,4,21,5,41,20,37,130];
    if (t.contains('SEGA')) return [29,32,23,84,107];
    if (t.contains('PLAYSTATION')) return [7,8,9,48,167];
    if (t.contains('XBOX')) return [11,12,49,169];
    return [];
  }

  @override void initState(){super.initState();_scroll.addListener(_onScroll);_load();}
  @override void dispose(){_search.dispose();_scroll.dispose();super.dispose();}
  void _onScroll(){if(!_scroll.hasClients||_searching)return;if(_scroll.position.maxScrollExtent-_scroll.position.pixels<900)_load();}

  Future<void> _load() async {
    if(_loading||!_hasMore||_searching)return;
    setState(()=>_loading=true);
    try{
      final rows=await _repository.getContentItemsPage(type:widget.contentType,page:_page);
      if(!mounted)return;
      setState((){_items.addAll(rows);_page++;_hasMore=rows.length==ContentRepository.pageSize;_loading=false;_focus=_items.length>2?2:0;});
    }catch(e){if(mounted)setState((){_loading=false;_error='$e';});}
  }

  Future<void> _searchExternal() async {
    final query=_search.text.trim();if(query.isEmpty||!_external)return;
    FocusScope.of(context).unfocus();
    setState((){_searching=true;_loading=true;_error=null;_items.clear();_focus=0;});
    if(_scroll.hasClients)_scroll.jumpTo(0);
    try{
      final response=await supabase.functions.invoke('darkestworld-content-import',body:{'source':_source,'query':query,'platformIds':_platformIds});
      final data=Map<String,dynamic>.from(response.data as Map);
      if(data['ok']!=true)throw Exception('${data['error']??'Zoeken mislukt.'}');
      final results=<ContentItem>[];
      for(final raw in(data['items'] is List?data['items'] as List:const [])){
        if(raw is! Map)continue;final row=Map<String,dynamic>.from(raw);final src='${row['external_source']??_source}';final id='${row['external_id']??''}';row['id']='$src:$id';row['slug']='${row['slug']??row['title']??'$src-$id'}';
        try{results.add(ContentItem.fromRow(row));}catch(_){ }
      }
      if(mounted){setState((){_items.addAll(results);_loading=false;_focus=results.length>2?2:0;});WidgetsBinding.instance.addPostFrameCallback((_){_centerFocus();});}
    }catch(e){if(mounted)setState((){_loading=false;_error='$e';});}
  }

  Future<void> _centerFocus() async {
    if(!mounted||!_scroll.hasClients||_items.length<2)return;
    final width=_scroll.position.viewportDimension;
    final gap=width>1500?18.0:14.0;
    final card=math.max(150.0,(width-gap*4)/5);
    final target=_focus*(card+gap);
    await _scroll.animateTo(target.clamp(0.0,_scroll.position.maxScrollExtent),duration:const Duration(milliseconds:220),curve:Curves.easeOut);
  }

  void _moveFocus(int delta){
    if(_items.isEmpty)return;
    final next=(_focus+delta).clamp(0,_items.length-1);
    if(next==_focus)return;
    setState(()=>_focus=next);
    _centerFocus();
  }

  Future<void> _refresh() async{_search.clear();setState((){_items.clear();_page=0;_focus=2;_hasMore=true;_searching=false;_error=null;});if(_scroll.hasClients)_scroll.jumpTo(0);await _load();}
  void _open(ContentItem item)=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ContentDetailPage(item:item)));

  ChatContext? get _chatContext{if(_searching)return null;final scope=switch(widget.contentType){'game'=>ChatScope.games,'movie'=>ChatScope.movies,'series'=>ChatScope.series,_=>null};if(scope==null)return null;final item=_items.isEmpty?null:_items[_focus.clamp(0,_items.length-1)];return ChatContext(scope:scope,contentId:item?.id,contentTitle:item?.title);}

  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(widget.title),actions:[IconButton(onPressed:_loading?null:_refresh,icon:const Icon(Icons.refresh))]),floatingActionButton:_chatContext==null?null:Chatbox(contextData:_chatContext!),body:Column(children:[
    if(_gameBrowser)Padding(padding:const EdgeInsets.fromLTRB(24,12,24,0),child:Text('GAME-WORLD  ›  ${_displayTitle.toUpperCase()}  ›  GAMES',style:TextStyle(fontSize:9,letterSpacing:2.1,color:Colors.white.withValues(alpha:.28)))),
    if(_external)Padding(padding:const EdgeInsets.fromLTRB(24,18,24,4),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:760),child:TextField(controller:_search,textInputAction:TextInputAction.search,onSubmitted:(_)=>_searchExternal(),decoration:InputDecoration(hintText:widget.contentType=='game'?'Zoek een game':widget.contentType=='movie'?'Zoek een film':'Zoek een serie',prefixIcon:const Icon(Icons.search),suffixIcon:IconButton(onPressed:_loading?null:_searchExternal,icon:const Icon(Icons.arrow_forward)),border:const OutlineInputBorder())))),
    if(_searching)Padding(padding:const EdgeInsets.only(top:8),child:Text('LIVE ${_source.toUpperCase()} • NIET OPGESLAGEN',style:TextStyle(fontSize:11,color:Colors.white.withValues(alpha:.42)))),
    if(_items.length>1)_ContentNavigation(items:_items,focus:_focus,onPrevious:_focus>0?()=>_moveFocus(-1):null,onNext:_focus<_items.length-1?()=>_moveFocus(1):null),
    Expanded(child:_body())]));

  Widget _body(){
    if(_error!=null&&_items.isEmpty)return Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Text('Laden mislukt: $_error'),const SizedBox(height:12),OutlinedButton(onPressed:_searching?_searchExternal:_load,child:const Text('Opnieuw'))]));
    if(_items.isEmpty)return Center(child:_loading?const CircularProgressIndicator():Text(_searching?'Geen resultaten gevonden.':'Geen content gevonden.'));
    return LayoutBuilder(builder:(context,c){
      final gap=c.maxWidth>1500?18.0:14.0;final card=math.max(150.0,(c.maxWidth-gap*4)/5);final height=card*1.42;final side=(c.maxWidth-card)/2;
      return ListView.builder(controller:_scroll,scrollDirection:Axis.horizontal,padding:EdgeInsets.symmetric(horizontal:side),itemCount:_items.length,itemBuilder:(context,i){final main=i==_focus;return SizedBox(width:card+gap,height:height+40,child:Center(child:MouseRegion(cursor:SystemMouseCursors.click,onEnter:(_)=>setState(()=>_focus=i),child:GestureDetector(onTap:()=>_open(_items[i]),child:AnimatedScale(scale:main?1.10:1.0,duration:const Duration(milliseconds:140),child:_Card(item:_items[i],width:card,height:height,main:main))))));});
    });
  }
}

class _ContentNavigation extends StatelessWidget {
  final List<ContentItem> items;
  final int focus;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  const _ContentNavigation({required this.items,required this.focus,required this.onPrevious,required this.onNext});

  @override Widget build(BuildContext context){
    final previous=focus>0?items[focus-1].title:null;
    final current=items[focus].title;
    final next=focus<items.length-1?items[focus+1].title:null;
    return Padding(padding:const EdgeInsets.fromLTRB(24,14,24,4),child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[
      _ContentNavNode(label:'PREVIOUS',value:previous,onTap:onPrevious,align:CrossAxisAlignment.end),
      const Padding(padding:EdgeInsets.symmetric(horizontal:18),child:Text('|',style:TextStyle(color:Color(0xFF5C5577)))),
      Column(mainAxisSize:MainAxisSize.min,children:[Text('CURRENT',style:TextStyle(color:Colors.white.withValues(alpha:.38),fontSize:8,letterSpacing:2.4)),const SizedBox(height:4),ConstrainedBox(constraints:const BoxConstraints(maxWidth:260),child:Text(current,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12,letterSpacing:.8,fontWeight:FontWeight.w600))) ]),
      const Padding(padding:EdgeInsets.symmetric(horizontal:18),child:Text('|',style:TextStyle(color:Color(0xFF5C5577)))),
      _ContentNavNode(label:'NEXT',value:next,onTap:onNext,align:CrossAxisAlignment.start),
    ]));
  }
}

class _ContentNavNode extends StatelessWidget {
  final String label;final String? value;final VoidCallback? onTap;final CrossAxisAlignment align;
  const _ContentNavNode({required this.label,required this.value,required this.onTap,required this.align});
  @override Widget build(BuildContext context)=>InkWell(onTap:onTap,borderRadius:BorderRadius.circular(8),child:Padding(padding:const EdgeInsets.symmetric(horizontal:4,vertical:4),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:align,children:[Text(label,style:TextStyle(color:onTap==null?Colors.white.withValues(alpha:.14):Colors.white.withValues(alpha:.32),fontSize:8,letterSpacing:2.2)),const SizedBox(height:4),ConstrainedBox(constraints:const BoxConstraints(maxWidth:180),child:Text(value??'—',maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(color:onTap==null?Colors.white.withValues(alpha:.12):const Color(0xFF9A82FF),fontSize:10,letterSpacing:.6))) ]));
}

class _Card extends StatelessWidget{final ContentItem item;final double width,height;final bool main;const _Card({required this.item,required this.width,required this.height,required this.main});@override Widget build(BuildContext context){final url='${item.metadata['public_url']??item.metadata['image_url']??''}'.trim();return Container(width:width,height:height,clipBehavior:Clip.antiAlias,decoration:BoxDecoration(borderRadius:BorderRadius.circular(14),border:Border.all(width:main?2:1,color:main?Theme.of(context).colorScheme.primary:Theme.of(context).colorScheme.outlineVariant)),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Expanded(child:url.isEmpty?_Placeholder(title:item.title):Image.network(url,fit:BoxFit.cover,errorBuilder:(_,__,___)=>_Placeholder(title:item.title))),Padding(padding:const EdgeInsets.fromLTRB(12,10,12,11),child:Text(item.title,maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(fontWeight:main?FontWeight.w700:FontWeight.w500))) ]));}}
class _Placeholder extends StatelessWidget{final String title;const _Placeholder({required this.title});@override Widget build(BuildContext context)=>Center(child:Padding(padding:const EdgeInsets.all(18),child:Text(title,textAlign:TextAlign.center,maxLines:4,overflow:TextOverflow.ellipsis)));}
