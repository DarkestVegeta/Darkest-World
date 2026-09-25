import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'content_browser_page.dart';
import 'game_platform_page.dart';

class GameListPage extends StatefulWidget {
  final String territory;
  final String platform;
  final List<int> externalPlatformIds;
  final List<GamePlatform> navigationPlatforms;
  const GameListPage({super.key, required this.territory, required this.platform, required this.externalPlatformIds});
  @override State<GameListPage> createState()=>_GameListPageState();
}
class _GameListPageState extends State<GameListPage> with SingleTickerProviderStateMixin {
  late final AnimationController _clock=AnimationController(vsync:this,duration:const Duration(seconds:72))..repeat();
  bool _traveling=false;
  @override void dispose(){_clock.dispose();super.dispose();}
  Future<void> _open() async {
    if(_traveling)return;
    setState(()=>_traveling=true);
    await Future<void>.delayed(const Duration(milliseconds:650));
    if(!mounted)return;
    await Navigator.of(context).push(MaterialPageRoute(builder:(_)=>ContentBrowserPage(title:'${widget.platform} • GAMES',contentType:'game',platformIds:widget.externalPlatformIds)));
    if(mounted)setState(()=>_traveling=false);
  }
  @override Widget build(BuildContext context){
    final compact=MediaQuery.sizeOf(context).width<760;
    return Scaffold(backgroundColor:const Color(0xFF010207),body:AnimatedBuilder(animation:_clock,builder:(_,__)=>Stack(fit:StackFit.expand,children:[
      const RepaintBoundary(child:CustomPaint(painter:_ArchiveSpaceStatic())),
      RepaintBoundary(child:CustomPaint(painter:_ArchiveSpaceAtmosphere(_clock.value))),
      Center(child:LayoutBuilder(builder:(_,b){final d=math.min(b.maxWidth*(compact ? .90 : .64),b.maxHeight*(compact ? .54 : .68)).toDouble();return AnimatedScale(scale:_traveling?2.65:1.0,alignment:Alignment.center,duration:const Duration(milliseconds:650),curve:Curves.easeInCubic,child:GestureDetector(onTap:_open,child:MouseRegion(cursor:SystemMouseCursors.click,child:SizedBox.square(dimension:d,child:CustomPaint(painter:_ArchiveWorld(_clock.value))))));})),
      SafeArea(child:Padding(padding:EdgeInsets.all(compact?14:30),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('GAME-WORLD / ${widget.territory.toUpperCase()} / ${widget.platform.toUpperCase()}',style:const TextStyle(fontSize:10,letterSpacing:2.3)),const SizedBox(height:5),const Text('ARCHIVE WORLD  /  CATALOG ORBIT',style:TextStyle(fontSize:6.5,letterSpacing:2,color:Color(0x5FFFFFFF))),const Spacer(),Center(child:Text('PHYSICAL MEDIA ARCHIVE  •  LIVE CATALOG',style:TextStyle(fontSize:6,letterSpacing:2,color:Colors.white.withValues(alpha:.35))))]))),
      Positioned(left:compact?14:30,right:compact?14:30,bottom:compact?16:28,child:AnimatedOpacity(opacity:_traveling?0.0:1.0,duration:const Duration(milliseconds:300),child:Text('ENTER THE ARCHIVE WORLD · TRAVEL INTO THE LIBRARY',style:TextStyle(fontSize:6.5,letterSpacing:1.8,color:Colors.white.withValues(alpha:.30))))),
      Positioned.fill(child:IgnorePointer(child:AnimatedOpacity(opacity:_traveling?.24:0.0,duration:const Duration(milliseconds:650),curve:Curves.easeInCubic,child:const ColoredBox(color:Color(0xFF02040A))))),
    ])));
  }
}
class _ArchiveWorld extends CustomPainter{final double phase;const _ArchiveWorld(this.phase);@override void paint(Canvas x,Size s){final c=Offset(s.width*.5,s.height*.5),r=math.min(s.width,s.height)*.31;for(var i=0;i<8;i++){final rr=r*(1.45+i*.22);x.drawOval(Rect.fromCenter(center:c,width:rr*2,height:rr*.54),Paint()..style=PaintingStyle.stroke..strokeWidth=i==7?1:.48..color=const Color(0x218EA8B8));}final rect=Rect.fromCircle(center:c,radius:r*1.08);x.drawCircle(c,r*1.08,Paint()..shader=const RadialGradient(center:Alignment(-.42,-.48),colors:[Color(0xFFC2CED5),Color(0xFF6E7D91),Color(0xFF293446),Color(0xFF050811)],stops:[.03,.24,.62,1]).createShader(rect));final lat=Paint()..style=PaintingStyle.stroke..strokeWidth=.65..color=const Color(0x457F9BA8);for(var i=-3;i<=3;i++){x.drawOval(Rect.fromCenter(center:Offset(c.dx,c.dy+i*r*.12),width:r*1.72,height:r*(.18+(3-i.abs())*.10)),lat);}final detail=Paint()..style=PaintingStyle.stroke..strokeWidth=1.0..color=const Color(0x597A9587);for(var i=0;i<12;i++){final p=Path()..moveTo(c.dx-r*.62+i*r*.09,c.dy-r*.45)..cubicTo(c.dx-r*.3+i*r*.07,c.dy-r*.15,c.dx-r*.45+i*r*.08,c.dy+r*.22,c.dx-r*.08+i*r*.08,c.dy+r*.53);x.drawPath(p,detail);}x.drawArc(Rect.fromCircle(center:c,radius:r*1.16),phase*math.pi*2,.9,false,Paint()..style=PaintingStyle.stroke..strokeWidth=1.5..color=const Color(0x729BBCC7));x.drawCircle(c,r*1.08,Paint()..style=PaintingStyle.stroke..strokeWidth=r*.025..color=const Color(0x397FADB7));} @override bool shouldRepaint(covariant _ArchiveWorld o)=>o.phase!=phase;}
class _ArchiveSpaceStatic extends CustomPainter{
  const _ArchiveSpaceStatic();
  @override void paint(Canvas x,Size s){
    x.drawRect(Offset.zero&s,Paint()..shader=const RadialGradient(
      colors:[Color(0xFF10182A),Color(0xFF040710),Color(0xFF010207)]
    ).createShader(Offset.zero&s));
  }
  @override bool shouldRepaint(covariant _ArchiveSpaceStatic o)=>false;
}
class _ArchiveSpaceAtmosphere extends CustomPainter{
  final double phase;
  const _ArchiveSpaceAtmosphere(this.phase);
  @override void paint(Canvas x,Size s){
    final rnd=math.Random(917);
    for(var i=0;i<150;i++){
      final p=Offset(rnd.nextDouble()*s.width,rnd.nextDouble()*s.height);
      final pulse=.35+.65*math.sin(phase*math.pi*2+i*.41).abs();
      x.drawCircle(p,.2+rnd.nextDouble()*.65,Paint()..color=Colors.white.withValues(alpha:.02+.045*pulse));
    }
  }
  @override bool shouldRepaint(covariant _ArchiveSpaceAtmosphere o)=>o.phase!=phase;
}
