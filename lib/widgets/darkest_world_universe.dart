import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../screens/galaxy_navigation_session.dart';

enum GalaxyWorldKind { vegeta, game, identity, cinema, creation, music, family, archive, comingSoon }

class GalaxyWorld { final GalaxyWorldKind kind; final String title; final String description; const GalaxyWorld({required this.kind,required this.title,required this.description}); }

/// Game-only visual core. CreateWorld references define the visual language;
/// the island composition is a strong structural guide, never a literal copy.
/// Game Planet is the first/only planet being built now, while its visual
/// language deliberately leaves room for distinct future planets.
class DarkestWorldUniverse extends StatefulWidget {
  final List<GalaxyWorld> worlds; final ValueChanged<GalaxyWorld>? onWorldTap;
  const DarkestWorldUniverse({super.key,required this.worlds,this.onWorldTap});
  @override State<DarkestWorldUniverse> createState()=>_DarkestWorldUniverseState();
}
class _DarkestWorldUniverseState extends State<DarkestWorldUniverse> with SingleTickerProviderStateMixin {
  late final AnimationController clock=AnimationController(vsync:this,duration:const Duration(seconds:32))..repeat();
  bool worldOpen=false;
  GalaxyWorld get gameWorld=>widget.worlds.firstWhere((w)=>w.kind==GalaxyWorldKind.game,orElse:()=>const GalaxyWorld(kind:GalaxyWorldKind.game,title:'Game World',description:'The Game World'));
  @override void dispose(){clock.dispose();super.dispose();}
  void enterWorld(){setState(()=>worldOpen=true);GalaxyNavigationSession.instance.selected=GalaxyWorldKind.game.name;widget.onWorldTap?.call(gameWorld);}
  @override Widget build(BuildContext context)=>Scaffold(backgroundColor:const Color(0xFF02040A),body:Stack(fit:StackFit.expand,children:[CustomPaint(painter:_DeepSpacePainter(clock)),AnimatedSwitcher(duration:const Duration(milliseconds:750),switchInCurve:Curves.easeOutCubic,switchOutCurve:Curves.easeInCubic,child:worldOpen?_GameWorldView(key:const ValueKey('game-world'),clock:clock):_GamePlanetView(key:const ValueKey('game-planet'),clock:clock,onEnter:enterWorld)),if(worldOpen)Positioned(top:28,left:28,child:_BackButton(onTap:()=>setState(()=>worldOpen=false)))]));
}

class _GamePlanetView extends StatelessWidget { final Animation<double> clock; final VoidCallback onEnter; const _GamePlanetView({super.key,required this.clock,required this.onEnter});
  @override Widget build(BuildContext context)=>Center(child:LayoutBuilder(builder:(context,box){final size=math.min(box.maxWidth,box.maxHeight)*.58;return GestureDetector(onTap:onEnter,child:SizedBox(width:size,height:size,child:Stack(alignment:Alignment.center,children:[CustomPaint(size:Size.square(size),painter:_PlanetAtmosphere(clock)),CustomPaint(size:Size.square(size),painter:_GamePlanetPainter(clock)),Positioned(bottom:size*.07,child:Text('GAME',style:TextStyle(color:Colors.white.withValues(alpha:.80),fontSize:math.max(12,size*.032),letterSpacing:math.max(4,size*.011),fontWeight:FontWeight.w500)))])));}));
}

class _GameWorldView extends StatelessWidget { final Animation<double> clock; const _GameWorldView({super.key,required this.clock});
  @override Widget build(BuildContext context)=>LayoutBuilder(builder:(context,box)=>Center(child:SizedBox(width:box.maxWidth*.94,height:box.maxHeight*.86,child:CustomPaint(painter:_IslandGameWorldPainter(clock)))));
}
class _BackButton extends StatelessWidget { final VoidCallback onTap; const _BackButton({required this.onTap}); @override Widget build(BuildContext context)=>GestureDetector(onTap:onTap,child:Container(padding:const EdgeInsets.symmetric(horizontal:14,vertical:8),decoration:BoxDecoration(color:const Color(0x66101722),border:Border.all(color:const Color(0x335C6F87)),borderRadius:BorderRadius.circular(20)),child:Text('GAME PLANET',style:TextStyle(color:Colors.white.withValues(alpha:.72),fontSize:11,letterSpacing:1.8)))); }

