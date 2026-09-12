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
    final position = valid ? widget.navigationIndex + 1 : 1;
    return Scaffold(
      backgroundColor: const Color(0xFF010107),
      body: LayoutBuilder(builder: (context, box) {
        final compact = box.maxWidth < 900;
        return AnimatedBuilder(animation: clock, builder: (_, __) => Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _GamesSpace(t: clock.value))),
          SafeArea(child: Padding(padding: EdgeInsets.fromLTRB(compact ? 14 : 28, 14, compact ? 14 : 28, 0), child: Row(children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, size: 16)),
            const SizedBox(width: 6),
            Expanded(child: Text('GAME-WORLD  /  ${widget.territory}  /  ${widget.platform}', style: const TextStyle(fontSize: 10, letterSpacing: 2.2))),
            if (!compact) ...[_Mini(label:'WORLD',value:'${widget.territory.toUpperCase()}'), const SizedBox(width:22)],
            _Mini(label:'GAMES',value:'LIBRARY'), const SizedBox(width:18), _Mini(label:'VIEW',value:'FOCUS'),
          ]))),
          Center(child: _FocusBrowser(
            platforms: platforms,
            currentIndex: widget.navigationIndex,
            focus: focus,
            currentName: widget.platform,
            compact: compact,
            position: position,
            onFocus: (i) => setState(() => focus = i),
            onOpenCurrent: openLibrary,
            onOpenPlatform: (i) { if (i >= 0 && i < platforms.length) openPlatform(platforms[i]); },
          )),
          Positioned(left: compact ? 12 : 28, right: compact ? 12 : 28, bottom: compact ? 12 : 24, child: _Navigation(previous: previous, current: widget.platform, next: next, onPrevious: previous == null ? null : () => openPlatform(previous), onNext: next == null ? null : () => openPlatform(next), position: position, total: platforms.length)),
          Positioned(left: compact ? 16 : 30, bottom: compact ? 62 : 78, child: Text(focus == 2 ? 'CURRENT PLATFORM  •  ENTER TO OPEN GAME LIBRARY' : 'PLATFORM FOCUS  •  ENTER TO CHANGE WORLD', style: const TextStyle(fontSize: 7, letterSpacing: 2.2, color: Colors.white24))),
        ]));
      }),
    );
  }
}

class _Mini extends StatelessWidget {
  final String label,value;
  const _Mini({required this.label,required this.value});
  @override Widget build(BuildContext c) => Column(crossAxisAlignment:CrossAxisAlignment.end,children:[Text(label,style:const TextStyle(fontSize:6,letterSpacing:2,color:Colors.white24)),const SizedBox(height:3),Text(value,style:const TextStyle(fontSize:8,letterSpacing:1.3,color:Colors.white54))]);
}

class _FocusBrowser extends StatelessWidget {
  final List<GamePlatform> platforms;
  final int currentIndex,focus,position;
  final String currentName;
  final bool compact;
  final ValueChanged<int> onFocus;
  final VoidCallback onOpenCurrent;
  final ValueChanged<int> onOpenPlatform;
  const _FocusBrowser({required this.platforms,required this.currentIndex,required this.focus,required this.currentName,required this.compact,required this.position,required this.onFocus,required this.onOpenCurrent,required this.onOpenPlatform});

