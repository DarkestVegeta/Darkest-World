import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../screens/galaxy_navigation_session.dart';

enum GalaxyWorldKind { vegeta, game, identity, cinema, creation, music, family, archive, comingSoon }

class GalaxyWorld { final GalaxyWorldKind kind; final String title; final String description; const GalaxyWorld({required this.kind,required this.title,required this.description}); }

/// Game-only visual core. CreateWorld references define the visual language;
/// the island composition is a strong structural guide, never a literal copy.
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
  @override Widget build(BuildContext context)=>Center(child:LayoutBuilder(builder:(context,box){final size=math.min(box.maxWidth,box.maxHeight)*.55;return GestureDetector(onTap:onEnter,child:SizedBox(width:size,height:size,child:Stack(alignment:Alignment.center,children:[CustomPaint(size:Size.square(size),painter:_PlanetAtmosphere(clock)),CustomPaint(size:Size.square(size),painter:_GamePlanetPainter(clock)),Positioned(bottom:size*.08,child:Text('GAME',style:TextStyle(color:Colors.white.withValues(alpha:.86),fontSize:math.max(13,size*.035),letterSpacing:math.max(4,size*.012),fontWeight:FontWeight.w500)))])));}));
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
  @override void paint(Canvas canvas,Size size){final c=Offset(size.width/2,size.height/2),r=size.width*.315;canvas.drawCircle(c,r*1.30,Paint()..shader=RadialGradient(colors:[const Color(0x443F6DAA),const Color(0x18283F72),Colors.transparent]).createShader(Rect.fromCircle(center:c,radius:r*1.30)));final rim=Paint()..style=PaintingStyle.stroke..strokeWidth=2.2..shader=const SweepGradient(colors:[Color(0x008EA8E2),Color(0x997B8FD0),Color(0x005B6B9D)]).createShader(Rect.fromCircle(center:c,radius:r*1.04));canvas.drawCircle(c,r*1.04,rim);}
  @override bool shouldRepaint(covariant _PlanetAtmosphere oldDelegate)=>true;
}

class _GamePlanetPainter extends CustomPainter { final Animation<double> clock; _GamePlanetPainter(this.clock):super(repaint:clock);
  @override void paint(Canvas canvas,Size size){final c=Offset(size.width/2,size.height/2),r=size.width*.315;canvas.drawCircle(c,r,Paint()..shader=const RadialGradient(center:Alignment(-.45,-.48),radius:.86,colors:[Color(0xFF75839B),Color(0xFF414E68),Color(0xFF1B263A),Color(0xFF050911)],stops:[0,.34,.70,1]).createShader(Rect.fromCircle(center:c,radius:r)));
    final rng=math.Random(4207);final land=Paint();for(var i=0;i<22;i++){final a=rng.nextDouble()*math.pi*2;final rr=math.sqrt(rng.nextDouble())*r*.76;final p=Offset(c.dx+math.cos(a)*rr,c.dy+math.sin(a)*rr*.70);final rw=5+rng.nextDouble()*20;land.color=Color.lerp(const Color(0xFF7F8790),const Color(0xFF202A3A),rng.nextDouble())!.withValues(alpha:.18+rng.nextDouble()*.18);canvas.drawOval(Rect.fromCenter(center:p,width:rw,height:rw*.5),land);}
    canvas.drawCircle(c,r,Paint()..shader=RadialGradient(center:const Alignment(.62,.55),colors:[const Color(0xAA000000),const Color(0x22000000),Colors.transparent]).createShader(Rect.fromCircle(center:c,radius:r)));canvas.drawCircle(c,r,Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0x6694A7C4));}
  @override bool shouldRepaint(covariant _GamePlanetPainter oldDelegate)=>true;
}