class _DeepSpacePainter extends CustomPainter { final Animation<double> clock; _DeepSpacePainter(this.clock):super(repaint:clock);
  @override void paint(Canvas canvas,Size size){final r=Offset.zero&size;canvas.drawRect(r,Paint()..shader=const RadialGradient(center:Alignment(0,-.12),radius:1.1,colors:[Color(0xFF111A2B),Color(0xFF070B15),Color(0xFF020309)]).createShader(r));final star=Paint();final random=math.Random(9127);for(var i=0;i<150;i++){final x=random.nextDouble()*size.width,y=random.nextDouble()*size.height;star.color=Colors.white.withValues(alpha:.10+.07*math.sin(clock.value*math.pi*2+i));canvas.drawCircle(Offset(x,y),.35+random.nextDouble()*.55,star);}}
  @override bool shouldRepaint(covariant _DeepSpacePainter oldDelegate)=>false;
}

class _PlanetAtmosphere extends CustomPainter { final Animation<double> clock; _PlanetAtmosphere(this.clock):super(repaint:clock);
  @override void paint(Canvas canvas,Size size){final c=Offset(size.width/2,size.height/2),r=size.width*.33;final glow=Paint()..shader=RadialGradient(colors:[const Color(0x553D5FA0),const Color(0x202D3E7A),Colors.transparent],stops:const [.55,.76,1]).createShader(Rect.fromCircle(center:c,radius:r*1.55));canvas.drawCircle(c,r*1.55,glow);final rim=Paint()..style=PaintingStyle.stroke..strokeWidth=2.8..shader=const SweepGradient(colors:[Color(0x00788FD4),Color(0xAA8C8CDA),Color(0x005B78B8),Color(0x006C7DC5)]).createShader(Rect.fromCircle(center:c,radius:r*1.025));canvas.drawCircle(c,r*1.025,rim);final haze=Paint()..style=PaintingStyle.stroke..strokeWidth=7..color=const Color(0x183F5E9A);canvas.drawArc(Rect.fromCircle(center:c,radius:r*1.035),-1.05,1.55,false,haze);}
  @override bool shouldRepaint(covariant _PlanetAtmosphere oldDelegate)=>true;
}

