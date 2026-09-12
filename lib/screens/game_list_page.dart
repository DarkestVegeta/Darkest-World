import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'content_browser_page.dart';
import 'game_platform_page.dart';

class GameListPage extends StatefulWidget {
  final String territory;
  final String platform;
  final List<int> externalPlatformIds;
  final List<GamePlatform> navigationPlatforms;
  final int navigationIndex;
  const GameListPage({super.key, required this.territory, required this.platform, required this.externalPlatformIds, this.navigationPlatforms = const [], this.navigationIndex = -1});
  @override State<GameListPage> createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage> with SingleTickerProviderStateMixin {
  int focus = 2;
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();
  @override void dispose() { clock.dispose(); super.dispose(); }
  void openPlatform(GamePlatform target) => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => GameListPage(territory: widget.territory, platform: target.name, externalPlatformIds: target.externalPlatformIds, navigationPlatforms: widget.navigationPlatforms, navigationIndex: widget.navigationPlatforms.indexOf(target))));
  void openLibrary() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContentBrowserPage(title: '${widget.platform} • GAMES', contentType: 'game', platformIds: widget.externalPlatformIds)));

  @override Widget build(BuildContext context) {
    final platforms = widget.navigationPlatforms;
    final valid = widget.navigationIndex >= 0 && widget.navigationIndex < platforms.length;
    final previous = valid && widget.navigationIndex > 0 ? platforms[widget.navigationIndex - 1] : null;
    final next = valid && widget.navigationIndex < platforms.length - 1 ? platforms[widget.navigationIndex + 1] : null;
    return Scaffold(backgroundColor: const Color(0xFF010107), body: LayoutBuilder(builder: (context, box) {
      final compact = box.maxWidth < 900;
      return AnimatedBuilder(animation: clock, builder: (_, __) => Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _GamesSpace(t: clock.value))),
        SafeArea(child: Padding(padding: EdgeInsets.fromLTRB(compact ? 14 : 26, 14, compact ? 14 : 26, 0), child: Row(children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, size: 16)),
          const SizedBox(width: 6), Expanded(child: Text('GAME-WORLD  /  ${widget.territory}  /  ${widget.platform}', style: const TextStyle(fontSize: 10, letterSpacing: 2.2))),
          _Mini(label:'GAMES',value:'LIBRARY'), const SizedBox(width:16), _Mini(label:'VIEW',value:'FOCUS'),
        ]))),
        Center(child: _FocusBrowser(platforms: platforms, currentIndex: widget.navigationIndex, focus: focus, currentName: widget.platform, compact: compact, onFocus: (i) => setState(() => focus = i), onOpenCurrent: openLibrary, onOpenPlatform: (i) { if (i >= 0 && i < platforms.length) openPlatform(platforms[i]); }})),
        Positioned(left: 0, right: 0, bottom: compact ? 18 : 30, child: _Navigation(previous: previous, current: widget.platform, next: next, onPrevious: previous == null ? null : () => openPlatform(previous), onNext: next == null ? null : () => openPlatform(next))),
        Positioned(left: compact ? 16 : 30, bottom: compact ? 70 : 86, child: Text(focus == 2 ? 'CURRENT PLATFORM  •  ENTER TO OPEN GAME LIBRARY' : 'PLATFORM FOCUS  •  ENTER TO CHANGE WORLD', style: const TextStyle(fontSize: 7, letterSpacing: 2.2, color: Colors.white24))),
      ]));
    }));
  }
}

class _Mini extends StatelessWidget { final String label,value; const _Mini({required this.label,required this.value}); @override Widget build(BuildContext c)=>Column(crossAxisAlignment:CrossAxisAlignment.end,children:[Text(label,style:const TextStyle(fontSize:6,letterSpacing:2,color:Colors.white24)),const SizedBox(height:3),Text(value,style:const TextStyle(fontSize:8,letterSpacing:1.3,color:Colors.white54))]); }

