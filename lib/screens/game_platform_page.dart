import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_list_page.dart';

class GamePlatformPage extends StatefulWidget {
  final String territory;
  final List<GamePlatformGroup> groups;
  const GamePlatformPage({super.key, required this.territory, required this.groups});
  @override State<GamePlatformPage> createState() => _GamePlatformPageState();
}

class _GamePlatformPageState extends State<GamePlatformPage> with SingleTickerProviderStateMixin {
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 120))..repeat();
  int? traveling;
  List<GamePlatform> get platforms => widget.groups.expand((g) => g.platforms).toList(growable: false);
  @override void dispose(){clock.dispose();super.dispose();}
  Future<void> enter(int i) async {
    if (traveling != null) return;
    setState(() => traveling = i);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final p = platforms[i];
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => GameListPage(
      territory: widget.territory, platform: p.name, externalPlatformIds: p.externalPlatformIds,
      navigationPlatforms: platforms, navigationIndex: i,
    )));
    if (mounted) setState(() => traveling = null);
  }
  @override Widget build(BuildContext context){
    final compact=MediaQuery.sizeOf(context).width<820;
    return Scaffold(backgroundColor:const Color(0xFF02040A),body:AnimatedBuilder(animation:clock,builder:(_,__)=>Stack(fit:StackFit.expand,children:[
      const RepaintBoundary(child: CustomPaint(painter:_RealmSpace())),
      SafeArea(child:Padding(padding:EdgeInsets.fromLTRB(compact?14:30,compact?12:24,compact?14:30,0),child:Row(children:[
        IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.arrow_back_ios_new,size:14)),const SizedBox(width:8),
        Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(widget.territory.toUpperCase(),style:const TextStyle(fontSize:16,letterSpacing:3.8)),
          const SizedBox(height:4),const Text('LIVING PLATFORM REALMS · TRAVEL THROUGH THE ARCHIVE',style:TextStyle(fontSize:6.5,letterSpacing:2.1,color:Color(0x668D95A5))),
        ]),
      ]))),
      Center(child:LayoutBuilder(builder:(_,b){
        final w=math.min(b.maxWidth*(compact ? .98 : .90),1550.0),h=math.min(b.maxHeight*(compact ? .72 : .80),850.0);
        return AnimatedScale(
          scale: traveling == null ? 1.0 : 3.05,
          alignment: traveling == null ? Alignment.center : _realmZoomAlignment(traveling!, total: platforms.length, size: Size(w,h), phase: clock.value),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInCubic,
          child: IgnorePointer(
            ignoring: traveling != null,
            child: SizedBox(width:w,height:h,child:Stack(children:[
              CustomPaint(painter:_RealmAtlas()),
              for(var i=0;i<platforms.length;i++) _RealmHit(
                platform:platforms[i],index:i,total:platforms.length,size:Size(w,h),phase:clock.value,
                onOpen:()=>enter(i),
              ),
            ])),
          ),
        );
      })),
      Positioned(
        left:compact?14:30,right:compact?14:30,bottom:compact?14:28,
        child:AnimatedOpacity(
          opacity: traveling == null ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 320),
          child:Text(
            'TRAVEL TO A PLATFORM REALM',
            style:TextStyle(fontSize:6.5,letterSpacing:1.7,color:Colors.white.withValues(alpha:.30)),
          ),
        ),
      ),
      Positioned.fill(
        child:IgnorePointer(
          child:AnimatedOpacity(
            opacity: traveling == null ? 0.0 : .24,
            duration: const Duration(milliseconds:700),
            curve: Curves.easeInCubic,
            child:const ColoredBox(color:Color(0xFF02040A)),
          ),
        ),
      ),
    ])));
  }
}

class GamePlatformGroup { final String name; final String subtitle; final List<GamePlatform> platforms; const GamePlatformGroup(this.name,this.subtitle,this.platforms); }
class GamePlatform { final String name; final List<int> externalPlatformIds; const GamePlatform(this.name,this.externalPlatformIds); }