class _IslandGameWorldPainter extends CustomPainter { final Animation<double> clock; _IslandGameWorldPainter(this.clock):super(repaint:clock);
  Path island(Size s,List<Offset> pts){final p=Path()..moveTo(pts.first.dx*s.width,pts.first.dy*s.height);for(var i=1;i<pts.length;i++)p.lineTo(pts[i].dx*s.width,pts[i].dy*s.height);return p..close();}
  void drawIsland(Canvas c,Size s,List<Offset> pts,Color base,double scale,{bool main=false}){
    final path=island(s,pts),b=path.getBounds();
    c.drawPath(path.shift(Offset(0,11*scale)),Paint()..color=const Color(0x99000000));
    c.drawPath(path,Paint()..shader=LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[base.withValues(alpha:.99),base.withValues(alpha:.90),const Color(0xFF101823)]).createShader(b));
    // A second inner coast gives the land real depth instead of a flat polygon.
    final inner=Path()..addOval(Rect.fromCenter(center:b.center,width:b.width*.84,height:b.height*.76));
    c.drawPath(inner,Paint()..style=PaintingStyle.stroke..strokeWidth=main?2.0:1.15..color=const Color(0x3E9AA9A7));
    c.drawPath(path,Paint()..style=PaintingStyle.stroke..strokeWidth=1.25*scale..color=const Color(0x68758CA4));
  }
  void terrain(Canvas c,Size s,Rect area,int seed,{bool ridges=false}){
    final rng=math.Random(seed);final p=Paint()..style=PaintingStyle.stroke..strokeWidth=ridges?1.25:1..color=ridges?const Color(0x465F7389):const Color(0x305F7389);
    for(var i=0;i<(ridges?11:8);i++){
      final cx=area.left+area.width*(.12+rng.nextDouble()*.76),cy=area.top+area.height*(.16+rng.nextDouble()*.68);
      final rx=area.width*(.035+rng.nextDouble()*.13),ry=area.height*(.025+rng.nextDouble()*.11);
      c.drawOval(Rect.fromCenter(center:Offset(cx,cy),width:rx*2,height:ry*2),p);
    }
  }
  void plateau(Canvas c,Size s,Offset center,double w,double h,int seed){
    final r=Rect.fromCenter(center:center,width:w,height:h);
    c.drawOval(r.shift(const Offset(0,5)),Paint()..color=const Color(0x55000000));
    c.drawOval(r,Paint()..shader=RadialGradient(center:const Alignment(-.25,-.35),colors:[const Color(0xFF7B8780),const Color(0xFF4B5A58),const Color(0xFF29363A)]).createShader(r));
    terrain(c,s,r,seed,ridges:true);
  }
  @override void paint(Canvas canvas,Size s){
    final full=Offset.zero&s;
    canvas.drawRect(full,Paint()..shader=const RadialGradient(center:Alignment(.08,-.18),radius:1.0,colors:[Color(0xFF20354A),Color(0xFF0B1829),Color(0xFF020811)]).createShader(full));
    // Broad, quiet water rings create the feeling of a large world rather than a UI panel.
    final water=Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0x1D477B9A);
    for(var i=0;i<8;i++){final rr=Rect.fromCenter(center:Offset(s.width*.52,s.height*.49),width:s.width*(.27+i*.105),height:s.height*(.17+i*.068));canvas.drawOval(rr,water);}
    // Main landmass: asymmetrical, layered and dominant, following the reference's island hierarchy.
    final main=[const Offset(.15,.46),const Offset(.20,.34),const Offset(.32,.24),const Offset(.47,.20),const Offset(.61,.27),const Offset(.68,.40),const Offset(.64,.56),const Offset(.55,.67),const Offset(.39,.73),const Offset(.25,.66),const Offset(.17,.56)];
    drawIsland(canvas,s,main,const Color(0xFF596A68),1.0,main:true);
    drawIsland(canvas,s,[const Offset(.68,.13),const Offset(.78,.09),const Offset(.90,.15),const Offset(.88,.29),const Offset(.76,.33),const Offset(.68,.26)],const Color(0xFF465963),.74);
    drawIsland(canvas,s,[const Offset(.04,.25),const Offset(.13,.14),const Offset(.25,.19),const Offset(.28,.31),const Offset(.16,.38),const Offset(.07,.34)],const Color(0xFF4C5C61),.72);
    drawIsland(canvas,s,[const Offset(.69,.66),const Offset(.81,.59),const Offset(.93,.65),const Offset(.89,.79),const Offset(.76,.82),const Offset(.69,.75)],const Color(0xFF40515B),.70);
    drawIsland(canvas,s,[const Offset(.18,.75),const Offset(.29,.73),const Offset(.38,.81),const Offset(.31,.92),const Offset(.17,.86)],const Color(0xFF3D4D57),.66);
    // Raised terrain makes the main island read as land with elevation, not a flat map.
    plateau(canvas,s,Offset(s.width*.39,s.height*.39),s.width*.23,s.height*.15,8101);
    plateau(canvas,s,Offset(s.width*.52,s.height*.54),s.width*.18,s.height*.12,8102);
    terrain(canvas,s,Rect.fromLTWH(s.width*.19,s.height*.24,s.width*.47,s.height*.45),7301,ridges:true);
    terrain(canvas,s,Rect.fromLTWH(s.width*.68,s.height*.13,s.width*.23,s.height*.19),7302);
    terrain(canvas,s,Rect.fromLTWH(s.width*.70,s.height*.61,s.width*.23,s.height*.21),7303);
    // One restrained route ties the elevations together without turning the world into a dashboard.
    final route=Paint()..style=PaintingStyle.stroke..strokeWidth=1.5..color=const Color(0x50869AA9);
    final path=Path()..moveTo(s.width*.27,s.height*.57)..quadraticBezierTo(s.width*.37,s.height*.49,s.width*.46,s.height*.54)..quadraticBezierTo(s.width*.55,s.height*.57,s.width*.60,s.height*.40);canvas.drawPath(path,route);
    final nodes=[const Offset(.29,.52),const Offset(.46,.54),const Offset(.60,.40),const Offset(.79,.22),const Offset(.16,.28),const Offset(.81,.70)];
    final node=Paint()..color=const Color(0x9A9BAFC5);for(var i=0;i<nodes.length;i++){final q=Offset(nodes[i].dx*s.width,nodes[i].dy*s.height);final pulse=.82+.20*math.sin(clock.value*math.pi*2+i);canvas.drawCircle(q,2.35*pulse,node);}
    // Atmospheric veil at the far edges keeps the world spatial and cinematic.
    canvas.drawRect(full,Paint()..shader=const RadialGradient(center:Alignment(0,-.10),radius:1.0,colors:[Colors.transparent,Color(0x18020A14),Color(0x60020812)]).createShader(full));
    final title=TextPainter(text:TextSpan(text:'GAME WORLD',style:TextStyle(color:Colors.white.withValues(alpha:.72),fontSize:math.max(13,s.width*.018),letterSpacing:4.2,fontWeight:FontWeight.w500)),textDirection:TextDirection.ltr)..layout();title.paint(canvas,Offset((s.width-title.width)/2,s.height*.94));
  }
  @override bool shouldRepaint(covariant _IslandGameWorldPainter oldDelegate)=>true;
}
