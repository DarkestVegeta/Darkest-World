import 'dart:math' as math;
import 'package:flutter/material.dart';

enum GalaxyWorldKind { vegeta, game, music, identity, family, cinema, creation, archive, comingSoon }

class GalaxyWorld {
  final String title;
  final String description;
  final GalaxyWorldKind kind;
  const GalaxyWorld(this.title, this.description, this.kind);
}

class DarkestWorldUniverse extends StatefulWidget {
  final List<GalaxyWorld> worlds;
  final ValueChanged<GalaxyWorld>? onWorldTap;
  const DarkestWorldUniverse({super.key, required this.worlds, this.onWorldTap});
  @override State<DarkestWorldUniverse> createState() => _DarkestWorldUniverseState();
}

class _DarkestWorldUniverseState extends State<DarkestWorldUniverse> {
  GalaxyWorldKind? hovered, selected;
  GalaxyWorld? find(GalaxyWorldKind k) => widget.worlds.cast<GalaxyWorld?>().firstWhere((w) => w?.kind == k, orElse: () => null);
  @override Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
    final compact = box.maxWidth < 760;
    final size = Size(box.maxWidth, box.maxHeight);
    final current = selected == null ? null : find(selected!);
    return Stack(fit: StackFit.expand, children: [
      const RepaintBoundary(child: CustomPaint(painter: _UniversePainter())),
      Positioned.fill(child: _PlanetField(worlds: widget.worlds, size: size, compact: compact, hovered: hovered, selected: selected,
        onHover: (k) => setState(() => hovered = k), onSelect: (w) => setState(() => selected = w.kind))),
      Positioned(left: compact ? 18 : 34, top: compact ? 18 : 28, child: const _UniverseTitle()),
      if (!compact) Positioned(right: 34, top: 30, child: Text('DARKESTWORLD / UNIVERSE', style: TextStyle(fontSize: 7, letterSpacing: 2.8, color: Colors.white.withValues(alpha: .20)))),
      if (current != null) _SelectionLayer(world: current, compact: compact, onClose: () => setState(() => selected = null), onEnter: () => widget.onWorldTap?.call(current)),
    ]);
  });
}

class _PlanetField extends StatelessWidget {
  final List<GalaxyWorld> worlds; final Size size; final bool compact; final GalaxyWorldKind? hovered, selected;
  final ValueChanged<GalaxyWorldKind?> onHover; final ValueChanged<GalaxyWorld> onSelect;
  const _PlanetField({required this.worlds, required this.size, required this.compact, required this.hovered, required this.selected, required this.onHover, required this.onSelect});
  @override Widget build(BuildContext context) {
    final b = math.min(size.width, size.height);
    final pos = <GalaxyWorldKind, Offset>{
      GalaxyWorldKind.vegeta: Offset(size.width*.50,size.height*.51),
      GalaxyWorldKind.identity: Offset(size.width*.17,size.height*.30), GalaxyWorldKind.game: Offset(size.width*.79,size.height*.29),
      GalaxyWorldKind.cinema: Offset(size.width*.82,size.height*.71), GalaxyWorldKind.creation: Offset(size.width*.20,size.height*.73),
      GalaxyWorldKind.music: Offset(size.width*.53,size.height*.85), GalaxyWorldKind.family: Offset(size.width*.50,size.height*.15),
      GalaxyWorldKind.archive: Offset(size.width*.075,size.height*.53), GalaxyWorldKind.comingSoon: Offset(size.width*.925,size.height*.53),
    };
    final sz = <GalaxyWorldKind,double>{
      GalaxyWorldKind.vegeta:b*(compact?.29:.33), GalaxyWorldKind.identity:b*(compact?.125:.145), GalaxyWorldKind.game:b*(compact?.135:.155),
      GalaxyWorldKind.cinema:b*(compact?.115:.13), GalaxyWorldKind.creation:b*(compact?.115:.13), GalaxyWorldKind.music:b*(compact?.095:.11),
      GalaxyWorldKind.family:b*(compact?.085:.10), GalaxyWorldKind.archive:b*(compact?.06:.07), GalaxyWorldKind.comingSoon:b*(compact?.055:.065),
    };
    return Stack(clipBehavior: Clip.none, children: [for (final w in worlds) if (pos.containsKey(w.kind))
      Positioned(left: pos[w.kind]!.dx-sz[w.kind]!/2, top: pos[w.kind]!.dy-sz[w.kind]!/2,
        child: _PlanetInteraction(world:w,size:sz[w.kind]!,central:w.kind==GalaxyWorldKind.vegeta,
          active:hovered==w.kind||selected==w.kind,onHover:(v)=>onHover(v?w.kind:null),onTap:()=>onSelect(w)))
    ]);
  }
}