class _RealmHit extends StatelessWidget{
  final GamePlatform platform; final int index,total; final Size size; final double phase; final VoidCallback onOpen;
  const _RealmHit({required this.platform,required this.index,required this.total,required this.size,required this.phase,required this.onOpen});
  @override Widget build(BuildContext context){
    final p=_pos(index,total,size,phase);
    final d=math.max(150.0,size.width*.235);
    return Positioned(left:p.dx-d*.50,top:p.dy-d*.36,width:d,height:d*.78,child:MouseRegion(
      cursor:SystemMouseCursors.click,
      child:GestureDetector(
        onTap:onOpen,
        child:Stack(
          fit:StackFit.expand,
          children:[
            CustomPaint(painter:_MiniRealm(seed:index,active:false,label:platform.name)),
            IgnorePointer(child:CustomPaint(painter:_RealmBeacon(seed:index,active:false,phase:phase))),
          ],
        ),
      ),
    ));
  }
}
Alignment _realmZoomAlignment(int i,{required int total,required Size size,required double phase}) {
  final p = _pos(i,total,size,phase);
  return Alignment((p.dx / size.width - .5) * 2, (p.dy / size.height - .5) * 2);
}

Offset _pos(int i,int total,Size s,double phase){
  const positions=[
    Offset(.20,.42),Offset(.50,.31),Offset(.80,.43),Offset(.34,.70),Offset(.68,.72),
    Offset(.18,.69),Offset(.83,.70),Offset(.50,.73)
  ];
  final p=positions[i%positions.length];
  return Offset(s.width*p.dx,s.height*p.dy+math.sin(phase*math.pi*2+i*.9)*4);
}

class _MiniRealm extends CustomPainter{
  final int seed; final bool active; final String label;
  const _MiniRealm({required this.seed,required this.active,required this.label});

  @override void paint(Canvas c,Size s){
    final center=Offset(s.width*.5,s.height*.40);
    final rnd=math.Random(900+seed*71);
    final w=s.width*.98,h=s.height*.70;
    final pts=<Offset>[];
    for(var i=0;i<30;i++){
      final a=i*math.pi*2/30;
      final noise=.82+rnd.nextDouble()*.18+math.sin(a*2.7+seed)*.055+math.sin(a*5.0+seed*.4)*.025;
      pts.add(center+Offset(math.cos(a)*w*.5*noise,math.sin(a)*h*.5*noise));
    }
    final top=_closed(pts);
    final body=top.shift(Offset(0,h*.24));
    // Massive rock underside — the island must have physical volume.
    c.drawPath(body,Paint()..color=const Color(0xF0081116));
    for(var layer=0;layer<5;layer++){
      final t=layer/5;
      final lower=top.shift(Offset(0,h*(.08+.18*t)));
      c.drawPath(lower,Paint()..style=PaintingStyle.stroke..strokeWidth=math.max(1,s.width*.006*(1-t))..color=Color.lerp(const Color(0xAA26383B),const Color(0x0010181D),t)!);
    }

    final bounds=top.getBounds();
    c.drawPath(top,Paint()..shader=LinearGradient(begin:Alignment(-.8,-1),end:Alignment(.8,1),colors:_palette(seed)).createShader(bounds));

    // Coastal shelf: a darker broken shoreline gives the landmass a natural boundary.
    final coast = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, s.width * .010)
      ..color = const Color(0x4C9AB8B2);
    final coastPath = _closed([
      for (var i = 0; i < pts.length; i++)
        center + (pts[i] - center) * .945,
    ]);
    c.drawPath(coastPath, coast);

    // Uneven terrain/vegetation patches prevent the realm from reading as a single procedural blob.
    final vegetation = Paint()..color = Colors.white.withValues(alpha: .045);
    for(var i=0;i<28;i++){
      final a=i*2.41+seed*.7;
      final p=center+Offset(math.cos(a)*w*(.10+(i%5)*.065),math.sin(a*1.31)*h*(.09+(i%4)*.055));
      c.drawOval(
        Rect.fromCenter(center:p,width:w*(.018+(i%3)*.012),height:h*(.025+(i%2)*.014)),
        vegetation,
      );
    }

    // Real terrain relief: broad plateaus, valleys, ridges and vegetation masses.
    for(var layer=1;layer<=6;layer++){
      final shrink=1-layer*.105;
      final inner=Path();
      for(var i=0;i<pts.length;i++){
        final q=center+(pts[i]-center)*shrink;
        if(i==0)inner.moveTo(q.dx,q.dy);else inner.lineTo(q.dx,q.dy);
      }
      inner.close();
      c.drawPath(inner,Paint()..style=PaintingStyle.stroke..strokeWidth=math.max(.7,s.width*.004)..color=Colors.white.withValues(alpha:(active ? .105 : .045)*(1-layer*.08)));
    }

