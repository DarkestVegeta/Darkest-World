import 'dart:math' as math;
import 'package:flutter/material.dart';

class DarkestGalaxy extends StatefulWidget {
  final List<GalaxyWorld> worlds;
  final ValueChanged<GalaxyWorld>? onWorldTap;
  const DarkestGalaxy({super.key, required this.worlds, this.onWorldTap});
  @override State<DarkestGalaxy> createState() => _DarkestGalaxyState();
}

class _DarkestGalaxyState extends State<DarkestGalaxy> with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(vsync:this,duration:const Duration(seconds:70))..repeat();
  int? selected;
  @override void dispose(){_motion.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>LayoutBuilder(builder:(context,c){
    final compact=c.maxWidth<800;
    return Stack(fit:StackFit.expand,children:[
      RepaintBoundary(child:CustomPaint(painter:_GalaxyPainter(_motion))),
      Center(child:InteractiveViewer(minScale:.72,maxScale:1.55,panEnabled:true,scaleEnabled:true,boundaryMargin:const EdgeInsets.all(180),child:_GalaxyMap(compact:compact,worlds:widget.worlds,selected:selected,onSelect:(i)=>setState(()=>selected=i)))),
      Positioned(left:28,top:24,child:_GalaxyHeading()),
      Positioned(right:22,bottom:24,child:_GalaxyHint()),
      if(selected!=null)Align(alignment:Alignment.bottomCenter,child:_WorldPanel(world:widget.worlds[selected!],onClose:()=>setState(()=>selected=null),onEnter:()=>widget.onWorldTap?.call(widget.worlds[selected!]))),
    ]);
  });
}

class _GalaxyMap extends StatelessWidget {
  final bool compact; final List<GalaxyWorld> worlds; final int? selected; final ValueChanged<int> onSelect;
  const _GalaxyMap({required this.compact,required this.worlds,required this.selected,required this.onSelect});
  @override Widget build(BuildContext context){
    final w=compact?780.0:1420.0,h=compact?760.0:860.0;
    final p=compact?const [Offset(360,275),Offset(70,80),Offset(555,65),Offset(55,395),Offset(585,390),Offset(220,555),Offset(375,85),Offset(625,555),Offset(115,610)]:const [Offset(625,320),Offset(75,150),Offset(500,35),Offset(1015,105),Offset(85,505),Offset(1000,455),Offset(390,620),Offset(745,125),Offset(1190,570)];
    final s=compact?const [230.0,105,92,118,100,94,82,105,88]:const [350.0,135,115,145,125,118,108,120,102];
    return SizedBox(width:w,height:h,child:Stack(children:[CustomPaint(size:Size(w,h),painter:_OrbitPainter()),for(var i=0;i<worlds.length&&i<p.length;i++)Positioned(left:p[i].dx,top:p[i].dy,child:_PlanetNode(world:worlds[i],size:s[i],index:i,central:i==0,selected:selected==i,onTap:()=>onSelect(i)))]));
  }
}