class _PlanetInteraction extends StatelessWidget {
  final GalaxyWorld world; final double size; final bool central, active; final ValueChanged<bool> onHover; final VoidCallback onTap;
  const _PlanetInteraction({required this.world,required this.size,required this.central,required this.active,required this.onHover,required this.onTap});
  @override Widget build(BuildContext context) => MouseRegion(cursor:SystemMouseCursors.click,onEnter:(_)=>onHover(true),onExit:(_)=>onHover(false),
    child:GestureDetector(onTap:onTap,child:SizedBox(width:size+112,height:size+80,child:Stack(clipBehavior:Clip.none,alignment:Alignment.topCenter,children:[
      CustomPaint(size:Size.square(size),painter:_PlanetPainter(kind:world.kind,seed:world.kind.index*1783+91,active:active,central:central)),
      Positioned(top:size+9,left:-28,right:-28,child:Text(world.title,textAlign:TextAlign.center,maxLines:1,overflow:TextOverflow.ellipsis,
        style:TextStyle(fontSize:central?11:8,letterSpacing:central?3.6:2.3,color:Colors.white.withValues(alpha:active||central?.82:.48),shadows:const[Shadow(color:Colors.black,blurRadius:14)]))),
      if(active) Positioned(top:size+25,left:-28,right:-28,child:Text('OPEN',textAlign:TextAlign.center,style:TextStyle(fontSize:6,letterSpacing:2.5,color:Colors.white.withValues(alpha:.30)))),
    ]))));
}

class _UniverseTitle extends StatelessWidget { const _UniverseTitle();
  @override Widget build(BuildContext context)=>IgnorePointer(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('DARKESTWORLD',style:TextStyle(fontSize:14,letterSpacing:5.5,color:Colors.white.withValues(alpha:.78))),const SizedBox(height:5),
    Text('THE WORLDS BEYOND',style:TextStyle(fontSize:7,letterSpacing:3.2,color:Colors.white.withValues(alpha:.25))) ]));
}

class _UniversePainter extends CustomPainter {
  const _UniversePainter();
  @override void paint(Canvas c,Size s){
    final rect=Offset.zero&s;
    c.drawRect(rect,Paint()..shader=const RadialGradient(center:Alignment(0,-.10),radius:1.15,colors:[Color(0xFF171426),Color(0xFF070710),Color(0xFF010105)]).createShader(rect));
    final q=math.Random(4817), stars=Paint();
    for(var i=0;i<380;i++){
      final a=.012+q.nextDouble()*.065;
      stars.color=Colors.white.withValues(alpha:a);
      c.drawCircle(Offset(q.nextDouble()*s.width,q.nextDouble()*s.height),.12+q.nextDouble()*.50,stars);
    }
    final haze=Rect.fromCenter(center:Offset(s.width*.50,s.height*.50),width:s.width*.84,height:s.height*.68);
    c.drawOval(haze,Paint()..shader=RadialGradient(colors:[const Color(0xFF69568F).withValues(alpha:.045),const Color(0xFF40536F).withValues(alpha:.016),Colors.transparent]).createShader(haze));
    // A restrained, broad dust glow gives depth without turning the background into a busy galaxy map.
    final dust=Rect.fromCenter(center:Offset(s.width*.50,s.height*.53),width:s.width*.76,height:s.height*.22);
    c.drawOval(dust,Paint()..shader=RadialGradient(colors:[const Color(0xFF8B70B2).withValues(alpha:.018),Colors.transparent]).createShader(dust));
  }
  @override bool shouldRepaint(covariant _UniversePainter old)=>false;
}

