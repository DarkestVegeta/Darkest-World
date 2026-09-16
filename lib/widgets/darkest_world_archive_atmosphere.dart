import 'dart:math' as math;
import 'dart:typed_data';
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
  @override Widget build(BuildContext context)=>IgnorePointer(child:CustomPaint(painter:_ArchiveAtmospherePainter(_clock),size:Size.infinite));
}

class _ArchiveStar {
  final double x,y,driftFrequency,driftPhaseCycles,driftScale,twinkleFrequency,twinklePhaseCycles,radius,alpha;
  const _ArchiveStar(this.x,this.y,this.driftFrequency,this.driftPhaseCycles,this.driftScale,this.twinkleFrequency,this.twinklePhaseCycles,this.radius,this.alpha);
}

class _ArchiveAtmospherePainter extends CustomPainter {
  final Animation<double> phase; _ArchiveAtmospherePainter(this.phase):super(repaint:phase);
  static const int _lutSize=1024;
  static const int _lutMask=_lutSize-1;
  static final Float32List _sinLut=Float32List.fromList(List.generate(_lutSize+1,(i)=>math.sin(i*math.pi*2/_lutSize)));
  static final List<_ArchiveStar> _stars=List.generate(520,(i){
    final rng=math.Random(4207+i*17); final depth=rng.nextDouble();
    return _ArchiveStar(rng.nextDouble(),rng.nextDouble(),.25+depth*.7,i*.31/(math.pi*2),.7+depth*2.2,.5+depth*1.4,i*.77/(math.pi*2),.18+depth*1.05,.018+depth*.12);
  });
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
  static const List<double> _ringStrokeWidths=[.42,.50,.58,.66,.74];
  static const List<double> _ringPhaseOffsets=[0,.1591549431,.3183098862,.4774648293,.6366197724];
  Size _cachedSize=Size.zero; bool _geometryReady=false;
  late Offset _center;
  late Rect _fullRect,_hazeRect,_coreGlowRect,_coreRect,_arcRect,_scanBandRect;
  late double _short,_core;
  late Shader _backgroundShader,_hazeShader,_coreGlowShader,_coreShader,_scanBandShader;
  late List<Rect> _ringRects;
  late List<Offset> _frameStarts,_frameEnds;
  late Path _framePath;
  late Float32List _starBaseXY;
  static double _sin(double cycles){final position=cycles*_lutSize;final whole=position.floor();final base=whole&_lutMask;final fraction=position-whole;final a=_sinLut[base];return a+(_sinLut[base+1]-a)*fraction;}
  void _ensureGeometry(Size s){
    if(_geometryReady&&_cachedSize==s)return;
    _cachedSize=s;_short=math.min(s.width,s.height);_center=Offset(s.width*.5,s.height*.46);
    _fullRect=Offset.zero&s;_hazeRect=Rect.fromCenter(center:Offset(_center.dx,_center.dy+_short*.06),width:s.width*.92,height:_short*.30);_arcRect=Rect.fromCenter(center:_center,width:_short*.76,height:_short*.235);_core=_short*.13;_coreGlowRect=Rect.fromCircle(center:_center,radius:_core*2.8);_coreRect=Rect.fromCircle(center:_center,radius:_core*.62);
    _scanBandRect=Rect.fromLTWH(0,0,s.width,15);
    _scanBandShader=LinearGradient(colors:[Colors.transparent,const Color(0x052C5B7A),Colors.transparent]).createShader(_scanBandRect);
    _starBaseXY=Float32List(_stars.length*2);
    for(var i=0;i<_stars.length;i++){final star=_stars[i];final base=i*2;_starBaseXY[base]=star.x*s.width;_starBaseXY[base+1]=star.y*s.height;}
    _ringRects=List.generate(5,(i){final rr=_short*(.27+i*.072);return Rect.fromCenter(center:_center,width:rr*2.25,height:rr*.60);});const arm=34.0;
    _frameStarts=[const Offset(18,arm),const Offset(18,18),Offset(s.width-18,arm),Offset(s.width-18,18),Offset(18,s.height-arm),Offset(18,s.height-18),Offset(s.width-18,s.height-arm),Offset(s.width-18,s.height-18)];
    _frameEnds=[const Offset(18,18),const Offset(arm,18),Offset(s.width-18,18),Offset(s.width-arm,18),Offset(18,s.height-18),Offset(arm,s.height-18),Offset(s.width-18,s.height-18),Offset(s.width-arm,s.height-18)];
    _framePath=Path();
    for(var i=0;i<_frameStarts.length;i++){_framePath.moveTo(_frameStarts[i].dx,_frameStarts[i].dy);_framePath.lineTo(_frameEnds[i].dx,_frameEnds[i].dy);}
    _backgroundShader=RadialGradient(center:const Alignment(0,.05),radius:1.05,colors:[Colors.transparent,const Color(0x16040A18),const Color(0xA8010308)],stops:const[.34,.72,1]).createShader(_fullRect);_hazeShader=RadialGradient(colors:[const Color(0x1B8D78AA),const Color(0x0A526B89),Colors.transparent]).createShader(_hazeRect);_coreGlowShader=RadialGradient(colors:[const Color(0x1E7D70A0),const Color(0x091D2D42),Colors.transparent]).createShader(_coreGlowRect);_coreShader=RadialGradient(colors:[const Color(0x4B8E86AE),const Color(0x0A8C7EA0),Colors.transparent]).createShader(_coreRect);_geometryReady=true;
  }
  @override void paint(Canvas c,Size s){
    _ensureGeometry(s);final phaseCycles=phase.value;final phaseAngle=phaseCycles*math.pi*2;_backgroundPaint.shader=_backgroundShader;c.drawRect(_fullRect,_backgroundPaint);
    for(var i=0;i<_stars.length;i++){final star=_stars[i];final base=i*2;final drift=_sin(phaseCycles*star.driftFrequency+star.driftPhaseCycles)*star.driftScale;final twinkle=.45+.55*_sin(phaseCycles*star.twinkleFrequency+star.twinklePhaseCycles);_starPaint.color=Colors.white.withValues(alpha:(star.alpha*twinkle).clamp(.25,1));c.drawCircle(Offset(_starBaseXY[base]+drift,_starBaseXY[base+1]),star.radius,_starPaint);}
    _hazePaint.shader=_hazeShader;c.drawOval(_hazeRect,_hazePaint);
    for(var i=0;i<5;i++){final rot=_sin(phaseCycles+_ringPhaseOffsets[i])*.025;c.save();c.translate(_center.dx,_center.dy);c.rotate(rot);c.translate(-_center.dx,-_center.dy);_ringPaint.strokeWidth=_ringStrokeWidths[i];_ringPaint.color=const Color(0x167D8FA8);c.drawOval(_ringRects[i],_ringPaint);c.restore();}
    _arcPaint.strokeWidth=1.15;_arcPaint.color=const Color(0x4D8D7CB4);c.drawArc(_arcRect,phaseAngle,1.12,false,_arcPaint);_secondaryArcPaint.strokeWidth=.55;_secondaryArcPaint.color=const Color(0x2E9DB1C1);c.drawArc(_arcRect,phaseAngle+math.pi,.42,false,_secondaryArcPaint);
    _coreGlowPaint.shader=_coreGlowShader;c.drawCircle(_center,_core*2.8,_coreGlowPaint);_corePaint.shader=_coreShader;c.drawCircle(_center,_core*.62,_corePaint);
    final scan=(phaseCycles*s.height*1.25)%s.height;c.drawLine(Offset.zero,Offset(s.width,scan),_scanPaint);
    c.save();c.translate(0,scan-7);_scanBandPaint.shader=_scanBandShader;c.drawRect(_scanBandRect,_scanBandPaint);c.restore();
    c.drawPath(_framePath,_framePaint);
  }
  @override bool shouldRepaint(covariant _ArchiveAtmospherePainter old)=>false;
}