import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'content_browser_page.dart';

class GameListPage extends StatefulWidget {
  final String territory;
  final String platform;
  final List<int> externalPlatformIds;
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
      IgnorePointer(child:RepaintBoundary(child:CustomPaint(painter:_ArchiveWorldAtmosphere(_clock.value)))),
      Center(child:LayoutBuilder(builder:(_,b){final d=math.min(b.maxWidth*(compact ? .90 : .64),b.maxHeight*(compact ? .54 : .68)).toDouble();return AnimatedScale(scale:_traveling?2.65:1.0,alignment:Alignment.center,duration:const Duration(milliseconds:650),curve:Curves.easeInCubic,child:GestureDetector(onTap:_open,child:MouseRegion(cursor:SystemMouseCursors.click,child:SizedBox.square(dimension:d,child:CustomPaint(painter:const _ArchiveWorldStatic())))));})),
      SafeArea(child:Padding(padding:EdgeInsets.all(compact?14:30),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('GAME-WORLD / ${widget.territory.toUpperCase()} / ${widget.platform.toUpperCase()}',style:const TextStyle(fontSize:10,letterSpacing:2.3)),const SizedBox(height:5),const Text('ARCHIVE WORLD  /  CATALOG ORBIT',style:TextStyle(fontSize:6.5,letterSpacing:2,color:Color(0x5FFFFFFF))),const Spacer(),Center(child:Text('PHYSICAL MEDIA ARCHIVE  •  LIVE CATALOG',style:TextStyle(fontSize:6,letterSpacing:2,color:Colors.white.withValues(alpha:.35))))]))),
      Positioned(left:compact?14:30,right:compact?14:30,bottom:compact?16:28,child:AnimatedOpacity(opacity:_traveling?0.0:1.0,duration:const Duration(milliseconds:300),child:Text('ENTER THE ARCHIVE WORLD · TRAVEL INTO THE LIBRARY',style:TextStyle(fontSize:6.5,letterSpacing:1.8,color:Colors.white.withValues(alpha:.30))))),
      Positioned.fill(child:IgnorePointer(child:AnimatedOpacity(opacity:_traveling?.24:0.0,duration:const Duration(milliseconds:650),curve:Curves.easeInCubic,child:const ColoredBox(color:Color(0xFF02040A))))),
    ])));
  }
}
class _ArchiveWorldStatic extends CustomPainter {
  const _ArchiveWorldStatic();

  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width * .5, s.height * .5);
    final r = math.min(s.width, s.height) * .31;

    // The archive remains a physical destination: a dark spherical library
    // world with real volume, rather than a control panel.
    final rect = Rect.fromCircle(center: center, radius: r * 1.08);
    c.drawCircle(
      center,
      r * 1.08,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.42, -.48),
          colors: [
            Color(0xFFB7C5CF),
            Color(0xFF66798B),
            Color(0xFF293547),
            Color(0xFF050811),
          ],
          stops: [.03, .24, .62, 1],
        ).createShader(rect),
    );

    // Physical surface masses: broad irregular regions create a living
    // archive world instead of a small globe with decorative map markings.
    for (var i = 0; i < 5; i++) {
      final a = i * 1.83;
      final p = center + Offset(
        math.cos(a) * r * (.18 + (i % 3) * .13),
        math.sin(a * 1.27) * r * (.16 + (i % 2) * .15),
      );
      final w = r * (.28 + (i % 3) * .10);
      final h = r * (.15 + (i % 2) * .09);
      final land = Path();
      for (var k = 0; k < 12; k++) {
        final aa = k / 12 * math.pi * 2;
        final n = .78 + .14 * math.sin(aa * 3 + i) + .07 * math.sin(aa * 5 + i * .4);
        final q = p + Offset(math.cos(aa) * w * n, math.sin(aa) * h * n);
        if (k == 0) land.moveTo(q.dx, q.dy); else land.lineTo(q.dx, q.dy);
      }
      land.close();
      c.drawPath(
        land,
        Paint()..shader = LinearGradient(
          begin: Alignment(-.7, -1),
          end: Alignment(.8, 1),
          colors: const [Color(0x735D766D), Color(0x38313F3D)],
        ).createShader(Rect.fromCenter(center: p, width: w * 2, height: h * 2)),
      );
      c.drawPath(
        land,
        Paint()..style = PaintingStyle.stroke..strokeWidth = math.max(1, r * .012)
          ..color = const Color(0x3A93AAA0),
      );
    }

    // A faint atmospheric rim and deep underside provide physical separation.
    c.drawCircle(
      center,
      r * 1.08,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, r * .025)
        ..color = const Color(0x397FADB7),
    );
    c.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + r * .64),
        width: r * 1.9,
        height: r * .42,
      ),
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.black.withValues(alpha: .42),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + r * .64),
            width: r * 2.1,
            height: r * .48,
          ),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _ArchiveWorldStatic oldDelegate) => false;
}

class _ArchiveWorldAtmosphere extends CustomPainter {
  final double phase;
  const _ArchiveWorldAtmosphere(this.phase);

  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width * .5, s.height * .5);
    final r = math.min(s.width, s.height) * .31;

    c.drawArc(
      Rect.fromCircle(center: center, radius: r * 1.16),
      phase * math.pi * 2,
      .9,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, r * .012)
        ..color = const Color(0x729BBCC7),
    );

    final mist = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, r * .018)
      ..color = const Color(0x208F7BD0);
    c.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + r * .08),
        width: r * 2.45,
        height: r * 1.25,
      ),
      phase * math.pi * 2 + 1.1,
      .65,
      false,
      mist,
    );
  }

  @override
  bool shouldRepaint(covariant _ArchiveWorldAtmosphere oldDelegate) =>
      oldDelegate.phase != phase;
}

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