class _PlanetPainter extends CustomPainter {
  final GalaxyWorldKind kind; final int seed; final bool active,central;
  const _PlanetPainter({required this.kind,required this.seed,required this.active,required this.central});

  @override void paint(Canvas c,Size s){
    final r=s.width/2, o=s.center(Offset.zero), p=_palette(kind);
    final planet=Rect.fromCircle(center:o,radius:r*.965);
    final haloR=r*(active?1.075:1.035);
    c.drawCircle(o,haloR,Paint()..shader=RadialGradient(colors:[p.glow.withValues(alpha:active?.15:.045),p.glow.withValues(alpha:.018),Colors.transparent],stops:const[0,.34,1]).createShader(Rect.fromCircle(center:o,radius:haloR)));
    c.drawCircle(o,r*.965,Paint()..shader=RadialGradient(center:const Alignment(-.38,-.40),radius:1.02,colors:[p.light,p.base,p.shadow],stops:const[0,.50,1]).createShader(planet));
    c.save();
    c.clipPath(Path()..addOval(planet));
    final q=math.Random(seed);
    _continents(c,o,r,q,p);
    _terrain(c,o,r,q,p);
    _atmosphereBands(c,o,r,q,p);
    _craters(c,o,r,q,p);
    _night(c,o,r,p);
    _shine(c,o,r,p);
    c.restore();
    _edge(c,planet,r,p);
  }

  void _continents(Canvas c,Offset o,double r,math.Random q,_PlanetPalette p){
    final n=switch(kind){GalaxyWorldKind.archive=>11,GalaxyWorldKind.creation=>10,GalaxyWorldKind.game=>9,GalaxyWorldKind.identity=>8,GalaxyWorldKind.family=>7,GalaxyWorldKind.vegeta=>8,_=>6};
    for(var i=0;i<n;i++){
      final a=q.nextDouble()*math.pi*2;
      final d=r*(.08+q.nextDouble()*.58);
      final at=o+Offset(math.cos(a)*d,math.sin(a)*d);
      final rx=r*(.055+q.nextDouble()*.18), ry=r*(.030+q.nextDouble()*.105), rot=q.nextDouble()*math.pi;
      final blob=_blob(at,rx,ry,rot,q,24);
      c.drawPath(blob,Paint()..color=p.land.withValues(alpha:.065+q.nextDouble()*.105));
      final coast=_blob(at+Offset(rx*.02,-ry*.025),rx*.94,ry*.78,rot,q,24);
      c.drawPath(coast,Paint()..color=p.coast.withValues(alpha:.014+q.nextDouble()*.025));
      if(i%2==0){
        final inner=_blob(at+Offset(-rx*.10,ry*.08),rx*.48,ry*.34,rot+.15,q,16);
        c.drawPath(inner,Paint()..color=p.terrainLight.withValues(alpha:.018+q.nextDouble()*.022));
      }
    }
  }

  Path _blob(Offset o,double rx,double ry,double rot,math.Random q,int points){
    final path=Path(), co=math.cos(rot), si=math.sin(rot);
    for(var i=0;i<=points;i++){
      final a=math.pi*2*i/points;
      final w=.62+q.nextDouble()*.72;
      final x=math.cos(a)*rx*w, y=math.sin(a)*ry*w;
      final px=o.dx+x*co-y*si, py=o.dy+x*si+y*co;
      if(i==0)path.moveTo(px,py);else path.lineTo(px,py);
    }
    path.close(); return path;
  }