class _FocusBrowser extends StatelessWidget {
  final List<GamePlatform> platforms; final int currentIndex,focus; final String currentName; final bool compact; final ValueChanged<int> onFocus; final VoidCallback onOpenCurrent; final ValueChanged<int> onOpenPlatform;
  const _FocusBrowser({required this.platforms,required this.currentIndex,required this.focus,required this.currentName,required this.compact,required this.onFocus,required this.onOpenCurrent,required this.onOpenPlatform});
  @override Widget build(BuildContext context) {
    final width=math.min(MediaQuery.sizeOf(context).width-(compact?20:60),1360.0);
    return SizedBox(width:width,height:compact?470:555,child:Column(children:[
      Text('GAME LIBRARY',style:TextStyle(fontSize:9,letterSpacing:3.5,color:Colors.white.withValues(alpha:.28))),
      const SizedBox(height:8),Text(currentName.toUpperCase(),style:const TextStyle(fontSize:22,letterSpacing:4)),
      const SizedBox(height:10),const Text('FOCUS BROWSE  /  FIVE WORLDS IN VIEW',style:TextStyle(fontSize:6,letterSpacing:2,color:Colors.white24)),
      const SizedBox(height:22),Expanded(child: Row(crossAxisAlignment:CrossAxisAlignment.center,children:List.generate(5,(slot){
        final index=currentIndex+slot-2,available=index>=0&&index<platforms.length,main=slot==2,active=focus==slot;
        final title=available?platforms[index].name:(main?currentName:'—');
        return Expanded(child:Padding(padding:const EdgeInsets.symmetric(horizontal:5),child:MouseRegion(onEnter:(_)=>onFocus(slot),cursor:available||main?SystemMouseCursors.click:SystemMouseCursors.basic,child:GestureDetector(onTap:main?onOpenCurrent:available?()=>onOpenPlatform(index):null,child:_Card(title:title,main:main,active:active,available:available,height:main?(compact?300:365):(compact?240:285))))));
      }))),
      const SizedBox(height:15),AnimatedSwitcher(duration:const Duration(milliseconds:180),child:Text(focus==2?'CURRENT  •  ENTER':(focus>=0&&focus<5?'SELECTED  •  ENTER':'—'),key:ValueKey(focus),style:const TextStyle(fontSize:8,letterSpacing:2.2,color:Colors.white30))),
    ]));
  }
}

class _Card extends StatelessWidget {
  final String title; final bool main,active,available; final double height;
  const _Card({required this.title,required this.main,required this.active,required this.available,required this.height});
  @override Widget build(BuildContext context)=>AnimatedContainer(duration:const Duration(milliseconds:180),height:height,transform:Matrix4.identity()..scale(main?1.0:(active?1.025:.97)),transformAlignment:Alignment.center,decoration:BoxDecoration(borderRadius:BorderRadius.circular(main?20:15),border:Border.all(color:Colors.white.withValues(alpha:main?.30:(active?.18:(available?.09:.035))),width:main?1.5:1),gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:main?const[Color(0xFF292340),Color(0xFF0B0A14),Color(0xFF020207)]:const[Color(0xFF17152A),Color(0xFF080811),Color(0xFF030307)]),boxShadow:main?const[BoxShadow(color:Color(0x667765D0),blurRadius:38),BoxShadow(color:Color(0x66000000),blurRadius:24,offset:Offset(0,15))]:active?const[BoxShadow(color:Color(0x337765D0),blurRadius:20)]:const[]),child:Stack(children:[Positioned.fill(child:CustomPaint(painter:_CardRelief(active:main||active))),Padding(padding:EdgeInsets.all(main?21:15),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(main?'CURRENT':available?'PLATFORM':'EMPTY',style:TextStyle(fontSize:7,letterSpacing:2.2,color:Colors.white.withValues(alpha:main?.50:.24))),const Spacer(),if(main)Container(width:34,height:1,margin:const EdgeInsets.only(bottom:14),color:const Color(0x668F82B5)),Text(title,maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:main?17:11,letterSpacing:main?2:1,fontWeight:main?FontWeight.w600:FontWeight.w500,color:Colors.white.withValues(alpha:available||main?1:.22))),const SizedBox(height:9),Text(available||main?(main?'OPEN GAME LIBRARY':'ENTER WORLD'):'NO WORLD',style:TextStyle(fontSize:7,letterSpacing:1.6,color:Colors.white.withValues(alpha:main?.30:.20))),if(active&&!main) ...[const Spacer(),const Text('FOCUS',style:TextStyle(fontSize:6,letterSpacing:2,color:Color(0x669A8CC0)))]))]));
}