class _PlanetNode extends StatelessWidget {
  final GalaxyWorld world; final double size; final int index; final bool central,selected; final VoidCallback onTap;
  const _PlanetNode({required this.world,required this.size,required this.index,required this.central,required this.selected,required this.onTap});
  @override Widget build(BuildContext context)=>GestureDetector(onTap:onTap,child:SizedBox(width:size+210,height:size+90,child:Stack(clipBehavior:Clip.none,children:[
    if(central)Positioned(left:-28,top:-28,child:Container(width:size+56,height:size+56,decoration:BoxDecoration(shape:BoxShape.circle,gradient:RadialGradient(colors:[const Color(0xFF8E5DDE).withValues(alpha:.16),Colors.transparent]),boxShadow:[BoxShadow(color:const Color(0xFF426FC2).withValues(alpha:.10),blurRadius:90,spreadRadius:18)]))),
    if(selected)Positioned(left:-9,top:-9,child:Container(width:size+18,height:size+18,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:const Color(0xFFB084FF).withValues(alpha:.65)),boxShadow:[BoxShadow(color:const Color(0xFF7444FF).withValues(alpha:.30),blurRadius:38,spreadRadius:5)]))),
    Container(width:size,height:size,decoration:BoxDecoration(shape:BoxShape.circle,gradient:RadialGradient(center:const Alignment(-.38,-.4),radius:1,colors:_colors(world.kind),stops:const[0,.52,1]),boxShadow:[BoxShadow(color:const Color(0xFF6940B5).withValues(alpha:central?.38:.20),blurRadius:central?95:34,spreadRadius:central?12:2)]),child:CustomPaint(painter:_PlanetPainter(seed:index*71+19,kind:world.kind,central:central))),
    if(index==2||index==5||index==8)Positioned(left:size*.04,top:size*.36,child:Transform.rotate(angle:-.24,child:Container(width:size*.92,height:size*.18,decoration:BoxDecoration(border:Border.all(color:Colors.white.withValues(alpha:.10)),borderRadius:BorderRadius.circular(100))))),
    if(index==3||index==6)Positioned(left:size*.72,top:size*.10,child:Container(width:size*.18,height:size*.18,decoration:BoxDecoration(shape:BoxShape.circle,color:const Color(0xFF8FA9D6).withValues(alpha:.48),boxShadow:[BoxShadow(color:const Color(0xFF617CB0).withValues(alpha:.25),blurRadius:10)]))),
    Positioned(left:size+18,top:size*.46,child:_WorldLabel(world.title,active:central||selected)),
  ])));
  List<Color> _colors(GalaxyWorldKind k)=>switch(k){GalaxyWorldKind.vegeta=>const[Color(0xFF7551A9),Color(0xFF282039),Color(0xFF05030A)],GalaxyWorldKind.game=>const[Color(0xFF6350B8),Color(0xFF292052),Color(0xFF070511)],GalaxyWorldKind.music=>const[Color(0xFF4D83C0),Color(0xFF1F3A68),Color(0xFF050914)],GalaxyWorldKind.identity=>const[Color(0xFF985CC0),Color(0xFF351E4B),Color(0xFF08040D)],GalaxyWorldKind.family=>const[Color(0xFF6489B2),Color(0xFF27384E),Color(0xFF060A11)],GalaxyWorldKind.cinema=>const[Color(0xFF9A6CB8),Color(0xFF3B274D),Color(0xFF09060D)],GalaxyWorldKind.creation=>const[Color(0xFF5883C0),Color(0xFF263F6D),Color(0xFF050A13)],GalaxyWorldKind.archive=>const[Color(0xFF77718D),Color(0xFF302D3E),Color(0xFF09080D)],GalaxyWorldKind.comingSoon=>const[Color(0xFFA175DC),Color(0xFF3D285E),Color(0xFF0A0611)]};
}

class _WorldLabel extends StatelessWidget{final String text;final bool active;const _WorldLabel(this.text,{required this.active});@override Widget build(BuildContext context)=>Text(text,style:TextStyle(fontSize:active?11:9,letterSpacing:active?2.8:2.0,color:Colors.white.withValues(alpha:active?.92:.58),shadows:const[Shadow(color:Colors.black,blurRadius:16)]));}
class _GalaxyHeading extends StatelessWidget{@override Widget build(BuildContext context)=>IgnorePointer(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('DARKESTWORLD',style:TextStyle(fontSize:15,letterSpacing:6,color:Colors.white.withValues(alpha:.84))),const SizedBox(height:5),Text('GALAXY',style:TextStyle(fontSize:8,letterSpacing:4,color:Colors.white.withValues(alpha:.35)))]));}
class _GalaxyHint extends StatelessWidget{@override Widget build(BuildContext context)=>IgnorePointer(child:Text('DRAG • ZOOM • EXPLORE',style:TextStyle(fontSize:8,letterSpacing:2.6,color:Colors.white.withValues(alpha:.28))));}
enum GalaxyWorldKind{vegeta,game,music,identity,family,cinema,creation,archive,comingSoon}
class GalaxyWorld{final String title;final String description;final GalaxyWorldKind kind;const GalaxyWorld(this.title,this.description,this.kind);}

class _GalaxyPainter extends CustomPainter{final Animation<double> animation;_GalaxyPainter(this.animation):super(repaint:animation);@override void paint(Canvas canvas,Size size){final rect=Offset.zero&size;canvas.drawRect(rect,Paint()..shader=const RadialGradient(center:Alignment(0,-.1),radius:1.12,colors:[Color(0xFF160C29),Color(0xFF05030B),Color(0xFF010106)]).createShader(rect));final c=Offset(size.width*.5,size.height*.5);final neb=Rect.fromCenter(center:c,width:size.width*.78,height:size.height*.46);canvas.drawOval(neb,Paint()..shader=LinearGradient(colors:[const Color(0xFF7C4FC4).withValues(alpha:.09),const Color(0xFF356BB0).withValues(alpha:.035),Colors.transparent]).createShader(neb));final r=math.Random(731),star=Paint();for(var i=0;i<720;i++){final x=r.nextDouble()*size.width,y=r.nextDouble()*size.height,p=.22+.78*((math.sin(animation.value*math.pi*2+i*1.37)+1)/2);star.color=Colors.white.withValues(alpha:(.025+r.nextDouble()*.30)*p);canvas.drawCircle(Offset(x,y),r.nextDouble()*1.35,star);}final dust=Paint()..color=const Color(0xFF8A69C9).withValues(alpha:.14);for(var i=0;i<85;i++){final a=animation.value*math.pi*2+i*math.pi*2/85;canvas.drawCircle(c+Offset(math.cos(a)*size.width*.34,math.sin(a)*size.height*.20),.9,dust);}}@override bool shouldRepaint(covariant _GalaxyPainter oldDelegate)=>false;}