  void _terrain(Canvas c,Offset o,double r,math.Random q,_PlanetPalette p){
    // Dense but extremely subtle micro-terrain replaces the old obvious globe/grid look.
    for(var i=0;i<120;i++){
      final a=q.nextDouble()*math.pi*2, d=math.sqrt(q.nextDouble())*r*.91;
      final at=o+Offset(math.cos(a)*d,math.sin(a)*d);
      final w=r*(.002+q.nextDouble()*.025), h=w*(.45+q.nextDouble()*2.2);
      c.drawOval(Rect.fromCenter(center:at,width:w*2.8,height:h*2.0),Paint()..color=(i.isEven?p.terrainLight:p.terrainDark).withValues(alpha:.010+q.nextDouble()*.034));
    }
    final ridge=Paint()..style=PaintingStyle.stroke..strokeWidth=math.max(.35,r*.0028);
    for(var i=0;i<9;i++){
      final a=q.nextDouble()*math.pi*2, d=r*(.05+q.nextDouble()*.68), len=r*(.10+q.nextDouble()*.32);
      final start=o+Offset(math.cos(a)*d,math.sin(a)*d);
      final path=Path()..moveTo(start.dx,start.dy);
      for(var j=1;j<7;j++){
        final t=j/6, bend=math.sin(j*1.7+i)*r*.018;
        path.lineTo(start.dx+math.cos(a)*len*t+math.cos(a+math.pi/2)*bend,start.dy+math.sin(a)*len*t+math.sin(a+math.pi/2)*bend);
      }
      ridge.color=p.terrainLight.withValues(alpha:.012+q.nextDouble()*.016); c.drawPath(path,ridge);
    }
  }

  void _atmosphereBands(Canvas c,Offset o,double r,math.Random q,_PlanetPalette p){
    final bands=switch(kind){GalaxyWorldKind.music=>3,GalaxyWorldKind.game=>2,GalaxyWorldKind.cinema=>2,GalaxyWorldKind.archive=>1,_=>2};
    final pen=Paint()..style=PaintingStyle.stroke;
    for(var i=0;i<bands;i++){
      final y=o.dy+(i-(bands-1)/2)*r*.34+q.nextDouble()*r*.025;
      final path=Path()..moveTo(o.dx-r*.94,y);
      for(var j=1;j<=17;j++){
        final x=o.dx-r*.94+r*1.88*j/17;
        path.lineTo(x,y+math.sin(j*.58+i*2.1)*r*.010);
      }
      pen.strokeWidth=math.max(.45,r*.004); pen.color=p.cloud.withValues(alpha:.010+q.nextDouble()*.018); c.drawPath(path,pen);
    }
  }

  void _craters(Canvas c,Offset o,double r,math.Random q,_PlanetPalette p){
    final n=switch(kind){GalaxyWorldKind.archive=>30,GalaxyWorldKind.vegeta=>18,GalaxyWorldKind.family=>15,GalaxyWorldKind.music=>6,GalaxyWorldKind.game=>7,_=>11};
    for(var i=0;i<n;i++){
      final at=o+Offset((q.nextDouble()*2-1)*r*.84,(q.nextDouble()*2-1)*r*.84);
      if((at-o).distance>r*.89)continue;
      final rr=r*(.0035+q.nextDouble()*.022);
      c.drawCircle(at,rr,Paint()..color=Colors.black.withValues(alpha:.014+q.nextDouble()*.032));
      final ring=Paint()..style=PaintingStyle.stroke..strokeWidth=math.max(.25,rr*.10)..color=p.highlight.withValues(alpha:.018+q.nextDouble()*.025);
      c.drawArc(Rect.fromCircle(center:at-Offset(rr*.16,rr*.16),radius:rr*.74),math.pi*1.02,math.pi*.92,false,ring);
    }
  }