    final ridge=Paint()..style=PaintingStyle.stroke..strokeCap=StrokeCap.round..strokeWidth=math.max(1,s.width*.006)..color=Colors.white.withValues(alpha:.095);
    for(var i=0;i<8;i++){
      final yy=center.dy+h*(i-2)*.045;
      final path=Path()..moveTo(center.dx-w*.36,yy+h*.02);
      path.cubicTo(center.dx-w*.20,yy-h*.16,center.dx-w*.03,yy+h*.12,center.dx+w*.08,yy-h*.10);
      path.cubicTo(center.dx+w*.18,yy-h*.18,center.dx+w*.28,yy+h*.08,center.dx+w*.37,yy-h*.01);
      c.drawPath(path,ridge);
    }

    // Mountain silhouettes sit inside the landmass, giving actual elevation rather than a flat blob.
    final mountain=Paint()..color=Colors.white.withValues(alpha:.105);
    for(var i=0;i<5;i++){
      final x=center.dx+(-.30+i*.15)*w;
      final base=center.dy+h*.13;
      final peak=base-h*(.17+.04*((seed+i)%3));
      final path=Path()..moveTo(x-w*.10,base)..lineTo(x,peak)..lineTo(x+w*.11,base)..close();
      c.drawPath(path,mountain);
      c.drawPath(Path()..moveTo(x,peak)..lineTo(x+w*.035,base)..lineTo(x+w*.11,base),Paint()..color=Colors.black.withValues(alpha:.12));
    }

    // Deep environmental shadows: terrain masses should sit inside the world, not float as stickers.
    final depthShadow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, .8),
        radius: 1,
        colors: [Colors.black.withValues(alpha: .42), Colors.transparent],
      ).createShader(Rect.fromCenter(
        center: Offset(center.dx, center.dy + h * .30),
        width: w * 1.05,
        height: h * .55,
      ));
    c.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + h * .28), width: w * 1.05, height: h * .48),
      depthShadow,
    );

    // Secondary lower shelf: a broken, offset rock mass makes the realm read as
    // suspended terrain with depth, rather than a single flat island silhouette.
    final lowerShelf = top.shift(Offset(-w * .015, h * .29));
    c.drawPath(
      lowerShelf,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, s.width * .010)
        ..color = const Color(0x3B6C7A7A),
    );

    // A handful of cliff-face facets catch the environmental light. These are
    // broad and irregular rather than decorative lines.
    final facet = Paint()
      ..color = const Color(0x2E91A09A);
    for (var i = 0; i < 7; i++) {
      final x = center.dx + (-.32 + i * .105) * w;
      final y = center.dy + h * (.20 + (i % 3) * .035);
      final p = Path()
        ..moveTo(x - w * .055, y)
        ..lineTo(x, y + h * (.10 + (i % 2) * .045))
        ..lineTo(x + w * .06, y)
        ..close();
      c.drawPath(p, facet);
    }

    // Platform identity comes from environmental accents, never mascots or famous scenes.
    final accent=_accent(seed);
    final beacon=Offset(center.dx+w*.16,center.dy-h*.035);
    c.drawCircle(beacon,w*.08,Paint()..shader=RadialGradient(colors:[accent.withValues(alpha:active ? .28 : .10),Colors.transparent]).createShader(Rect.fromCircle(center:beacon,radius:w*.28)));
    c.drawCircle(beacon,w*.018,Paint()..color=accent.withValues(alpha:active ? .65 : .22));

    // Foreground terrain shadow creates separation from the atmospheric background.
    final shadow=Paint()..shader=RadialGradient(colors:[Colors.black.withValues(alpha:.32),Colors.transparent]).createShader(Rect.fromCenter(center:Offset(center.dx,center.dy+h*.30),width:w*.95,height:h*.34));
    c.drawOval(Rect.fromCenter(center:Offset(center.dx,center.dy+h*.30),width:w*.95,height:h*.34),shadow);

    final tp=TextPainter(text:TextSpan(text:label.toUpperCase(),style:TextStyle(color:Colors.white.withValues(alpha:active ? .96 : .58),fontSize:math.max(8,s.width*.054),letterSpacing:1.5,fontWeight:FontWeight.w400)),textDirection:TextDirection.ltr)..layout(maxWidth:s.width*1.2);
    tp.paint(c,Offset(center.dx-tp.width/2,center.dy+h*.67));
    if(active){
      c.drawPath(top,Paint()..style=PaintingStyle.stroke..strokeWidth=math.max(1.5,s.width*.009)..color=Colors.white.withValues(alpha:.20));
    }
  }

  Path _closed(List<Offset> pts){final p=Path()..moveTo(pts.first.dx,pts.first.dy);for(final q in pts.skip(1))p.lineTo(q.dx,q.dy);p.close();return p;}

  List<Color> _palette(int i)=>const[
    [Color(0xFF627C63),Color(0xFF3A5745),Color(0xFF1E3430)],
    [Color(0xFF92775B),Color(0xFF5B4B40),Color(0xFF29302E)],
    [Color(0xFF718096),Color(0xFF465467),Color(0xFF252D3A)],
    [Color(0xFF568079),Color(0xFF2D5551),Color(0xFF172E34)],
    [Color(0xFF69627C),Color(0xFF403A52),Color(0xFF222336)],
    [Color(0xFF77827C),Color(0xFF45514D),Color(0xFF242D2F)],
  ][i%6];

  Color _accent(int i)=>const[Color(0xFFB9D69D),Color(0xFFD4A66B),Color(0xFFAEBCE0),Color(0xFF6BC2B1),Color(0xFFA58CDA),Color(0xFF9EB5AC)][i%6];
  @override bool shouldRepaint(covariant _MiniRealm o)=>o.seed!=seed||o.active!=active||o.label!=label;
}