class _OrbitPainter extends CustomPainter{@override void paint(Canvas canvas,Size size){final c=Offset(size.width*.5,size.height*.47);final p=Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0xFF8968C2).withValues(alpha:.10);for(final q in[190.0,310.0,430.0])canvas.drawOval(Rect.fromCenter(center:c,width:q*2,height:q*.64),p);final p2=Paint()..color=const Color(0xFF4C79B7).withValues(alpha:.055);canvas.drawOval(Rect.fromCenter(center:c,width:900,height:300),p2);} @override bool shouldRepaint(covariant _OrbitPainter oldDelegate)=>false;}

class _PlanetPainter extends CustomPainter{final int seed;final GalaxyWorldKind kind;final bool central;_PlanetPainter({required this.seed,required this.kind,required this.central});@override void paint(Canvas canvas,Size size){final c=size.center(Offset.zero),r=size.width/2,random=math.Random(seed);final haze=Paint()..color=Colors.white.withValues(alpha:central?.055:.035);for(var i=0;i<8;i++){final y=c.dy-r*.68+i*r*.19;canvas.drawOval(Rect.fromCenter(center:Offset(c.dx,y),width:r*(1.2+i*.09),height:r*.09),haze);}final detail=Paint();for(var i=0;i<(central?100:42);i++){final x=c.dx+(random.nextDouble()*2-1)*r*.82,y=c.dy+(random.nextDouble()*2-1)*r*.82;if((Offset(x,y)-c).distance<r*.88){detail.color=Colors.white.withValues(alpha:.025+random.nextDouble()*.055);canvas.drawCircle(Offset(x,y),random.nextDouble()*1.7,detail);}}if(kind==GalaxyWorldKind.vegeta){final crack=Paint()..color=const Color(0xFF0A0610).withValues(alpha:.75)..style=PaintingStyle.stroke..strokeWidth=r*.014;final path=Path()..moveTo(c.dx-r*.56,c.dy-r*.10)..lineTo(c.dx-r*.18,c.dy+r*.01)..lineTo(c.dx-r*.32,c.dy+r*.36)..moveTo(c.dx+r*.04,c.dy-r*.62)..lineTo(c.dx-r*.01,c.dy-r*.20)..lineTo(c.dx+r*.29,c.dy+r*.12)..moveTo(c.dx+r*.44,c.dy+r*.33)..lineTo(c.dx+r*.17,c.dy+r*.20);canvas.drawPath(path,crack);}}@override bool shouldRepaint(covariant _PlanetPainter oldDelegate)=>false;}

class _WorldPanel extends StatelessWidget{final GalaxyWorld world;final VoidCallback onClose,onEnter;const _WorldPanel({required this.world,required this.onClose,required this.onEnter});@override Widget build(BuildContext context)=>Container(width:math.min(MediaQuery.sizeOf(context).width-40,520),margin:const EdgeInsets.only(bottom:22),padding:const EdgeInsets.fromLTRB(20,17,12,17),decoration:BoxDecoration(color:const Color(0xFF08050D).withValues(alpha:.95),borderRadius:BorderRadius.circular(15),border:Border.all(color:const Color(0xFF9367D0).withValues(alpha:.25)),boxShadow:[BoxShadow(color:const Color(0xFF713FB0).withValues(alpha:.15),blurRadius:40)]),child:Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(world.title,style:const TextStyle(fontSize:13,letterSpacing:2.7)),const SizedBox(height:6),Text(world.description,style:TextStyle(fontSize:11,height:1.45,color:Colors.white.withValues(alpha:.48)))])),IconButton(onPressed:onClose,icon:const Icon(Icons.close,size:17)),TextButton(onPressed:onEnter,child:const Text('ENTER'))]));}