  void _night(Canvas c,Offset o,double r,_PlanetPalette p){
    final n=o+Offset(r*.40,r*.24), rr=r*.75;
    c.drawCircle(n,rr,Paint()..shader=RadialGradient(center:const Alignment(-.18,-.18),radius:.92,colors:[Colors.transparent,Colors.black.withValues(alpha:.045),Colors.black.withValues(alpha:.30)],stops:const[0,.48,1]).createShader(Rect.fromCircle(center:n,radius:rr)));
  }

  void _shine(Canvas c,Offset o,double r,_PlanetPalette p){
    final at=o+Offset(-r*.30,-r*.34),rr=r*.58;
    c.drawCircle(at,rr,Paint()..shader=RadialGradient(colors:[Colors.white.withValues(alpha:.050),p.highlight.withValues(alpha:.014),Colors.transparent],stops:const[0,.30,1]).createShader(Rect.fromCircle(center:at,radius:rr)));
  }

  void _edge(Canvas c,Rect planet,double r,_PlanetPalette p){
    final edge=Paint()..style=PaintingStyle.stroke;
    edge.strokeWidth=math.max(1,r*.010); edge.color=p.glow.withValues(alpha:active?.28:.12);
    c.drawArc(planet.deflate(r*.006),math.pi*.65,math.pi*1.16,false,edge);
    edge.strokeWidth=math.max(.45,r*.004); edge.color=Colors.white.withValues(alpha:.055);
    c.drawArc(planet.deflate(r*.012),-math.pi*.96,math.pi*.48,false,edge);
    if(central){edge.strokeWidth=math.max(1.1,r*.008);edge.color=p.highlight.withValues(alpha:.045);c.drawArc(planet.deflate(r*.020),math.pi*.14,math.pi*.33,false,edge);}
  }

  _PlanetPalette _palette(GalaxyWorldKind k)=>switch(k){
    GalaxyWorldKind.vegeta=>const _PlanetPalette(Color(0xFF514C70),Color(0xFF211D34),Color(0xFF030208),Color(0xFF716B91),Color(0xFFA99BCB),Color(0xFF6E6590),Color(0xFF856BC0),Color(0xFFD4CBEB),Color(0xFFD0C8DE),Color(0xFF3B354F),Color(0xFF171328)),
    GalaxyWorldKind.game=>const _PlanetPalette(Color(0xFF4B7890),Color(0xFF163648),Color(0xFF031018),Color(0xFF466F4C),Color(0xFF8CA48D),Color(0xFF47778B),Color(0xFF5D9BBC),Color(0xFFD0E9E6),Color(0xFFC5E1DF),Color(0xFF244536),Color(0xFF102B31)),
    GalaxyWorldKind.music=>const _PlanetPalette(Color(0xFF594572),Color(0xFF261A33),Color(0xFF06040A),Color(0xFF77547C),Color(0xFFAA83AD),Color(0xFF76517E),Color(0xFF9360B5),Color(0xFFE0BFE4),Color(0xFFD9B9DE),Color(0xFF4A294E),Color(0xFF1D1027)),
    GalaxyWorldKind.identity=>const _PlanetPalette(Color(0xFF466F84),Color(0xFF172D3A),Color(0xFF02090E),Color(0xFF4E6F6C),Color(0xFF8FAAA0),Color(0xFF3F6575),Color(0xFF5C91A9),Color(0xFFC5DFDC),Color(0xFFC2D9D4),Color(0xFF294B49),Color(0xFF10262C)),
    GalaxyWorldKind.family=>const _PlanetPalette(Color(0xFF705B4D),Color(0xFF30231F),Color(0xFF080504),Color(0xFF735A48),Color(0xFFA78A70),Color(0xFF60483C),Color(0xFFA87858),Color(0xFFE3C5A6),Color(0xFFDCC9B8),Color(0xFF47362E),Color(0xFF201714)),
    GalaxyWorldKind.cinema=>const _PlanetPalette(Color(0xFF66768B),Color(0xFF293541),Color(0xFF05080C),Color(0xFF626C76),Color(0xFFA9B3BD),Color(0xFF586879),Color(0xFF819BB8),Color(0xFFD9E4ED),Color(0xFFD6E0E7),Color(0xFF353D47),Color(0xFF171D24)),
    GalaxyWorldKind.creation=>const _PlanetPalette(Color(0xFF805A75),Color(0xFF38263A),Color(0xFF09060B),Color(0xFF855B7D),Color(0xFFC29CB9),Color(0xFF875F82),Color(0xFFC16EA7),Color(0xFFF0CEE5),Color(0xFFE7CEDF),Color(0xFF513448),Color(0xFF211525)),
    GalaxyWorldKind.archive=>const _PlanetPalette(Color(0xFF50535D),Color(0xFF1E2026),Color(0xFF030306),Color(0xFF53545B),Color(0xFF85868D),Color(0xFF4A4C54),Color(0xFF777C8A),Color(0xFFC9CBD0),Color(0xFFC3C6CA),Color(0xFF33343A),Color(0xFF15161B)),
    GalaxyWorldKind.comingSoon=>const _PlanetPalette(Color(0xFF405764),Color(0xFF17252C),Color(0xFF020609),Color(0xFF405A61),Color(0xFF70888A),Color(0xFF3A515B),Color(0xFF5F8791),Color(0xFFC2D9D7),Color(0xFFBCD0CF),Color(0xFF293E44),Color(0xFF111D22)),
  };
  @override bool shouldRepaint(covariant _PlanetPainter old)=>old.active!=active||old.kind!=kind||old.seed!=seed||old.central!=central;
}

