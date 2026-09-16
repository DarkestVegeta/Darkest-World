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
        child: CustomPaint(
          painter:_ConstellationPainter(nav:nav,phase:clock,compact:compact),
          child: Padding(padding:EdgeInsets.all(compact?12:18),child:_Labels(nav:nav,compact:compact)),
        ),
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
  final DarkestWorldNavigationState nav;final Animation<double> phase;final bool compact;
  static final Paint _background=Paint();
  static final Paint _line=Paint()..style=PaintingStyle.stroke..strokeWidth=.65..color=const Color(0x337F70B0);
  static final Paint _halo=Paint();
  static final Paint _nodeFill=Paint();
  static final Paint _nodeStroke=Paint()..style=PaintingStyle.stroke;
  late Size _cachedSize;
  late Offset _center;
  late Offset _left;
  late Offset _right;
  late Offset _top;
  late List<Rect> _rings;
  late List<Offset> _related;
  late int _relatedCount;
  bool _geometryReady=false;
  const _ConstellationPainter({required this.nav,required this.phase,required this.compact}):super(repaint:phase);

  void _ensureGeometry(Size s){
    if(_geometryReady&&_cachedSize==s)return;
    _cachedSize=s;
    _center=Offset(s.width*.5,s.height*.54);
    _left=Offset(s.width*.16,s.height*.58);
    _right=Offset(s.width*.84,s.height*.58);
    _top=Offset(s.width*.5,s.height*.12);
    _rings=List<Rect>.generate(5,(i){final rr=22+i*23.0;return Rect.fromCenter(center:_center,width:rr*2.7,height:rr*.7);},growable:false);
    _relatedCount=math.min(nav.related.length,6);
    _related=List<Offset>.generate(_relatedCount,(i){final a=-math.pi*.82+i*(math.pi*1.64/5);return Offset(_center.dx+math.cos(a)*s.width*.33,_center.dy+math.sin(a)*s.height*.36);},growable:false);
    _geometryReady=true;
  }

  @override void paint(Canvas c,Size s){
    _ensureGeometry(s);
    final r=Offset.zero&s;
    _background.shader=const RadialGradient(center:Alignment.center,radius:1.1,colors:[Color(0xC80B0B18),Color(0x6203040A),Color(0x00000000)]).createShader(r);
    c.drawRect(r,_background);
    c.drawLine(_left,_center,_line);c.drawLine(_center,_right,_line);if(!compact&&nav.related.isNotEmpty)c.drawLine(_center,_top,_line);
    for(final ring in _rings)c.drawOval(ring,_line);
    final pulse=.5+.5*math.sin(phase.value*math.pi*2);_halo.shader=RadialGradient(colors:[Color.fromRGBO(125,112,165,.20+.08*pulse),const Color(0x00000000)]).createShader(Rect.fromCircle(center:_center,radius:40+18*pulse));c.drawCircle(_center,40+18*pulse,_halo);
    _node(c,_left,12,nav.previous!=null);_node(c,_center,20,true);_node(c,_right,12,nav.next!=null);if(!compact&&nav.related.isNotEmpty)_node(c,_top,9,true);
    for(final p in _related){_node(c,p,5,true);c.drawLine(_center,p,_line);}
  }
  void _node(Canvas c,Offset p,double radius,bool active){_nodeFill.shader=RadialGradient(colors:[active?const Color(0xC06D6388):const Color(0x555A6574),const Color(0x08000000)]).createShader(Rect.fromCircle(center:p,radius:radius*2.2));c.drawCircle(p,radius*2.2,_nodeFill);_nodeStroke.strokeWidth=active?1:.5;_nodeStroke.color=active?const Color(0x887F70B0):const Color(0x447F90A4);c.drawCircle(p,radius,_nodeStroke);}
  @override bool shouldRepaint(covariant _ConstellationPainter old)=>old.nav.current.id!=nav.current.id||old.nav.related.length!=nav.related.length||old.compact!=compact;
}
