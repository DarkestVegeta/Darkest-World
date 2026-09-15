import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/darkest_world_navigation_state.dart';
import '../screens/galaxy_navigation_session.dart';

class DarkestWorldRelationConstellation extends StatefulWidget {
  const DarkestWorldRelationConstellation({super.key});
  @override State<DarkestWorldRelationConstellation> createState() => _DarkestWorldRelationConstellationState();
}

class _DarkestWorldRelationConstellationState extends State<DarkestWorldRelationConstellation> with SingleTickerProviderStateMixin {
  final session = GalaxyNavigationSession.instance;
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 110))..repeat();
  @override void initState(){super.initState();session.addListener(_changed);}
  void _changed(){if(mounted)setState((){});}
  @override void dispose(){session.removeListener(_changed);clock.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final nav=session.contentNavigation;
    if(nav==null)return const SizedBox.shrink();
    final compact=MediaQuery.sizeOf(context).width<850;
    return IgnorePointer(child: Positioned.fill(child: Padding(
      padding: EdgeInsets.fromLTRB(compact?12:42, compact?390:610, compact?12:42, compact?88:126),
      child: Align(alignment:Alignment.bottomCenter,child: SizedBox(
        height: compact?170:205,
        child: AnimatedBuilder(animation:clock,builder:(_,__)=>CustomPaint(
          painter:_ConstellationPainter(nav:nav,phase:clock.value,compact:compact),
          child: Padding(padding:EdgeInsets.all(compact?12:18),child:_Labels(nav:nav,compact:compact)),
        )),
      )),
    )));
  }
}

class _Labels extends StatelessWidget{
  final DarkestWorldNavigationState nav; final bool compact;
  const _Labels({required this.nav,required this.compact});
  @override Widget build(BuildContext context)=>Stack(children:[
    Align(alignment:Alignment.center,child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
      const Text('RELATION CONSTELLATION',style:TextStyle(fontSize:6,letterSpacing:2.4,color:Color(0x668F82A9))),
      const SizedBox(height:5),
      Text(nav.current.title.toUpperCase(),maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:compact?11:14,letterSpacing:1.6,fontWeight:FontWeight.w300)),
    ])),
    Align(alignment:Alignment.centerLeft,child:_NodeLabel('PREVIOUS',nav.previous?.title??'—')),
    Align(alignment:Alignment.centerRight,child:_NodeLabel('NEXT',nav.next?.title??'—',right:true)),
    if(!compact)Align(alignment:Alignment.topCenter,child:_NodeLabel('RELATED','${nav.related.length} CONNECTED WORLDS')),
  ]);
}
class _NodeLabel extends StatelessWidget{final String a,b;final bool right;const _NodeLabel(this.a,this.b,{this.right=false});@override Widget build(BuildContext context)=>Container(constraints:const BoxConstraints(maxWidth:170),padding:const EdgeInsets.symmetric(horizontal:7,vertical:5),color:const Color(0xB805060D),child:Column(crossAxisAlignment:right?CrossAxisAlignment.end:CrossAxisAlignment.start,children:[Text(a,style:const TextStyle(fontSize:5.2,letterSpacing:1.6,color:Color(0x557F90A4))),const SizedBox(height:2),Text(b,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:6.3,letterSpacing:.8))]));}

class _ConstellationPainter extends CustomPainter{
  final DarkestWorldNavigationState nav;final double phase;final bool compact;
  const _ConstellationPainter({required this.nav,required this.phase,required this.compact});
  @override void paint(Canvas c,Size s){
    final r=Offset.zero&s;final center=Offset(s.width*.5,s.height*.54);final left=Offset(s.width*.16,s.height*.58);final right=Offset(s.width*.84,s.height*.58);final top=Offset(s.width*.5,s.height*.12);
    c.drawRect(r,Paint()..shader=const RadialGradient(center:Alignment.center,radius:1.1,colors:[Color(0xC80B0B18),Color(0x6203040A),Color(0x00000000)]).createShader(r));
    final line=Paint()..style=PaintingStyle.stroke..strokeWidth=.65..color=const Color(0x337F70B0);
    c.drawLine(left,center,line);c.drawLine(center,right,line);if(!compact&&nav.related.isNotEmpty)c.drawLine(center,top,line);
    for(var i=0;i<5;i++){final rr=22+i*23.0;c.drawOval(Rect.fromCenter(center:center,width:rr*2.7,height:rr*.7),line);}
    final pulse=.5+.5*math.sin(phase*math.pi*2);final halo=Paint()..shader=RadialGradient(colors:[Color.fromRGBO(125,112,165,.20+.08*pulse),const Color(0x00000000)]).createShader(Rect.fromCircle(center:center,radius:40+18*pulse));c.drawCircle(center,40+18*pulse,halo);
    _node(c,left,12,nav.previous!=null);_node(c,center,20,true);_node(c,right,12,nav.next!=null);if(!compact&&nav.related.isNotEmpty)_node(c,top,9,true);
    for(var i=0;i<math.min(nav.related.length,6);i++){final a=-math.pi*.82+i*(math.pi*1.64/5);final p=Offset(center.dx+math.cos(a)*s.width*.33,center.dy+math.sin(a)*s.height*.36);_node(c,p,5,true);c.drawLine(center,p,Paint()..color=const Color(0x167F70B0)..strokeWidth=.45);}
  }
  void _node(Canvas c,Offset p,double radius,bool active){final fill=Paint()..shader=RadialGradient(colors:[active?const Color(0xC06D6388):const Color(0x555A6574),const Color(0x08000000)]).createShader(Rect.fromCircle(center:p,radius:radius*2.2));c.drawCircle(p,radius*2.2,fill);c.drawCircle(p,radius,Paint()..style=PaintingStyle.stroke..strokeWidth=active?1:.5..color=active?const Color(0x887F70B0):const Color(0x447F90A4));}
  @override bool shouldRepaint(covariant _ConstellationPainter old)=>old.phase!=phase||old.nav.current.id!=nav.current.id||old.nav.related.length!=nav.related.length;
}