  @override Widget build(BuildContext context) {
    final width=math.min(MediaQuery.sizeOf(context).width-(compact?18:56),1420.0);
    final height=compact?500.0:600.0;
    return SizedBox(width:width,height:height,child:Column(children:[
      Text('GAME LIBRARY',style:TextStyle(fontSize:9,letterSpacing:3.8,color:Colors.white.withValues(alpha:.28))),
      const SizedBox(height:8),
      Text(currentName.toUpperCase(),style:const TextStyle(fontSize:22,letterSpacing:4)),
      const SizedBox(height:8),
      Text('${widgetLabel(position, platforms.length)}  /  FOCUS BROWSE  /  FIVE WORLDS IN VIEW',style:const TextStyle(fontSize:6,letterSpacing:2,color:Colors.white24)),
      const SizedBox(height:18),
      Expanded(child: Row(crossAxisAlignment:CrossAxisAlignment.center,children:List.generate(5,(slot){
        final index=currentIndex+slot-2;
        final available=index>=0&&index<platforms.length;
        final main=slot==2;
        final active=focus==slot;
        final title=available?platforms[index].name:(main?currentName:'—');
        return Expanded(child:Padding(padding:const EdgeInsets.symmetric(horizontal:5),child:MouseRegion(
          onEnter:(_)=>onFocus(slot),
          cursor:available||main?SystemMouseCursors.click:SystemMouseCursors.basic,
          child:GestureDetector(onTap:main?onOpenCurrent:available?()=>onOpenPlatform(index):null,child:_Card(
            title:title,main:main,active:active,available:available,height:main?(compact?300:385):(compact?235:295),index:index,
          )),
        )));
      }))),
      const SizedBox(height:12),
      AnimatedSwitcher(duration:const Duration(milliseconds:180),child:Row(mainAxisSize:MainAxisSize.min,children:[
        Container(width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color:focus==2?const Color(0xAA9A8CC0):Colors.white24)),
        const SizedBox(width:9),
        Text(focus==2?'CURRENT  •  ENTER':(focus>=0&&focus<5?'SELECTED  •  ENTER':'—'),key:ValueKey(focus),style:const TextStyle(fontSize:8,letterSpacing:2.2,color:Colors.white30)),
      ])),
    ]));
  }
}

String widgetLabel(int position,int total) => total == 0 ? 'PLATFORM 01' : 'PLATFORM ${position.toString().padLeft(2,'0')} / ${total.toString().padLeft(2,'0')}';

class _Card extends StatelessWidget {
  final String title; final bool main,active,available; final double height; final int index;
  const _Card({required this.title,required this.main,required this.active,required this.available,required this.height,required this.index});
  @override Widget build(BuildContext context) => AnimatedContainer(
    duration:const Duration(milliseconds:220),
    height:height,
    transform:Matrix4.identity()..scale(main?1.0:(active?1.035:.965)),
    transformAlignment:Alignment.center,
    decoration:BoxDecoration(
      borderRadius:BorderRadius.circular(main?22:16),
      border:Border.all(color:Colors.white.withValues(alpha:main?.34:(active?.20:(available?.09:.035))),width:main?1.5:1),
      gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:main?const[Color(0xFF31294C),Color(0xFF100D1C),Color(0xFF020207)]:const[Color(0xFF19172B),Color(0xFF080811),Color(0xFF030307)]),
      boxShadow:main?const[BoxShadow(color:Color(0x667765D0),blurRadius:42),BoxShadow(color:Color(0x66000000),blurRadius:28,offset:Offset(0,16))]:active?const[BoxShadow(color:Color(0x337765D0),blurRadius:22)]:const[],
    ),
    child:Stack(children:[
      Positioned.fill(child:CustomPaint(painter:_CardRelief(active:main||active,index:index))),
      if(main) Positioned.fill(child:IgnorePointer(child:CustomPaint(painter:_PlatformSphere(seed:index+91,t:0)))),
      Padding(padding:EdgeInsets.all(main?21:15),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[Expanded(child:Text(main?'CURRENT':available?'PLATFORM':'EMPTY',style:TextStyle(fontSize:7,letterSpacing:2.2,color:Colors.white.withValues(alpha:main?.50:.24)))),Text('${(index<0?0:index+1).toString().padLeft(2,'0')}',style:const TextStyle(fontSize:6,letterSpacing:1.5,color:Colors.white24))]),
        const Spacer(),
        if(main) Container(width:42,height:1,margin:const EdgeInsets.only(bottom:14),color:const Color(0x668F82B5)),
        Text(title,maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:main?18:11,letterSpacing:main?2:1,fontWeight:main?FontWeight.w600:FontWeight.w500,color:Colors.white.withValues(alpha:available||main?1:.22))),
        const SizedBox(height:9),
        Text(available||main?(main?'OPEN GAME LIBRARY':'ENTER WORLD'):'NO WORLD',style:TextStyle(fontSize:7,letterSpacing:1.6,color:Colors.white.withValues(alpha:main?.30:.20))),
        if(main) ...[const SizedBox(height:12),_CardSignal()],
        if(active&&!main) ...[const Spacer(),const Text('FOCUS',style:TextStyle(fontSize:6,letterSpacing:2,color:Color(0x669A8CC0)))],
      ]),
    ]),
  );
}