class _GamePlanetPainter extends CustomPainter { final Animation<double> clock; _GamePlanetPainter(this.clock):super(repaint:clock);
  @override void paint(Canvas canvas,Size size){final c=Offset(size.width/2,size.height/2),r=size.width*.33,rect=Rect.fromCircle(center:c,radius:r);
    canvas.drawCircle(c,r,Paint()..shader=const RadialGradient(center:Alignment(-.46,-.50),radius:.92,colors:[Color(0xFF586B83),Color(0xFF263A55),Color(0xFF111B31),Color(0xFF030711)],stops:[0,.34,.68,1]).createShader(rect));
    final land=Paint();final rng=math.Random(4207);
    final continents=<List<Offset>>[
      [Offset(.23,.31),Offset(.34,.24),Offset(.47,.28),Offset(.50,.39),Offset(.43,.47),Offset(.29,.44),Offset(.20,.36)],
      [Offset(.56,.20),Offset(.73,.24),Offset(.80,.34),Offset(.73,.43),Offset(.61,.39),Offset(.54,.30)],
      [Offset(.34,.56),Offset(.47,.51),Offset(.58,.58),Offset(.62,.72),Offset(.51,.80),Offset(.39,.73),Offset(.31,.64)],
    ];
    for(var j=0;j<continents.length;j++){final pts=continents[j];final path=Path()..moveTo(c.dx+(pts[0].dx-.5)*r*2,c.dy+(pts[0].dy-.5)*r*2);for(var i=1;i<pts.length;i++)path.lineTo(c.dx+(pts[i].dx-.5)*r*2,c.dy+(pts[i].dy-.5)*r*2);path.close();land.color=const Color(0x553F5268);canvas.drawPath(path,land);canvas.drawPath(path,Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0x557A86A0));}
    final cloud=Paint()..style=PaintingStyle.stroke..strokeWidth=2.2..color=const Color(0x1ECDD7E0);for(var i=0;i<8;i++){final a=rng.nextDouble()*math.pi*2;final rr=math.sqrt(rng.nextDouble())*r*.75;final p=Offset(c.dx+math.cos(a)*rr,c.dy+math.sin(a)*rr*.67);canvas.drawOval(Rect.fromCenter(center:p,width:r*(.18+rng.nextDouble()*.20),height:r*(.025+rng.nextDouble()*.035)),cloud);}
    canvas.drawCircle(c,r,Paint()..shader=RadialGradient(center:const Alignment(.62,.54),colors:[const Color(0xCC000000),const Color(0x55000000),Colors.transparent],stops:const [0,.55,1]).createShader(rect));
    canvas.drawCircle(c,r,Paint()..style=PaintingStyle.stroke..strokeWidth=1.2..color=const Color(0x668FA4C5));
  }
  @override bool shouldRepaint(covariant _GamePlanetPainter oldDelegate)=>true;
}

