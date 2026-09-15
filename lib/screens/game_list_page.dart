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
  @override State<GameListPage> createState()=>_GameListPageState();
}
class _GameListPageState extends State<GameListPage> with SingleTickerProviderStateMixin {
  late final AnimationController _clock=AnimationController(vsync:this,duration:const Duration(seconds:72))..repeat();
  @override void dispose(){_clock.dispose();super.dispose();}
  void _open()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>ContentBrowserPage(title:'${widget.platform} • GAMES',contentType:'game',platformIds:widget.externalPlatformIds)));
  void _move(GamePlatform p,int i)=>Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>GameListPage(territory:widget.territory,platform:p.name,externalPlatformIds:p.externalPlatformIds,navigationPlatforms:widget.navigationPlatforms,navigationIndex:i)));
  @override Widget build(BuildContext context){
    final compact=MediaQuery.sizeOf(context).width<760;
    final prev=widget.navigationIndex>0?widget.navigationPlatforms[widget.navigationIndex-1]:null;
    final next=widget.navigationIndex>=0&&widget.navigationIndex+1<widget.navigationPlatforms.length?widget.navigationPlatforms[widget.navigationIndex+1]:null;
    return Scaffold(backgroundColor:const Color(0xFF010207),body:AnimatedBuilder(animation:_clock,builder:(_,__)=>Stack(fit:StackFit.expand,children:[
      CustomPaint(painter:_ArchiveSpace(_clock.value)),
      Center(child:LayoutBuilder(builder:(_,b){final d=math.min(b.maxWidth*(compact ? .90 : .64),b.maxHeight*(compact ? .54 : .68)).toDouble();return SizedBox.square(dimension:d,child:CustomPaint(painter:_ArchiveWorld(_clock.value)));})),
      SafeArea(child:Padding(padding:EdgeInsets.all(compact?14:30),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('GAME-WORLD / ${widget.territory.toUpperCase()} / ${widget.platform.toUpperCase()}',style:const TextStyle(fontSize:10,letterSpacing:2.3)),const SizedBox(height:5),const Text('ARCHIVE WORLD  /  CATALOG ORBIT',style:TextStyle(fontSize:6.5,letterSpacing:2,color:Color(0x5FFFFFFF))),const Spacer(),Center(child:Text('PHYSICAL MEDIA ARCHIVE  •  LIVE CATALOG',style:TextStyle(fontSize:6,letterSpacing:2,color:Colors.white.withValues(alpha:.35))))]))),
      Positioned(left:compact?12:30,right:compact?12:30,bottom:compact?14:28,child:_Panel(territory:widget.territory,platform:widget.platform,onOpen:_open,prev:prev,next:next,onPrev:prev==null?null:()=>_move(prev,widget.navigationIndex-1),onNext:next==null?null:()=>_move(next,widget.navigationIndex+1))),
    ])));
  }
}
class _ArchiveWorld extends CustomPainter{final double phase;const _ArchiveWorld(this.phase);@override void paint(Canvas x,Size s){final c=Offset(s.width*.5,s.height*.5),r=math.min(s.width,s.height)*.31;for(var i=0;i<8;i++){final rr=r*(1.45+i*.22);x.drawOval(Rect.fromCenter(center:c,width:rr*2,height:rr*.54),Paint()..style=PaintingStyle.stroke..strokeWidth=i==7?1:.48..color=const Color(0x218EA8B8));}final rect=Rect.fromCircle(center:c,radius:r*1.08);x.drawCircle(c,r*1.08,Paint()..shader=const RadialGradient(center:Alignment(-.42,-.48),colors:[Color(0xFFC2CED5),Color(0xFF6E7D91),Color(0xFF293446),Color(0xFF050811)],stops:[.03,.24,.62,1]).createShader(rect));final lat=Paint()..style=PaintingStyle.stroke..strokeWidth=.65..color=const Color(0x457F9BA8);for(var i=-3;i<=3;i++){x.drawOval(Rect.fromCenter(center:Offset(c.dx,c.dy+i*r*.12),width:r*1.72,height:r*(.18+(3-i.abs())*.10)),lat);}final detail=Paint()..style=PaintingStyle.stroke..strokeWidth=1.0..color=const Color(0x597A9587);for(var i=0;i<12;i++){final p=Path()..moveTo(c.dx-r*.62+i*r*.09,c.dy-r*.45)..cubicTo(c.dx-r*.3+i*r*.07,c.dy-r*.15,c.dx-r*.45+i*r*.08,c.dy+r*.22,c.dx-r*.08+i*r*.08,c.dy+r*.53);x.drawPath(p,detail);}x.drawArc(Rect.fromCircle(center:c,radius:r*1.16),phase*math.pi*2,.9,false,Paint()..style=PaintingStyle.stroke..strokeWidth=1.5..color=const Color(0x729BBCC7));x.drawCircle(c,r*1.08,Paint()..style=PaintingStyle.stroke..strokeWidth=r*.025..color=const Color(0x397FADB7));} @override bool shouldRepaint(covariant _ArchiveWorld o)=>o.phase!=phase;}
class _ArchiveSpace extends CustomPainter{final double phase;const _ArchiveSpace(this.phase);@override void paint(Canvas x,Size s){x.drawRect(Offset.zero&s,Paint()..shader=const RadialGradient(colors:[Color(0xFF10182A),Color(0xFF040710),Color(0xFF010207)]).createShader(Offset.zero&s));final rnd=math.Random(917);for(var i=0;i<360;i++){final p=Offset(rnd.nextDouble()*s.width,rnd.nextDouble()*s.height);x.drawCircle(p,.2+rnd.nextDouble()*.8,Paint()..color=Colors.white.withValues(alpha:.025+.07*((math.sin(phase*math.pi*2+i)+1)/2)));}}@override bool shouldRepaint(covariant _ArchiveSpace o)=>o.phase!=phase;}
class _Panel extends StatelessWidget{final String territory,platform;final VoidCallback onOpen;final GamePlatform? prev,next;final VoidCallback? onPrev,onNext;const _Panel({required this.territory,required this.platform,required this.onOpen,required this.prev,required this.next,required this.onPrev,required this.onNext});@override Widget build(BuildContext c)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:const Color(0xEF050912),border:Border.all(color:const Color(0x4F8199A7)),boxShadow:const[BoxShadow(color:Colors.black87,blurRadius:38)]),child:Row(children:[if(onPrev!=null)IconButton(onPressed:onPrev,icon:const Icon(Icons.chevron_left)),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('CATALOG WORLD  /  ${territory.toUpperCase()}',style:const TextStyle(fontSize:6,letterSpacing:1.8,color:Color(0x66FFFFFF))),const SizedBox(height:4),Text(platform,style:const TextStyle(fontSize:17,letterSpacing:2.4)),const SizedBox(height:3),const Text('PHYSICAL MEDIA • COMPLETE GAME LIBRARY',style:TextStyle(fontSize:6.5,color:Color(0x70FFFFFF),letterSpacing:1.2))])),FilledButton(onPressed:onOpen,child:const Text('OPEN LIBRARY')),if(onNext!=null)IconButton(onPressed:onNext,icon:const Icon(Icons.chevron_right))]));}