class _CardRelief extends CustomPainter { final bool active; const _CardRelief({required this.active}); @override void paint(Canvas c,Size s){final p=Paint()..style=PaintingStyle.stroke..strokeWidth=.6..color=Colors.white.withValues(alpha:active?.055:.025);for(var i=0;i<5;i++){final r=Rect.fromCenter(center:Offset(s.width*.56,s.height*.44),width:s.width*(.45+i*.17),height:s.height*(.18+i*.12));c.drawOval(r,p);}}@override bool shouldRepaint(covariant _CardRelief old)=>old.active!=active; }

class _Navigation extends StatelessWidget { final GamePlatform? previous,next; final String current; final VoidCallback? onPrevious,onNext; const _Navigation({required this.previous,required this.current,required this.next,required this.onPrevious,required this.onNext}); @override Widget build(BuildContext c)=>Row(mainAxisAlignment:MainAxisAlignment.center,children:[_NavButton('PREVIOUS',previous?.name,onPrevious),const Padding(padding:EdgeInsets.symmetric(horizontal:22),child:Text('•',style:TextStyle(color:Colors.white24))),Column(children:[const Text('CURRENT',style:TextStyle(fontSize:6,letterSpacing:2,color:Colors.white24)),const SizedBox(height:4),Text(current,style:const TextStyle(fontSize:10,letterSpacing:1.8))]),const Padding(padding:EdgeInsets.symmetric(horizontal:22),child:Text('•',style:TextStyle(color:Colors.white24))),_NavButton('NEXT',next?.name,onNext)]); }
class _NavButton extends StatelessWidget { final String label; final String? value; final VoidCallback? onTap; const _NavButton(this.label,this.value,this.onTap); @override Widget build(BuildContext c)=>InkWell(onTap:onTap,child:Column(children:[Text(label,style:TextStyle(fontSize:7,letterSpacing:2,color:Colors.white.withValues(alpha:onTap==null?.12:.30))),const SizedBox(height:4),Text(value??'—',style:TextStyle(fontSize:9,color:onTap==null?Colors.white10:const Color(0xFF9A82FF)))])); }

class _GamesSpace extends CustomPainter { final double t; const _GamesSpace({required this.t}); @override void paint(Canvas c,Size s){final rect=Offset.zero&s;c.drawRect(rect,Paint()..shader=const RadialGradient(center:Alignment(0,-.1),radius:1.1,colors:[Color(0xFF17132F),Color(0xFF060611),Color(0xFF010105)]).createShader(rect));final r=math.Random(442);for(var i=0;i<220;i++){final x=(r.nextDouble()*s.width+t*s.width*.02)%s.width,y=r.nextDouble()*s.height;c.drawCircle(Offset(x,y),.2+r.nextDouble()*.7,Paint()..color=Colors.white.withValues(alpha:.02+r.nextDouble()*.055));}for(var i=0;i<4;i++){final p=Offset(s.width*(.18+i*.22)+math.sin(t*math.pi*2+i)*12,s.height*(.28+(i%2)*.35));c.drawCircle(p,90+i*20.0,Paint()..color=const Color(0x068F82B5));}}@override bool shouldRepaint(covariant _GamesSpace old)=>old.t!=t;}