class _CardSignal extends StatelessWidget {
  @override Widget build(BuildContext context)=>Row(children:[
    Container(width:5,height:5,decoration:const BoxDecoration(shape:BoxShape.circle,color:Color(0xAA9A8CC0))),
    const SizedBox(width:7),
    const Text('CONNECTED',style:TextStyle(fontSize:6,letterSpacing:1.8,color:Colors.white24)),
    const Spacer(),
    const Text('READY',style:TextStyle(fontSize:6,letterSpacing:1.8,color:Color(0x669A8CC0))),
  ]);
}

class _CardRelief extends CustomPainter {
  final bool active; final int index;
  const _CardRelief({required this.active,required this.index});
  @override void paint(Canvas c,Size s){
    final p=Paint()..style=PaintingStyle.stroke..strokeWidth=.6..color=Colors.white.withValues(alpha:active?.055:.025);
    for(var i=0;i<7;i++){
      final r=Rect.fromCenter(center:Offset(s.width*(.54+math.sin(index+i)*.025),s.height*(.43+math.cos(index+i)*.02)),width:s.width*(.38+i*.15),height:s.height*(.15+i*.105));
      c.drawOval(r,p);
    }
    final grid=Paint()..style=PaintingStyle.stroke..strokeWidth=.35..color=const Color(0x14100D24);
    for(var i=1;i<6;i++) c.drawLine(Offset(s.width*i/6,0),Offset(s.width*i/6,s.height),grid);
  }
  @override bool shouldRepaint(covariant _CardRelief old)=>old.active!=active||old.index!=index;
}

class _PlatformSphere extends CustomPainter {
  final int seed; final double t;
  const _PlatformSphere({required this.seed,required this.t});
  @override void paint(Canvas c,Size s){
    final center=Offset(s.width*.67,s.height*.45); final r=math.min(s.width,s.height)*.27;
    c.drawCircle(center,r,Paint()..shader=RadialGradient(center:const Alignment(-.35,-.4),colors:const[Color(0xFF9A8FC0),Color(0xFF51496A),Color(0xFF171426),Color(0xFF030309)],stops:const[0,.25,.68,1]).createShader(Rect.fromCircle(center:center,radius:r)));
    final p=Paint()..style=PaintingStyle.stroke..strokeWidth=.55..color=const Color(0x447F72A0);
    for(var i=0;i<5;i++){final rr=r*(.35+i*.13);c.drawOval(Rect.fromCenter(center:center,width:rr*2,height:rr*1.25),p);}
    final land=Path(); final random=math.Random(seed); for(var i=0;i<=26;i++){final a=i/26*math.pi*2;final wobble=1+math.sin(a*3+seed)*.10+math.cos(a*5+seed)*.055;final q=Offset(center.dx+math.cos(a)*r*.70*wobble,center.dy+math.sin(a)*r*.48*wobble);if(i==0)land.moveTo(q.dx,q.dy);else land.lineTo(q.dx,q.dy);} c.drawPath(land,Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0x336F648D));
    c.drawArc(Rect.fromCircle(center:center,radius:r*1.12),-.8,2.7,false,Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0x668F82B5));
  }
  @override bool shouldRepaint(covariant _PlatformSphere old)=>old.seed!=seed||old.t!=t;
}

