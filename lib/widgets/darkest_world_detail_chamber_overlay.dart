import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/galaxy_navigation_session.dart';

class DarkestWorldDetailChamberOverlay extends StatefulWidget {
  const DarkestWorldDetailChamberOverlay({super.key});
  @override State<DarkestWorldDetailChamberOverlay> createState()=>_DetailChamberOverlayState();
}

class _DetailChamberOverlayState extends State<DarkestWorldDetailChamberOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _clock=AnimationController(vsync:this,duration:const Duration(seconds:92))..repeat();
  @override void initState(){super.initState();GalaxyNavigationSession.instance.addListener(_changed);}
  void _changed(){if(mounted)setState((){});}
  @override void dispose(){GalaxyNavigationSession.instance.removeListener(_changed);_clock.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final state=GalaxyNavigationSession.instance.contentNavigation;
    if(state==null)return const SizedBox.shrink();
    final compact=MediaQuery.sizeOf(context).width<900;
    return IgnorePointer(child:AnimatedBuilder(animation:_clock,builder:(_,__)=>Positioned.fill(child:CustomPaint(painter:_ChamberPainter(_clock.value),child:compact?_CompactPanel(state:state):_WidePanel(state:state)))));
  }
}

class _WidePanel extends StatelessWidget{
 final DarkestWorldNavigationState state;const _WidePanel({required this.state});
 @override Widget build(BuildContext context)=>Align(alignment:Alignment.bottomCenter,child:Padding(padding:const EdgeInsets.fromLTRB(30,0,30,30),child:Container(height:118,padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:const Color(0xD9080912),border:Border.all(color:const Color(0x447F70B0)),boxShadow:const [BoxShadow(color:Colors.black87,blurRadius:28)]),child:Row(children:[Expanded(flex:3,child:_Block(label:'ENTRY',value:state.entryLabel)),Expanded(flex:6,child:_Current(item:state.current)),Expanded(flex:3,child:_Block(label:'RELATIONS',value:'${state.related.length.toString().padLeft(2,'0')} CONNECTED'))]))));
}
class _CompactPanel extends StatelessWidget{
 final DarkestWorldNavigationState state;const _CompactPanel({required this.state});
 @override Widget build(BuildContext context)=>Align(alignment:Alignment.bottomCenter,child:Padding(padding:const EdgeInsets.all(12),child:Container(padding:const EdgeInsets.all(11),decoration:BoxDecoration(color:const Color(0xD9080912),border:Border.all(color:const Color(0x447F70B0))),child:Row(children:[_Block(label:'ENTRY',value:state.entryLabel),const Spacer(),Expanded(child:_Current(item:state.current)),const Spacer(),_Block(label:'REL',value:'${state.related.length}')] ))));
}
class _Current extends StatelessWidget{final ContentItem item;const _Current({required this.item});@override Widget build(BuildContext context)=>Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.center,children:[const Text('CURRENT ARCHIVE OBJECT',style:TextStyle(fontSize:5.5,letterSpacing:2.2,color:Color(0x668F82A9))),const SizedBox(height:6),Text(item.title.toUpperCase(),maxLines:1,overflow:TextOverflow.ellipsis,textAlign:TextAlign.center,style:const TextStyle(fontSize:11,letterSpacing:1.7,fontWeight:FontWeight.w300)),const SizedBox(height:5),Text(item.type.name.toUpperCase(),style:const TextStyle(fontSize:5.5,letterSpacing:1.7,color:Color(0x558F82A9))) ]);}
class _Block extends StatelessWidget{final String label,value;const _Block({required this.label,required this.value});@override Widget build(BuildContext context)=>Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(fontSize:5.5,letterSpacing:2,color:Color(0x557F8AA2))),const SizedBox(height:5),Text(value.toUpperCase(),maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:6.5,letterSpacing:1.2,color:Color(0xAAFFFFFF))) ]);}

class _ChamberPainter extends CustomPainter{
 final double phase;const _ChamberPainter(this.phase);
 @override void paint(Canvas c,Size s){
  final center=Offset(s.width*.5,s.height*.57),m=math.min(s.width,s.height);
  final bg=Rect.fromLTWH(0,0,s.width,s.height);c.drawRect(bg,Paint()..shader=const RadialGradient(center:Alignment(0,.1),radius:1.05,colors:[Color(0x1C40345A),Color(0x090A0B18),Colors.transparent]).createShader(bg));
  for(var i=0;i<8;i++){final f=.22+i*.055;c.drawOval(Rect.fromCenter(center:center,width:m*f*2.5,height:m*f),Paint()..style=PaintingStyle.stroke..strokeWidth=.42..color=Color(0x147F70B0));}
  final a=phase*math.pi*2;c.drawArc(Rect.fromCenter(center:center,width:m*.86,height:m*.34),a,.72,false,Paint()..style=PaintingStyle.stroke..strokeWidth=1.1..strokeCap=StrokeCap.round..color=const Color(0x508F82B9));
  for(var i=0;i<70;i++){final seed=i*17.31, x=(math.sin(seed)*.5+.5)*s.width,y=(math.cos(seed*.77)*.5+.5)*s.height,r=.35+(i%3)*.32;c.drawCircle(Offset(x,y),r,Paint()..color=const Color(0x35D3D8E2));}
  final scan=(phase*s.height*1.1)%(s.height+70)-35;c.drawRect(Rect.fromLTWH(0,scan,s.width,1),Paint()..color=const Color(0x117F9AB0));
  final veil=Rect.fromLTWH(0,0,s.width,s.height);c.drawRect(veil,Paint()..shader=const LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Color(0x11000000),Colors.transparent,Color(0x50000000)]).createShader(veil));
 }
 @override bool shouldRepaint(covariant _ChamberPainter old)=>old.phase!=phase;
}
