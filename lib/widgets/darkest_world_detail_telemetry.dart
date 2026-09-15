import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/galaxy_navigation_session.dart';

class DarkestWorldDetailTelemetry extends StatefulWidget {
  const DarkestWorldDetailTelemetry({super.key});
  @override State<DarkestWorldDetailTelemetry> createState() => _DarkestWorldDetailTelemetryState();
}

class _DarkestWorldDetailTelemetryState extends State<DarkestWorldDetailTelemetry> with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this, duration: const Duration(seconds: 72))..repeat();
  final session = GalaxyNavigationSession.instance;
  @override void initState(){super.initState(); session.addListener(_changed);}
  @override void dispose(){session.removeListener(_changed); _clock.dispose(); super.dispose();}
  void _changed(){if(mounted)setState((){});}
  @override Widget build(BuildContext context){
    final nav=session.contentNavigation;
    if(nav==null) return const SizedBox.shrink();
    final compact=MediaQuery.sizeOf(context).width<900;
    return IgnorePointer(child: AnimatedBuilder(animation:_clock,builder:(_,__)=>Align(alignment:Alignment.topRight,child:SafeArea(child:Padding(padding:EdgeInsets.fromLTRB(0,compact?76:92,compact?10:22,0),child:Container(width:compact?180:250,padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:const Color(0xC9060710),border:Border.all(color:const Color(0x337F70B0)),boxShadow:const[BoxShadow(color:Colors.black54,blurRadius:22)]),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[const Text('DETAIL INTEL',style:TextStyle(fontSize:6.5,letterSpacing:2.1,color:Color(0x889A8AC4))),const Spacer(),Text(nav.entryLabel,style:const TextStyle(fontSize:5.5,letterSpacing:1.2,color:Color(0x557F8AA2)))]),const SizedBox(height:8),Text(nav.current.title.toUpperCase(),maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:8.5,letterSpacing:1.2)),const SizedBox(height:8),CustomPaint(size:Size(double.infinity,18),painter:_SignalPainter(_clock.value)),const SizedBox(height:7),Row(children:[_Stat('PREV',nav.previous==null?'—':'READY'),_Stat('NEXT',nav.next==null?'—':'READY'),_Stat('REL', '${nav.related.length}')]),])))))));
  }
}
class _Stat extends StatelessWidget{final String a,b;const _Stat(this.a,this.b);@override Widget build(BuildContext c)=>Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(a,style:const TextStyle(fontSize:4.8,letterSpacing:1.2,color:Color(0x447F90A4))),const SizedBox(height:2),Text(b,style:const TextStyle(fontSize:6.5,letterSpacing:1))]));}
class _SignalPainter extends CustomPainter{final double phase;const _SignalPainter(this.phase);@override void paint(Canvas c,Size s){final p=Paint()..style=PaintingStyle.stroke..strokeWidth=.8..color=const Color(0x557F70B0);final path=Path();for(var i=0;i<36;i++){final x=i*s.width/35;final y=s.height*.5+math.sin(i*.72+phase*math.pi*2)*s.height*.22;path.lineTo(x,y);}c.drawPath(path,p);final x=(phase*s.width*1.4)%s.width;c.drawLine(Offset(x,0),Offset(x,s.height),Paint()..color=const Color(0x778A78B5));} @override bool shouldRepaint(covariant _SignalPainter old)=>old.phase!=phase;}