class _Navigation extends StatelessWidget {
  final GamePlatform? previous,next; final String current; final VoidCallback? onPrevious,onNext; final int position,total;
  const _Navigation({required this.previous,required this.current,required this.next,required this.onPrevious,required this.onNext,required this.position,required this.total});
  @override Widget build(BuildContext c)=>Container(
    padding:const EdgeInsets.symmetric(horizontal:18,vertical:10),
    decoration:BoxDecoration(color:const Color(0x7706070D),borderRadius:BorderRadius.circular(14),border:Border.all(color:Colors.white.withValues(alpha:.055))),
    child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[
      _NavButton('PREVIOUS',previous?.name,onPrevious),
      const Padding(padding:EdgeInsets.symmetric(horizontal:22),child:Text('•',style:TextStyle(color:Colors.white24))),
      Column(children:[const Text('CURRENT',style:TextStyle(fontSize:6,letterSpacing:2,color:Colors.white24)),const SizedBox(height:4),Text(current,style:const TextStyle(fontSize:10,letterSpacing:1.8)),const SizedBox(height:3),Text('${position.toString().padLeft(2,'0')} / ${total.toString().padLeft(2,'0')}',style:const TextStyle(fontSize:6,letterSpacing:1.5,color:Colors.white24))]),
      const Padding(padding:EdgeInsets.symmetric(horizontal:22),child:Text('•',style:TextStyle(color:Colors.white24))),
      _NavButton('NEXT',next?.name,onNext),
    ]),
  );
}

class _NavButton extends StatelessWidget {
  final String label; final String? value; final VoidCallback? onTap;
  const _NavButton(this.label,this.value,this.onTap);
  @override Widget build(BuildContext c)=>InkWell(onTap:onTap,borderRadius:BorderRadius.circular(8),child:Padding(padding:const EdgeInsets.all(6),child:Column(children:[Text(label,style:TextStyle(fontSize:7,letterSpacing:2,color:Colors.white.withValues(alpha:onTap==null?.12:.30))),const SizedBox(height:4),Text(value??'—',style:TextStyle(fontSize:9,color:onTap==null?Colors.white10:const Color(0xFF9A82FF)))])));
}

class _GamesSpace extends CustomPainter {
  final double t;
  const _GamesSpace({required this.t});
  @override void paint(Canvas c,Size s){
    final rect=Offset.zero&s;
    c.drawRect(rect,Paint()..shader=const RadialGradient(center:Alignment(0,-.1),radius:1.1,colors:[Color(0xFF17132F),Color(0xFF060611),Color(0xFF010105)]).createShader(rect));
    final r=math.Random(442);
    for(var i=0;i<260;i++){
      final x=(r.nextDouble()*s.width+t*s.width*.02)%s.width;
      final y=(r.nextDouble()*s.height+math.sin(t*math.pi*2+i*.13)*2.5)%s.height;
      c.drawCircle(Offset(x,y),.2+r.nextDouble()*.7,Paint()..color=Colors.white.withValues(alpha:.018+r.nextDouble()*.055));
    }
    for(var i=0;i<5;i++){
      final p=Offset(s.width*(.12+i*.19)+math.sin(t*math.pi*2+i)*18,s.height*(.2+(i%3)*.25));
      c.drawCircle(p,70+i*26.0,Paint()..color=const Color(0x068F82B5));
    }
    final horizon=Rect.fromCenter(center:Offset(s.width*.5,s.height*.52),width:s.width*.86,height:s.height*.58);
    c.drawOval(horizon,Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0x0D9B8FC2));
  }
  @override bool shouldRepaint(covariant _GamesSpace old)=>old.t!=t;
}