class _PlanetPalette {final Color light,base,shadow,land,coast,band,glow,highlight,cloud,terrainLight,terrainDark;const _PlanetPalette(this.light,this.base,this.shadow,this.land,this.coast,this.band,this.glow,this.highlight,this.cloud,this.terrainLight,this.terrainDark);}

class _SelectionLayer extends StatelessWidget {
  final GalaxyWorld world; final bool compact; final VoidCallback onClose,onEnter;
  const _SelectionLayer({required this.world,required this.compact,required this.onClose,required this.onEnter});
  @override Widget build(BuildContext context)=>Positioned(left:compact?16:34,bottom:compact?16:28,child:Material(color:Colors.transparent,child:Container(width:compact?250:330,padding:const EdgeInsets.fromLTRB(18,15,10,12),decoration:BoxDecoration(color:const Color(0xFF080810).withValues(alpha:.90),border:Border.all(color:const Color(0xFFB7A9D5).withValues(alpha:.13)),borderRadius:BorderRadius.circular(12),boxShadow:[BoxShadow(color:Colors.black.withValues(alpha:.5),blurRadius:28,offset:const Offset(0,10))]),child:Row(children:[
    Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[Text(world.title,style:const TextStyle(fontSize:11,letterSpacing:2.8)),const SizedBox(height:5),Text(world.description,maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:9,height:1.35,color:Colors.white.withValues(alpha:.38)))])),
    const SizedBox(width:8),TextButton(onPressed:onEnter,style:TextButton.styleFrom(padding:const EdgeInsets.symmetric(horizontal:9,vertical:6),minimumSize:Size.zero,tapTargetSize:MaterialTapTargetSize.shrinkWrap),child:const Text('ENTER',style:TextStyle(fontSize:8,letterSpacing:1.8))),
    IconButton(onPressed:onClose,padding:EdgeInsets.zero,constraints:const BoxConstraints.tightFor(width:28,height:28),icon:Icon(Icons.close,size:15,color:Colors.white54)),
  ]))));
}
