import 'dart:math' as math;
import 'package:flutter/material.dart';

enum GalaxyWorldKind { vegeta, game, identity, cinema, creation, music, family, archive, comingSoon }

class GalaxyWorld {
  final GalaxyWorldKind kind;
  final String title;
  final String description;
  const GalaxyWorld({required this.kind, required this.title, required this.description});
}

class DarkestWorldUniverse extends StatefulWidget {
  final List<GalaxyWorld> worlds;
  final ValueChanged<GalaxyWorld>? onWorldTap;
  const DarkestWorldUniverse({super.key, required this.worlds, this.onWorldTap});
  @override State<DarkestWorldUniverse> createState() => _DarkestWorldUniverseState();
}

class _DarkestWorldUniverseState extends State<DarkestWorldUniverse> {
  GalaxyWorldKind? selected;
  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    GalaxyWorld? current;
    for (final world in widget.worlds) { if (world.kind == selected) { current = world; break; } }
    return Scaffold(
      backgroundColor: const Color(0xFF010106),
      body: Stack(fit: StackFit.expand, children: [
        const _GalaxyBackground(),
        _GalaxyPlanets(worlds: widget.worlds, compact: compact, selected: selected, onSelect: (world) => setState(() => selected = selected == world.kind ? null : world.kind)),
        Positioned(left: compact ? 18 : 34, top: compact ? 18 : 28, child: const Text('DARKESTWORLD', style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 5, fontWeight: FontWeight.w300))),
        if (current != null) Positioned(right: compact ? 14 : 34, bottom: compact ? 14 : 34, width: compact ? 260 : 340, child: _SelectionPanel(world: current!, onClose: () => setState(() => selected = null), onEnter: () => widget.onWorldTap?.call(current!))),
      ]),
    );
  }
}

class _GalaxyBackground extends StatelessWidget { const _GalaxyBackground(); @override Widget build(BuildContext context) => CustomPaint(painter: _GalaxyBackgroundPainter()); }
class _GalaxyBackgroundPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0,-.12), radius: 1.15, colors: [Color(0xFF19152B),Color(0xFF070711),Color(0xFF010105)]).createShader(rect));
    final r = math.Random(17);
    for (var i=0;i<230;i++) canvas.drawCircle(Offset(r.nextDouble()*size.width,r.nextDouble()*size.height),.2+r.nextDouble()*.8,Paint()..color=Colors.white.withValues(alpha:.05+r.nextDouble()*.14));
    final haze = Paint()..shader = RadialGradient(colors:[const Color(0xFF5A3B78).withValues(alpha:.09),Colors.transparent]).createShader(Rect.fromCircle(center:Offset(size.width*.52,size.height*.48),radius:size.width*.48));
    canvas.drawCircle(Offset(size.width*.52,size.height*.48),size.width*.48,haze);
  }
  @override bool shouldRepaint(covariant _GalaxyBackgroundPainter oldDelegate)=>false;
}

class _GalaxyPlanets extends StatelessWidget {
  final List<GalaxyWorld> worlds; final bool compact; final GalaxyWorldKind? selected; final ValueChanged<GalaxyWorld> onSelect;
  const _GalaxyPlanets({required this.worlds,required this.compact,required this.selected,required this.onSelect});
  static const positions=<GalaxyWorldKind,Offset>{GalaxyWorldKind.vegeta:Offset(.50,.53),GalaxyWorldKind.game:Offset(.78,.25),GalaxyWorldKind.identity:Offset(.20,.34),GalaxyWorldKind.cinema:Offset(.84,.59),GalaxyWorldKind.creation:Offset(.22,.73),GalaxyWorldKind.music:Offset(.61,.81),GalaxyWorldKind.family:Offset(.39,.17),GalaxyWorldKind.archive:Offset(.09,.56),GalaxyWorldKind.comingSoon:Offset(.91,.80)};
  static const factors=<GalaxyWorldKind,double>{GalaxyWorldKind.vegeta:.34,GalaxyWorldKind.game:.205,GalaxyWorldKind.identity:.175,GalaxyWorldKind.cinema:.165,GalaxyWorldKind.creation:.155,GalaxyWorldKind.music:.14,GalaxyWorldKind.family:.125,GalaxyWorldKind.archive:.095,GalaxyWorldKind.comingSoon:.08};
  @override Widget build(BuildContext context){final s=MediaQuery.sizeOf(context),base=math.min(s.width,s.height);return Stack(fit:StackFit.expand,children:[for(final world in worlds.where((w)=>positions.containsKey(w.kind))) Positioned(left:s.width*positions[world.kind]!.dx,top:s.height*positions[world.kind]!.dy,child:Transform.translate(offset:Offset(-_size(base,world.kind)/2,-_size(base,world.kind)/2),child:_Planet(world:world,size:_size(base,world.kind),muted:selected!=null&&selected!=world.kind,onTap:()=>onSelect(world))))]);}
  double _size(double base,GalaxyWorldKind kind)=>math.max(72,base*(factors[kind]??.1));
}

class _Planet extends StatelessWidget {
  final GalaxyWorld world; final double size; final bool muted; final VoidCallback onTap;
  const _Planet({required this.world,required this.size,required this.muted,required this.onTap});
  @override Widget build(BuildContext context){
    final accent=world.kind==GalaxyWorldKind.vegeta?const Color(0xFF9B76C9):const Color(0xFF7185A9);
    return GestureDetector(onTap:onTap,child:Opacity(opacity:muted?.22:1,child:SizedBox(width:size,child:Column(mainAxisSize:MainAxisSize.min,children:[SizedBox(width:size,height:size,child:CustomPaint(painter:_WorldPlanetPainter(seed:world.kind.index+21,accent:accent))),const SizedBox(height:7),Text(world.title,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(color:Colors.white70,fontSize:world.kind==GalaxyWorldKind.vegeta?11:8,letterSpacing:world.kind==GalaxyWorldKind.vegeta?3:1.7))]))));
  }
}

