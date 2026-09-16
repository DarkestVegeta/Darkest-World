import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../screens/galaxy_navigation_session.dart';

enum GalaxyWorldKind { vegeta, game, identity, cinema, creation, music, family, archive, comingSoon }

class GalaxyWorld { final GalaxyWorldKind kind; final String title; final String description; const GalaxyWorld({required this.kind, required this.title, required this.description}); }

class DarkestWorldUniverse extends StatefulWidget {
  final List<GalaxyWorld> worlds; final ValueChanged<GalaxyWorld>? onWorldTap;
  const DarkestWorldUniverse({super.key,required this.worlds,this.onWorldTap});
  @override State<DarkestWorldUniverse> createState()=>_DarkestWorldUniverseState();
}
class _DarkestWorldUniverseState extends State<DarkestWorldUniverse> with SingleTickerProviderStateMixin {
  late final AnimationController clock=AnimationController(vsync:this,duration:const Duration(seconds:180))..repeat(); int? focused;
  @override void dispose(){clock.dispose();super.dispose();}
  void tap(int i){setState(()=>focused=focused==i?null:i);GalaxyNavigationSession.instance.selected=widget.worlds[i].kind.name;widget.onWorldTap?.call(widget.worlds[i]);}
  @override Widget build(BuildContext context){final compact=MediaQuery.sizeOf(context).width<820;return Scaffold(backgroundColor:const Color(0xFF010207),body:AnimatedBuilder(animation:clock,builder:(_,__)=>Stack(fit:StackFit.expand,children:[CustomPaint(painter:_Space(clock.value)),CustomPaint(painter:_GalaxyVeil(clock.value)),CustomPaint(painter:_Orbital(clock.value)),SafeArea(child:Padding(padding:EdgeInsets.all(compact?14:34),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('DARKESTWORLD',style:TextStyle(fontSize:19,letterSpacing:6.4,fontWeight:FontWeight.w500)),const SizedBox(height:6),const Text('THE WORLDS  /  CINEMATIC ATLAS',style:TextStyle(fontSize:6.5,letterSpacing:2.8,color:Color(0x66C0CFD5))),const Spacer(),Center(child:Text(compact?'TAP FOCUS  •  DOUBLE-TAP ENTER WORLD':'1× CLICK FOCUS     2× CLICK ENTER WORLD',style:const TextStyle(fontSize:6.5,letterSpacing:2.1,color:Color(0x55FFFFFF))))]))),Center(child:LayoutBuilder(builder:(_,b){final d=math.min(b.maxWidth*(compact?.93:.68),b.maxHeight*(compact?.58:.72)).toDouble();return SizedBox.square(dimension:d,child:Stack(children:[for(var i=0;i<widget.worlds.length;i++)_PlanetNode(world:widget.worlds[i],index:i,total:widget.worlds.length,diameter:d,phase:clock.value,selected:focused==i,onTap:()=>tap(i),onOpen:()=>widget.onWorldTap?.call(widget.worlds[i])),const Center(child:_Sun())]));})),if(focused!=null)Positioned(left:compact?14:34,right:compact?14:34,bottom:compact?48:60,child:_WorldPanel(world:widget.worlds[focused!],index:focused!,close:()=>setState(()=>focused=null),open:()=>widget.onWorldTap?.call(widget.worlds[focused!])))])));}
}
class _PlanetNode extends StatelessWidget { final GalaxyWorld world; final int index,total; final double diameter,phase; final bool selected; final VoidCallback onTap,onOpen; const _PlanetNode({required this.world,required this.index,required this.total,required this.diameter,required this.phase,required this.selected,required this.onTap,required this.onOpen}); @override Widget build(BuildContext context){final c=diameter/2;final orbit=diameter*(.20+(index%4)*.075);final a=-math.pi/2+index*math.pi*2/math.max(1,total)+phase*math.pi*.12*(index.isEven?1:-1);final p=Offset(c+math.cos(a)*orbit,c+math.sin(a)*orbit);final d=(selected?diameter*.15:diameter*.10).clamp(54.0,118.0).toDouble();return Positioned(left:p.dx-d/2,top:p.dy-d/2,width:d,height:d+30,child:GestureDetector(onTap:onTap,onDoubleTap:onOpen,child:Stack(children:[Positioned.fill(child:CustomPaint(painter:_PlanetPainter(index:index,selected:selected,phase:phase))),Positioned(left:0,right:0,top:d*.70,child:IgnorePointer(child:Text(world.title.toUpperCase(),textAlign:TextAlign.center,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(color:Colors.white.withValues(alpha:selected?.95:.62),fontSize:math.max(5.5,d*.065),letterSpacing:1.3,fontWeight:selected?FontWeight.w600:FontWeight.w400))))])));}}
class _PlanetPainter extends CustomPainter { final int index; final bool selected; final double phase; const _PlanetPainter({required this.index,required this.selected,required this.phase}); static final Paint _glow=Paint(); static final Paint _body=Paint(); static final Paint _detail=Paint()..style=PaintingStyle.stroke..strokeWidth=.45..color=const Color(0x558FA2A9); static final Paint _rim=Paint()..style=PaintingStyle.stroke; static final Paint _selection=Paint()..style=PaintingStyle.stroke..strokeWidth=1.1..color=const Color(0xA0B7D0D8); @override void paint(Canvas x,Size s){final c=Offset(s.width/2,s.width/2),r=s.width*.30;final base=[const Color(0xFF8E7865),const Color(0xFF647C82),const Color(0xFF857E67),const Color(0xFF75677F),const Color(0xFF70877A),const Color(0xFF7D7063)][index%6];final bounds=Rect.fromCircle(center:c,radius:r);_glow.shader=RadialGradient(colors:[const Color(0x5592B4C1).withValues(alpha:selected?.25:.07),Colors.transparent]).createShader(Rect.fromCircle(center:c,radius:r*1.8));x.drawCircle(c,r*1.8,_glow);_body.shader=RadialGradient(center:const Alignment(-.42,-.5),colors:[base,base.withValues(alpha:.78),const Color(0xFF26313A),const Color(0xFF02050A)]).createShader(bounds);x.drawCircle(c,r,_body);for(var i=1;i<5;i++)x.drawArc(Rect.fromCircle(center:c,radius:r*i/5),math.pi*(.2+i*.06),math.pi*(1.2+i*.1),false,_detail);_rim.strokeWidth=selected?1.5:.65;_rim.color=const Color(0x889FB5BD);x.drawCircle(c,r,_rim);if(selected)x.drawArc(Rect.fromCircle(center:c,radius:r*1.32),phase*math.pi*2,1.4,false,_selection);} @override bool shouldRepaint(covariant _PlanetPainter o)=>o.index!=index||o.selected!=selected||o.phase!=phase;}
class _Sun extends StatelessWidget {const _Sun();@override Widget build(BuildContext c)=>Container(width:86,height:86,decoration:const BoxDecoration(shape:BoxShape.circle,gradient:RadialGradient(colors:[Color(0xFFFFFFFF),Color(0xFFD7C49F),Color(0xFF695845),Color(0x00000000)],stops:[0,.18,.45,1]),boxShadow:[BoxShadow(color:Color(0x665F7480),blurRadius:48,spreadRadius:12)]));}
class _WorldPanel extends StatelessWidget {final GalaxyWorld world;final int index;final VoidCallback close,open;const _WorldPanel({required this.world,required this.index,required this.close,required this.open});@override Widget build(BuildContext c)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:const Color(0xF0070B11),border:Border.all(color:const Color(0x4B829DA8)),boxShadow:const[BoxShadow(color:Colors.black87,blurRadius:40)]),child:Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('WORLD ${(index+1).toString().padLeft(2,'0')} / ATLAS NODE',style:const TextStyle(fontSize:5.5,letterSpacing:1.8,color:Color(0x62FFFFFF))),const SizedBox(height:5),Text(world.title,style:const TextStyle(fontSize:17,letterSpacing:2.8)),const SizedBox(height:4),Text(world.description,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:7.5,color:Color(0x8CC7D2D6),height:1.35))])),TextButton(onPressed:close,child:const Text('×')),FilledButton(onPressed:open,child:const Text('ENTER WORLD'))]));}
class _SpaceStar {final double x,y,size;const _SpaceStar(this.x,this.y,this.size);}
class _Space extends CustomPainter {final double phase;const _Space(this.phase);static final List<_SpaceStar> _stars=List.generate(560,(i){final r=math.Random(912+i*13);return _SpaceStar(r.nextDouble(),r.nextDouble(),r.nextDouble());});static final Paint _background=Paint();static final Paint _star=Paint();@override void paint(Canvas x,Size s){final r=Offset.zero&s;_background.shader=const RadialGradient(colors:[Color(0xFF0A141D),Color(0xFF02060B),Color(0xFF010207)]).createShader(r);x.drawRect(r,_background);for(var i=0;i<_stars.length;i++){final star=_stars[i];final p=Offset(star.x*s.width,star.y*s.height);_star.color=Colors.white.withValues(alpha:.018+.075*((math.sin(phase*math.pi*2+i)+1)/2));x.drawCircle(p,.18+star.size*.62,_star);}}@override bool shouldRepaint(covariant _Space o)=>o.phase!=phase;}

