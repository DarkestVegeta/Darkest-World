import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Site-wide cinematic finishing layer. Procedural only: depth stars, haze,
/// restrained bloom, scan light and framing without textures or dependencies.
class DarkestWorldArchiveAtmosphere extends StatefulWidget {
  const DarkestWorldArchiveAtmosphere({super.key});
  @override State<DarkestWorldArchiveAtmosphere> createState()=>_DarkestWorldArchiveAtmosphereState();
}

class _DarkestWorldArchiveAtmosphereState extends State<DarkestWorldArchiveAtmosphere> with SingleTickerProviderStateMixin {
  late final AnimationController _clock=AnimationController(vsync:this,duration:const Duration(seconds:150))..repeat();
  @override void dispose(){_clock.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>IgnorePointer(child:AnimatedBuilder(animation:_clock,builder:(_,__)=>CustomPaint(painter:_ArchiveAtmospherePainter(_clock.value),size:Size.infinite)));
}

class _ArchiveStar { final double x,y,depth; const _ArchiveStar(this.x,this.y,this.depth); }

class _ArchiveAtmospherePainter extends CustomPainter {
  final double phase; const _ArchiveAtmospherePainter(this.phase);
  static final List<_ArchiveStar> _stars=List.generate(520,(i){final rng=math.Random(4207+i*17);return _ArchiveStar(rng.nextDouble(),rng.nextDouble(),rng.nextDouble());});
  static final Paint _backgroundPaint=Paint();
  static final Paint _starPaint=Paint();
  static final Paint _hazePaint=Paint();
  static final Paint _ringPaint=Paint()..style=PaintingStyle.stroke;
  static final Paint _arcPaint=Paint()..style=PaintingStyle.stroke..strokeCap=StrokeCap.round;
  static final Paint _secondaryArcPaint=Paint()..style=PaintingStyle.stroke;
  static final Paint _coreGlowPaint=Paint();
  static final Paint _corePaint=Paint();
  static final Paint _scanPaint=Paint()..color=const Color(0x0A92A7C2);
  static final Paint _scanBandPaint=Paint();
  static final Paint _framePaint=Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0x0C9BA9BC);

  @override void paint(Canvas c,Size s){
    final r=Offset.zero&s; final short=math.min(s.width,s.height); final center=Offset(s.width*.5,s.height*.46);
    _backgroundPaint.shader=RadialGradient(center:const Alignment(0,.05),radius:1.05,colors:[Colors.transparent,const Color(0x16040A18),const Color(0xA8010308)],stops:const[.34,.72,1]).createShader(r); c.drawRect(r,_backgroundPaint);
    for(var i=0;i<_stars.length;i++){
      final star=_stars[i]; final depth=star.depth;
      final drift=math.sin(phase*math.pi*2*(.25+depth*.7)+i*.31)*(.7+depth*2.2);
      final twinkle=.45+.55*math.sin(phase*math.pi*2*(.5+depth*1.4)+i*.77);
      _starPaint.color=Colors.white.withValues(alpha:(.018+depth*.12)*twinkle.clamp(.25,1));
      c.drawCircle(Offset(star.x*s.width+drift,star.y*s.height),.18+depth*1.05,_starPaint);
    }
    final hazeRect=Rect.fromCenter(center:Offset(center.dx,center.dy+short*.06),width:s.width*.92,height:short*.30);
    _hazePaint.shader=RadialGradient(colors:[const Color(0x1B8D78AA),const Color(0x0A526B89),Colors.transparent]).createShader(hazeRect); c.drawOval(hazeRect,_hazePaint);
    for(var i=0;i<5;i++){
      final rr=short*(.27+i*.072); final rot=math.sin(phase*math.pi*2+i)*.025;
      c.save(); c.translate(center.dx,center.dy); c.rotate(rot); c.translate(-center.dx,-center.dy);
      _ringPaint.strokeWidth=.42+i*.08; _ringPaint.color=const Color(0x167D8FA8);
      c.drawOval(Rect.fromCenter(center:center,width:rr*2.25,height:rr*.60),_ringPaint); c.restore();
    }
    final arcRect=Rect.fromCenter(center:center,width:short*.76,height:short*.235);
    _arcPaint.strokeWidth=1.15; _arcPaint.color=const Color(0x4D8D7CB4); c.drawArc(arcRect,phase*math.pi*2,1.12,false,_arcPaint);
    _secondaryArcPaint.strokeWidth=.55; _secondaryArcPaint.color=const Color(0x2E9DB1C1); c.drawArc(arcRect,phase*math.pi*2+math.pi,.42,false,_secondaryArcPaint);
    final core=short*.13;
    _coreGlowPaint.shader=RadialGradient(colors:[const Color(0x1E7D70A0),const Color(0x091D2D42),Colors.transparent]).createShader(Rect.fromCircle(center:center,radius:core*2.8)); c.drawCircle(center,core*2.8,_coreGlowPaint);
    _corePaint.shader=RadialGradient(colors:[const Color(0x4B8E86AE),const Color(0x0A8C7EA0),Colors.transparent]).createShader(Rect.fromCircle(center:center,radius:core*.62)); c.drawCircle(center,core*.62,_corePaint);
    final scan=(phase*s.height*1.25)%s.height; c.drawRect(Rect.fromLTWH(0,scan,s.width,1.1),_scanPaint);
    final scanBand=Rect.fromLTWH(0,scan-7,s.width,15); _scanBandPaint.shader=LinearGradient(colors:[Colors.transparent,const Color(0x052C5B7A),Colors.transparent]).createShader(scanBand); c.drawRect(scanBand,_scanBandPaint);
    const arm=34.0;
    c.drawLine(const Offset(18,arm),const Offset(18,18),_framePaint); c.drawLine(const Offset(18,18),const Offset(arm,18),_framePaint);
    c.drawLine(Offset(s.width-18,arm),Offset(s.width-18,18),_framePaint); c.drawLine(Offset(s.width-18,18),Offset(s.width-arm,18),_framePaint);
    c.drawLine(Offset(18,s.height-arm),Offset(18,s.height-18),_framePaint); c.drawLine(Offset(18,s.height-18),Offset(arm,s.height-18),_framePaint);
    c.drawLine(Offset(s.width-18,s.height-arm),Offset(s.width-18,s.height-18),_framePaint); c.drawLine(Offset(s.width-18,s.height-18),Offset(s.width-arm,s.height-18),_framePaint);
  }
  @override bool shouldRepaint(covariant _ArchiveAtmospherePainter old)=>old.phase!=phase;
}