class _WorldPlanetPainter extends CustomPainter {
  final int seed; final Color accent;
  const _WorldPlanetPainter({required this.seed,required this.accent});
  @override void paint(Canvas canvas,Size size){
    final c=Offset(size.width*.5,size.height*.5),r=size.shortestSide*.435,sphere=Rect.fromCircle(center:c,radius:r);
    canvas.drawCircle(c,r*1.24,Paint()..shader=RadialGradient(colors:[accent.withValues(alpha:.30),accent.withValues(alpha:.07),Colors.transparent],stops:const[0,.48,1]).createShader(Rect.fromCircle(center:c,radius:r*1.24)));
    canvas.drawCircle(c,r,Paint()..shader=const RadialGradient(center:Alignment(-.46,-.54),radius:1.12,colors:[Color(0xFFB0A9AA),Color(0xFF6E6D78),Color(0xFF303441),Color(0xFF080A10)],stops:[0,.30,.67,1]).createShader(sphere));
    canvas.save(); canvas.clipPath(Path()..addOval(sphere));
    final rnd=math.Random(seed*137);
    final landColors=[accent.withValues(alpha:.42),const Color(0xFFB29C78).withValues(alpha:.27),const Color(0xFF60766B).withValues(alpha:.30),const Color(0xFF484B59).withValues(alpha:.28)];
    // A few large, coherent continental masses rather than random spots.
    for(var i=0;i<4;i++){
      final angle=i*1.72+rnd.nextDouble()*.45;
      final cx=c.dx+math.cos(angle)*r*.30, cy=c.dy+math.sin(angle)*r*.27;
      final w=r*(.34+rnd.nextDouble()*.25),h=r*(.16+rnd.nextDouble()*.16);
      final path=_landmass(Offset(cx,cy),w,h,angle*.35,rnd,15);
      canvas.drawPath(path,Paint()..color=landColors[i]);
      canvas.drawPath(path,Paint()..style=PaintingStyle.stroke..strokeWidth=.65..color=Colors.white.withValues(alpha:.08));
      // contour ridges make the surface read as terrain, not stickers.
      for(var q=1;q<=3;q++){
        final rr=1-q*.15;
        canvas.drawPath(_landmass(Offset(cx-r*.025*q,cy+r*.018*q),w*rr,h*rr,angle*.35,rnd,15),Paint()..style=PaintingStyle.stroke..strokeWidth=.55..color=Colors.white.withValues(alpha:.035));
      }
    }
    for(var i=0;i<42;i++){
      final x=c.dx+(rnd.nextDouble()*2-1)*r*.82,y=c.dy+(rnd.nextDouble()*2-1)*r*.72;
      canvas.drawCircle(Offset(x,y),r*(.002+rnd.nextDouble()*.009),Paint()..color=Colors.white.withValues(alpha:.035+rnd.nextDouble()*.045));
    }
    canvas.restore();
    // A soft terminator gives the planet photographic depth.
    final shadow=c+Offset(r*.47,r*.07);
    canvas.drawCircle(shadow,r*.86,Paint()..shader=RadialGradient(colors:[Colors.transparent,Colors.black.withValues(alpha:.68)],stops:const[.42,1]).createShader(Rect.fromCircle(center:shadow,radius:r*.86)));
    canvas.drawArc(Rect.fromCircle(center:c,radius:r*1.005),math.pi*.60,math.pi*.88,false,Paint()..style=PaintingStyle.stroke..strokeWidth=1.25..color=Colors.white.withValues(alpha:.22));
    canvas.drawArc(Rect.fromCircle(center:c+Offset(-r*.035,-r*.035),radius:r*.93),math.pi*1.02,math.pi*.42,false,Paint()..style=PaintingStyle.stroke..strokeWidth=r*.035..color=Colors.white.withValues(alpha:.035));
  }
  Path _landmass(Offset c,double w,double h,double rot,math.Random rnd,int n){final p=Path();for(var i=0;i<n;i++){final a=i/n*math.pi*2;final wob=.78+rnd.nextDouble()*.44;var x=math.cos(a)*w*.5*wob,y=math.sin(a)*h*.5*wob;final xr=x*math.cos(rot)-y*math.sin(rot),yr=x*math.sin(rot)+y*math.cos(rot);if(i==0)p.moveTo(c.dx+xr,c.dy+yr);else p.lineTo(c.dx+xr,c.dy+yr);}p.close();return p;}
  @override bool shouldRepaint(covariant _WorldPlanetPainter oldDelegate)=>false;
}

class _SelectionPanel extends StatelessWidget{final GalaxyWorld world;final VoidCallback onClose,onEnter;const _SelectionPanel({required this.world,required this.onClose,required this.onEnter});@override Widget build(BuildContext context)=>Material(color:Colors.transparent,child:Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:const Color(0xE6090914),border:Border.all(color:Colors.white12),borderRadius:BorderRadius.circular(18)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[Text(world.title,style:const TextStyle(color:Colors.white,fontSize:16,letterSpacing:2)),const SizedBox(height:8),Text(world.description,style:const TextStyle(color:Colors.white54)),const SizedBox(height:14),Row(children:[TextButton(onPressed:onClose,child:const Text('Sluiten')),const Spacer(),ElevatedButton(onPressed:onEnter,child:const Text('Openen'))])]));}