class _RealmBeacon extends CustomPainter {
  final int seed;
  final bool active;
  final double phase;
  const _RealmBeacon({required this.seed,required this.active,required this.phase});

  @override
  void paint(Canvas c, Size s) {
    final center=Offset(s.width*.5,s.height*.40);
    final w=s.width*.98;
    final h=s.height*.70;
    final accent=_accent(seed);
    final beacon=Offset(
      center.dx+math.sin(phase*math.pi*2+seed)*w*.16,
      center.dy-h*.035,
    );
    c.drawCircle(
      beacon,w*.08,
      Paint()..shader=RadialGradient(
        colors:[accent.withValues(alpha:active ? .28 : .10),Colors.transparent],
      ).createShader(Rect.fromCircle(center:beacon,radius:w*.28)),
    );
    c.drawCircle(
      beacon,w*.018,
      Paint()..color=accent.withValues(alpha:active ? .65 : .22),
    );
  }

  @override
  bool shouldRepaint(covariant _RealmBeacon o) =>
      o.phase!=phase || o.active!=active || o.seed!=seed;
}

class _RealmAtlas extends CustomPainter {
  const _RealmAtlas();
  @override
  void paint(Canvas c, Size s) {
    final r = Offset.zero & s;
    c.drawRect(r, Paint()..shader = const RadialGradient(
      center: Alignment(0, -.25), radius: 1.05,
      colors: [Color(0xFF172B32), Color(0xFF07131D), Color(0xFF02040A)],
    ).createShader(r));
    final rnd = math.Random(5512);
    for (var i = 0; i < 120; i++) {
      final d = .2 + rnd.nextDouble() * .8;
      c.drawCircle(
        Offset(rnd.nextDouble() * s.width, rnd.nextDouble() * s.height),
        .25 + d * .8,
        Paint()..color = Colors.white.withValues(alpha: .018 + d * .045),
      );
    }
    final horizon = Path()..moveTo(0, s.height * .64);
    for (var i = 0; i <= 12; i++) {
      horizon.lineTo(s.width * i / 12, s.height * (.60 + .035 * math.sin(i * 1.4)));
    }
    horizon..lineTo(s.width, s.height)..lineTo(0, s.height)..close();
    c.drawPath(horizon, Paint()..color = const Color(0x25101C21));
    final center = Offset(s.width * .5, s.height * .48);
    c.drawCircle(center, s.width * .12, Paint()..shader = const RadialGradient(
      colors: [Color(0x24A78BEA), Color(0x00000000)],
    ).createShader(Rect.fromCircle(center: center, radius: s.width * .2)));
    for (var i = 0; i < 5; i++) {
      final rr = s.width * (.12 + i * .10);
      c.drawOval(
        Rect.fromCenter(center: center, width: rr * 2, height: rr * .48),
        Paint()..style = PaintingStyle.stroke..strokeWidth = .5..color = const Color(0x183E7480),
      );
    }
  }
  @override
  bool shouldRepaint(covariant _RealmAtlas o) => false;
}

class _RealmSpace extends CustomPainter {
  const _RealmSpace();
  @override
  void paint(Canvas c, Size s) {
    final r = Offset.zero & s;
    c.drawRect(r, Paint()..shader = const RadialGradient(
      center: Alignment(0, -.1), radius: 1.1,
      colors: [Color(0xFF11182A), Color(0xFF040812), Color(0xFF010207)],
    ).createShader(r));
  }
  @override
  bool shouldRepaint(covariant _RealmSpace o) => false;
}