class _GalaxyVeil extends CustomPainter {
  final double phase;
  const _GalaxyVeil(this.phase);

  static final Paint _veil = Paint();
  static final Paint _band = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
  static final Paint _inner = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final short = math.min(size.width, size.height);
    final center = Offset(size.width * .5, size.height * .5);
    final rect = Rect.fromCenter(center: center, width: size.width * .78, height: short * .31);
    final drift = math.sin(phase * math.pi * 2) * .035;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-.16 + drift);
    canvas.translate(-center.dx, -center.dy);

    _veil.shader = const RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [Color(0x071E3850), Color(0x0A6C638B), Color(0x052B4962), Colors.transparent],
      stops: [.0, .34, .68, 1],
    ).createShader(rect);
    canvas.drawOval(rect, _veil);

    _band.strokeWidth = math.max(1.0, short * .0022);
    _band.color = const Color(0x1A81759E);
    canvas.drawArc(rect, phase * math.pi * 2, 2.15, false, _band);

    final innerRect = Rect.fromCenter(center: center, width: size.width * .66, height: short * .18);
    _inner.strokeWidth = math.max(.55, short * .0011);
    _inner.color = const Color(0x126C8A9D);
    canvas.drawArc(innerRect, phase * math.pi * 2 + .9, 1.35, false, _inner);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GalaxyVeil oldDelegate) => oldDelegate.phase != phase;
}

class _Orbital extends CustomPainter {final double phase;const _Orbital(this.phase);static final Paint _rings=Paint()..style=PaintingStyle.stroke..strokeWidth=.45..color=const Color(0x1C8BA5AF);static final Paint _arc=Paint()..style=PaintingStyle.stroke..strokeWidth=1.0..color=const Color(0x527F9BA7);@override void paint(Canvas x,Size s){final c=Offset(s.width*.5,s.height*.5);for(var i=0;i<5;i++){final w=s.width*(.42+i*.10);final h=s.height*(.18+i*.04);x.drawOval(Rect.fromCenter(center:c,width:w,height:h),_rings);}x.drawArc(Rect.fromCenter(center:c,width:s.width*.72,height:s.height*.40),phase*math.pi*2,.75,false,_arc);}@override bool shouldRepaint(covariant _Orbital o)=>o.phase!=phase;}
