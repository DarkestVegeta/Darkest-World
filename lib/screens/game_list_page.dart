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
  bool _hovered=false;
  final FocusNode _focusNode=FocusNode();
  @override void dispose(){_focusNode.dispose();_clock.dispose();super.dispose();}
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
    return Scaffold(backgroundColor:const Color(0xFF010207),body:Focus(
      autofocus:true,
      focusNode:_focusNode,
      onKeyEvent:(_,event){
        if(event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape && !_traveling){
          Navigator.of(context).pop();
          return KeyEventResult.handled;
        }
        if(event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter && !_traveling){
          _open();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child:Stack(fit:StackFit.expand,children:[
      const RepaintBoundary(child:CustomPaint(painter:_ArchiveSpaceStatic())),
      AnimatedBuilder(animation:_clock,builder:(_,__) => RepaintBoundary(child:CustomPaint(painter:_ArchiveSpaceAtmosphere(_clock.value)))),
      IgnorePointer(child:AnimatedBuilder(animation:_clock,builder:(_,__) => RepaintBoundary(child:CustomPaint(painter:_ArchiveWorldAtmosphere(_clock.value))))),
      Center(child:LayoutBuilder(builder:(_,b){final d=math.min(b.maxWidth*(compact ? .90 : .64),b.maxHeight*(compact ? .58 : .72)).toDouble();return AnimatedScale(scale:_traveling?2.65:1.0,alignment:Alignment.center,duration:const Duration(milliseconds:650),curve:Curves.easeInCubic,child:GestureDetector(onTap:_open,child:MouseRegion(
          cursor:SystemMouseCursors.click,
          onEnter:(_)=>setState(()=>_hovered=true),
          onExit:(_)=>setState(()=>_hovered=false),
          child:AnimatedScale(scale:_hovered && !_traveling ? 1.025 : 1.0,duration:const Duration(milliseconds:220),curve:Curves.easeOut,child:SizedBox.square(dimension:d,child:CustomPaint(painter:const _ArchiveWorldStatic())))
        )));})),
      SafeArea(child:Padding(padding:EdgeInsets.all(compact?14:30),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('GAME-WORLD / ${widget.territory.toUpperCase()} / ${widget.platform.toUpperCase()}',style:const TextStyle(fontSize:10,letterSpacing:2.3)),const SizedBox(height:5),const Text('ARCHIVE WORLD  /  CATALOG ORBIT',style:TextStyle(fontSize:6.5,letterSpacing:2,color:Color(0x5FFFFFFF))),const Spacer(),Center(child:Text('PHYSICAL MEDIA ARCHIVE  •  LIVE CATALOG',style:TextStyle(fontSize:6,letterSpacing:2,color:Colors.white.withValues(alpha:.35))))]))),
      Positioned(left:compact?14:30,right:compact?14:30,bottom:compact?16:28,child:AnimatedOpacity(opacity:_traveling?0.0:1.0,duration:const Duration(milliseconds:300),child:Text('ENTER THE ARCHIVE WORLD · TRAVEL INTO THE LIBRARY',style:TextStyle(fontSize:6.5,letterSpacing:1.8,color:Colors.white.withValues(alpha:.30))))),
      Positioned.fill(child:IgnorePointer(child:AnimatedOpacity(opacity:_traveling?.24:0.0,duration:const Duration(milliseconds:650),curve:Curves.easeInCubic,child:const ColoredBox(color:Color(0xFF02040A))))),
    ]));
  }
}
class _ArchiveWorldStatic extends CustomPainter {
  const _ArchiveWorldStatic();

  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width * .5, s.height * .5);
    final r = math.min(s.width, s.height) * .34;
    final sphereRect = Rect.fromCircle(center: center, radius: r * 1.08);

    // The archive is a destination world, not a database icon: rich physical
    // surface layers keep the visual language continuous with Game World.
    c.drawCircle(
      center,
      r * 1.08,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.42, -.48),
          colors: [
            Color(0xFFC3D2D7),
            Color(0xFF718797),
            Color(0xFF35485A),
            Color(0xFF090E1A),
          ],
          stops: [.025, .22, .60, 1],
        ).createShader(sphereRect),
    );

    final rnd = math.Random(6117);
    final palettes = const [
      [Color(0x826C8D76), Color(0x454C6956)],
      [Color(0x826F7890), Color(0x45454E69)],
      [Color(0x827C6D5B), Color(0x454D443B)],
      [Color(0x82607873), Color(0x45405755)],
      [Color(0x826A5E78), Color(0x45433D57)],
      [Color(0x82758B70), Color(0x45465E4F)],
    ];

    // Six broad organic landmasses. Their irregular silhouettes echo the large
    // floating-world references without becoming a cartographic map.
    for (var i = 0; i < 6; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final rr = math.sqrt(rnd.nextDouble()) * r * .67;
      final p = center + Offset(math.cos(a) * rr, math.sin(a) * rr * .72);
      final w = r * (.22 + rnd.nextDouble() * .17);
      final h = r * (.11 + rnd.nextDouble() * .11);
      final pts = <Offset>[];
      for (var k = 0; k < 20; k++) {
        final t = k / 20 * math.pi * 2;
        final n = .72 +
            rnd.nextDouble() * .22 +
            math.sin(t * 2.4 + i) * .09 +
            math.sin(t * 6.1 + i * .4) * .035;
        pts.add(p + Offset(math.cos(t) * w * n, math.sin(t) * h * n));
      }
      final land = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final q in pts.skip(1)) land.lineTo(q.dx, q.dy);
      land.close();

      final palette = palettes[i];
      c.drawPath(
        land,
        Paint()
          ..shader = LinearGradient(
            begin: const Alignment(-.8, -1),
            end: const Alignment(.8, .9),
            colors: palette,
          ).createShader(Rect.fromCenter(center: p, width: w * 2, height: h * 2)),
      );

      // Visible cliff/body depth makes the archive world physically elevated.
      c.drawPath(
        land.shift(Offset(-w * .018, h * .30)),
        Paint()..color = const Color(0xD8070D15),
      );
      for (var layer = 0; layer < 3; layer++) {
        c.drawPath(
          land.shift(Offset(-w * (.008 + layer * .008), h * (.06 + layer * .08))),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(1, r * .009)
            ..color = Color.fromARGB(48 - layer * 10, 130, 151, 153),
        );
      }

      // Broad plateau/relief masses.
      for (var relief = 0; relief < 3; relief++) {
        final q = p + Offset(
          math.cos(i + relief * 2.1) * w * .16,
          math.sin(i * .7 + relief) * h * .20,
        );
        c.drawOval(
          Rect.fromCenter(center: q, width: w * .42, height: h * .40),
          Paint()
            ..shader = RadialGradient(
              colors: [Colors.white.withValues(alpha: .045), Colors.transparent],
            ).createShader(Rect.fromCenter(center: q, width: w * .42, height: h * .40)),
        );
      }

      // Mountain/architecture silhouettes: archive-world scale cues, not game
      // characters or recognizable locations.
      final structure = Paint()..color = Colors.white.withValues(alpha: .10 + i * .008);
      for (var m = 0; m < 4; m++) {
        final x = p.dx + (-.27 + m * .18) * w;
        final base = p.dy + h * .05;
        final peak = base - h * (.42 + (m % 2) * .16);
        final ridge = Path()
          ..moveTo(x - w * .10, base)
          ..quadraticBezierTo(x - w * .04, peak + h * .10, x, peak)
          ..quadraticBezierTo(x + w * .05, peak + h * .07, x + w * .11, base)
          ..close();
        c.drawPath(ridge, structure);
      }

      // Subtle archive "library" traces: small clustered forms rather than HUD.
      final archiveLight = Paint()..color = const Color(0x6A9A83D0);
      for (var q = 0; q < 5; q++) {
        final lp = p + Offset(
          (-.25 + (q % 3) * .24) * w,
          (-.06 + (q ~/ 3) * .16) * h,
        );
        c.drawCircle(lp, w * .012, archiveLight);
        c.drawLine(
          lp + Offset(-w * .035, h * .025),
          lp + Offset(w * .035, -h * .035),
          Paint()..color = const Color(0x326E9CC4)..strokeWidth = math.max(1, r * .004),
        );
      }
    }

    // Deep atmospheric depth inside the sphere.
    final haze = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.10, -.25),
        radius: .96,
        colors: const [Color(0x142C6B83), Colors.transparent, Color(0x24010208)],
        stops: const [0, .58, 1],
      ).createShader(sphereRect);
    c.drawCircle(center, r * 1.07, haze);

    // Directional limb and underside separation.
    c.drawCircle(
      center,
      r * 1.08,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, r * .024)
        ..color = const Color(0x397FADB7),
    );
    c.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + r * .66), width: r * 1.95, height: r * .43),
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.black.withValues(alpha: .44), Colors.transparent],
        ).createShader(
          Rect.fromCenter(center: Offset(center.dx, center.dy + r * .66), width: r * 2.1, height: r * .50),
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
    for(var i=0;i<60;i++){
      final p=Offset(rnd.nextDouble()*s.width,rnd.nextDouble()*s.height);
      final pulse=.35+.65*math.sin(phase*math.pi*2+i*.41).abs();
      x.drawCircle(p,.2+rnd.nextDouble()*.65,Paint()..color=Colors.white.withValues(alpha:.02+.045*pulse));
    }
  }
  @override bool shouldRepaint(covariant _ArchiveSpaceAtmosphere o)=>o.phase!=phase;
}