class _IslandGameWorldPainter extends CustomPainter { final Animation<double> clock; _IslandGameWorldPainter(this.clock):super(repaint:clock);
  Path island(Size s,List<Offset> pts){final p=Path()..moveTo(pts.first.dx*s.width,pts.first.dy*s.height);for(var i=1;i<pts.length;i++){final a=pts[i-1],b=pts[i],mid=Offset((a.dx+b.dx)*s.width*.5,(a.dy+b.dy)*s.height*.5);p.quadraticBezierTo(a.dx*s.width,a.dy*s.height,mid.dx,mid.dy);}return p..quadraticBezierTo(pts.last.dx*s.width,pts.last.dy*s.height,pts.first.dx*s.width,pts.first.dy*s.height)..close();}
  void drawIsland(Canvas c,Size s,List<Offset> pts,Color base,double scale,{bool main=false}){final path=island(s,pts),b=path.getBounds();c.drawPath(path.shift(Offset(0,12*scale)),Paint()..color=const Color(0x99000000));c.drawPath(path,Paint()..shader=LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[base.withValues(alpha:.98),base.withValues(alpha:.90),const Color(0xFF111B24)]).createShader(b));final shelf=Path()..addOval(Rect.fromCenter(center:b.center.translate(0,3),width:b.width*.90,height:b.height*.78));c.drawPath(shelf,Paint()..style=PaintingStyle.stroke..strokeWidth=main?4.0:2.4..color=const Color(0x286D8A8E));c.drawPath(path,Paint()..style=PaintingStyle.stroke..strokeWidth=1.35*scale..color=const Color(0x777D8EA0));}
  void terrain(Canvas c,Rect area,int seed,{bool ridges=false}){final rng=math.Random(seed);final p=Paint()..style=PaintingStyle.stroke..strokeWidth=ridges?1.35:1..color=ridges?const Color(0x50647782):const Color(0x2B657681);for(var i=0;i<(ridges?10:7);i++){final cx=area.left+area.width*(.12+rng.nextDouble()*.76),cy=area.top+area.height*(.16+rng.nextDouble()*.68);final rx=area.width*(.035+rng.nextDouble()*.13),ry=area.height*(.025+rng.nextDouble()*.11);c.drawOval(Rect.fromCenter(center:Offset(cx,cy),width:rx*2,height:ry*2),p);}}
  void plateau(Canvas c,Offset center,double w,double h,int seed){final r=Rect.fromCenter(center:center,width:w,height:h);c.drawOval(r.shift(const Offset(0,6)),Paint()..color=const Color(0x55000000));c.drawOval(r,Paint()..shader=const RadialGradient(center:Alignment(-.25,-.35),colors:[Color(0xFF75837D),Color(0xFF4B5B59),Color(0xFF27353A)]).createShader(r));terrain(c,r,seed,ridges:true);}
  @override void paint(Canvas canvas,Size s){final full=Offset.zero&s;canvas.drawRect(full,Paint()..shader=const RadialGradient(center:Alignment(.08,-.18),radius:1.05,colors:[Color(0xFF24415A),Color(0xFF0D2032),Color(0xFF020811)]).createShader(full));
    final water=Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0x224C819D);for(var i=0;i<7;i++){final rr=Rect.fromCenter(center:Offset(s.width*.51,s.height*.49),width:s.width*(.30+i*.11),height:s.height*(.18+i*.07));canvas.drawOval(rr,water);}
    final main=[const Offset(.12,.46),const Offset(.18,.34),const Offset(.31,.25),const Offset(.45,.20),const Offset(.58,.24),const Offset(.69,.35),const Offset(.66,.49),const Offset(.58,.62),const Offset(.43,.73),const Offset(.28,.69),const Offset(.17,.59)];drawIsland(canvas,s,main,const Color(0xFF5A6D69),1,main:true);
    drawIsland(canvas,s,[const Offset(.67,.12),const Offset(.78,.08),const Offset(.90,.15),const Offset(.88,.28),const Offset(.76,.34),const Offset(.67,.26)],const Color(0xFF465B62),.74);
    drawIsland(canvas,s,[const Offset(.03,.25),const Offset(.12,.14),const Offset(.24,.18),const Offset(.29,.30),const Offset(.18,.39),const Offset(.07,.34)],const Color(0xFF4E6063),.72);
    drawIsland(canvas,s,[const Offset(.69,.66),const Offset(.81,.59),const Offset(.94,.65),const Offset(.89,.80),const Offset(.76,.83),const Offset(.68,.75)],const Color(0xFF40535D),.70);
    drawIsland(canvas,s,[const Offset(.18,.76),const Offset(.29,.72),const Offset(.39,.81),const Offset(.32,.93),const Offset(.16,.86)],const Color(0xFF3D4E58),.66);
    plateau(canvas,Offset(s.width*.39,s.height*.39),s.width*.22,s.height*.15,8101);plateau(canvas,Offset(s.width*.52,s.height*.54),s.width*.17,s.height*.12,8102);
    terrain(canvas,Rect.fromLTWH(s.width*.18,s.height*.23,s.width*.48,s.height*.48),7301,ridges:true);terrain(canvas,Rect.fromLTWH(s.width*.68,s.height*.12,s.width*.23,s.height*.20),7302);terrain(canvas,Rect.fromLTWH(s.width*.70,s.height*.61,s.width*.23,s.height*.22),7303);
    final route=Paint()..style=PaintingStyle.stroke..strokeWidth=1.3..color=const Color(0x4B91A0A6);final path=Path()..moveTo(s.width*.27,s.height*.57)..quadraticBezierTo(s.width*.37,s.height*.49,s.width*.46,s.height*.54)..quadraticBezierTo(s.width*.55,s.height*.57,s.width*.60,s.height*.40);canvas.drawPath(path,route);
    final pulse=.84+.16*math.sin(clock.value*math.pi*2);final node=Paint()..color=const Color(0x7A9DABB0);for(final n in [const Offset(.29,.52),const Offset(.46,.54),const Offset(.60,.40),const Offset(.79,.22)])canvas.drawCircle(Offset(n.dx*s.width,n.dy*s.height),2.0*pulse,node);
    canvas.drawRect(full,Paint()..shader=const RadialGradient(center:Alignment(0,-.10),radius:1,colors:[Colors.transparent,Color(0x16020A14),Color(0x62020812)]).createShader(full));
  }
  @override bool shouldRepaint(covariant _IslandGameWorldPainter oldDelegate)=>true;
}
