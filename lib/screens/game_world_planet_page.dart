import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_platform_page.dart';

class GameWorldPlanetPage extends StatefulWidget { const GameWorldPlanetPage({super.key}); @override State<GameWorldPlanetPage> createState()=>_GameWorldPlanetPageState(); }
class _TerritoryData { final String name,description; final List<GamePlatformGroup> groups; _TerritoryData(this.name,this.description,this.groups); }
class _GameWorldPlanetPageState extends State<GameWorldPlanetPage>{
  int? selected;
  late final territories=<_TerritoryData>[
    _TerritoryData('NINTENDO','Nintendo generations.',[GamePlatformGroup('HOME CONSOLES','Home generations.',[GamePlatform('NES',[18]),GamePlatform('SNES',[19]),GamePlatform('N64',[4]),GamePlatform('GameCube',[21]),GamePlatform('Wii',[5]),GamePlatform('Wii U',[41]),GamePlatform('Switch',[130])]),GamePlatformGroup('HANDHELD','Portable generations.',[GamePlatform('Game Boy',[33]),GamePlatform('Game Boy Color',[22]),GamePlatform('Game Boy Advance',[24]),GamePlatform('DS',[20]),GamePlatform('3DS',[37])])]),
    _TerritoryData('SEGA','Sega generations.',[GamePlatformGroup('CONSOLES','Console generations.',[GamePlatform('Master System',[64]),GamePlatform('Mega Drive',[29]),GamePlatform('Saturn',[32]),GamePlatform('Dreamcast',[23])]),GamePlatformGroup('PORTABLE','Portable generation.',[GamePlatform('Game Gear',[35])])]),
    _TerritoryData('PLAYSTATION','PlayStation generations.',[GamePlatformGroup('GENERATIONS','Main generations.',[GamePlatform('PlayStation',[7]),GamePlatform('PlayStation 2',[8]),GamePlatform('PlayStation 3',[9]),GamePlatform('PlayStation 4',[48]),GamePlatform('PlayStation 5',[167])])]),
    _TerritoryData('XBOX','Xbox generations.',[GamePlatformGroup('GENERATIONS','Main generations.',[GamePlatform('Xbox',[11]),GamePlatform('Xbox 360',[12]),GamePlatform('Xbox One',[49]),GamePlatform('Xbox Series',[169])])])];
  void enter(int i)=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>GamePlatformPage(territory:territories[i].name,groups:territories[i].groups)));
  @override Widget build(BuildContext context)=>Scaffold(backgroundColor:const Color(0xFF010307),body:LayoutBuilder(builder:(context,box){final compact=box.maxWidth<760,d=math.min(box.maxWidth*.86,box.maxHeight*.86);return Stack(children:[Positioned.fill(child:CustomPaint(painter:_GameSpacePainter())),SafeArea(child:Padding(padding:EdgeInsets.all(compact?14:28),child:Row(children:[IconButton(onPressed:()=>Navigator.of(context).pop(),icon:const Icon(Icons.arrow_back_ios_new,size:16)),const SizedBox(width:10),const Text('GAME-WORLD',style:TextStyle(fontSize:16,letterSpacing:4)),const Spacer(),const Text('WORLD',style:TextStyle(fontSize:8,letterSpacing:3,color:Colors.white30))]))),Center(child:SizedBox(width:d,height:d,child:GestureDetector(onTapUp:(e){final h=_hit(e.localPosition,d);if(h!=null)setState(()=>selected=selected==h?null:h);},child:CustomPaint(painter:_GamePlanetPainter(selected:selected),child:Stack(children:[_label('NINTENDO',.27,.27,0,d),_label('SEGA',.73,.28,1,d),_label('PLAYSTATION',.27,.73,2,d),_label('XBOX',.73,.72,3,d),Center(child:Opacity(opacity:selected==null?1:.18,child:const Text('GAME-WORLD',style:TextStyle(fontSize:12,letterSpacing:5,color:Colors.white54))))]))))),if(selected!=null)Positioned(left:compact?14:30,right:compact?14:30,bottom:compact?45:58,child:Center(child:Container(padding:const EdgeInsets.all(16),constraints:const BoxConstraints(maxWidth:620),decoration:BoxDecoration(color:const Color(0xE6090913),borderRadius:BorderRadius.circular(16),border:Border.all(color:const Color(0x337F70B0))),child:Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(territories[selected!].name,style:const TextStyle(fontSize:13,letterSpacing:3)),const SizedBox(height:5),Text(territories[selected!].description,style:const TextStyle(fontSize:9,color:Colors.white38))])),TextButton(onPressed:()=>enter(selected!),child:const Text('ENTER'))])))),Positioned(left:compact?16:30,bottom:compact?18:26,child:Text(selected==null?'SELECT A REGION':'SELECTED REGION  •  ENTER TO OPEN',style:const TextStyle(fontSize:8,letterSpacing:2.4,color:Colors.white24))) ]);}));
  Widget _label(String text,double x,double y,int i,double d){final a=(selected==null||selected==i)? .76 : .12;return Positioned(left:d*x-80,top:d*y-22,width:160,child:IgnorePointer(child:Center(child:Text(text,style:TextStyle(fontSize:selected==i?11:9,letterSpacing:2.4,color:Colors.white.withValues(alpha:a))))));}
  int? _hit(Offset p,double d){final o=Offset(d/2,d/2),r=d*.49;const centers=[Offset(-.29,-.25),Offset(.29,-.25),Offset(-.29,.26),Offset(.29,.26)];for(var i=0;i<4;i++){final q=o+Offset(centers[i].dx*r,centers[i].dy*r);if((p-q).distance<r*.32)return i;}return null;}
}
class _GamePlanetPainter extends CustomPainter{
  final int? selected; const _GamePlanetPainter({required this.selected});
  static const centers=[Offset(-.29,-.25),Offset(.29,-.25),Offset(-.29,.26),Offset(.29,.26)];
  static const colors=[Color(0xFF9175A9),Color(0xFF66829A),Color(0xFF786C98),Color(0xFF5D847A)];
  @override void paint(Canvas canvas,Size size){
    final c=Offset(size.width*.5,size.height*.5),r=size.shortestSide*.47,sphere=Rect.fromCircle(center:c,radius:r),rnd=math.Random(442);
    canvas.drawCircle(c,r*1.28,Paint()..shader=const RadialGradient(colors:[Color(0x425E7396),Color(0x185E7396),Colors.transparent],stops:[0,.50,1]).createShader(Rect.fromCircle(center:c,radius:r*1.28)));
    canvas.drawCircle(c,r,Paint()..shader=const RadialGradient(center:Alignment(-.46,-.55),radius:1.10,colors:[Color(0xFFC0B7AE),Color(0xFF807C82),Color(0xFF41434D),Color(0xFF171A22),Color(0xFF05070C)],stops:[0,.16,.43,.72,1]).createShader(sphere));
    canvas.save();canvas.clipPath(Path()..addOval(sphere));
    for(var i=0;i<4;i++){
      final tc=c+Offset(centers[i].dx*r,centers[i].dy*r);
      final active=selected==null ? .25 : (selected==i ? .58 : .025);
      final w=r*.42,h=r*.31,rot=(i.isEven ? .18 : -.18)+(i<2 ? .08 : -.08);
      final path=_territory(tc,w,h,rot,rnd,30);
      canvas.drawPath(path,Paint()..color=colors[i].withValues(alpha:active));
      canvas.drawPath(path,Paint()..style=PaintingStyle.stroke..strokeWidth=selected==i?2.2:1..color=colors[i].withValues(alpha:selected==i ? .78 : .16));
      for(var q=1;q<=5;q++){
        final scale=1-q*.10;
        final inner=_territory(tc+Offset(-r*.008*q,r*.007*q),w*scale,h*scale,rot,rnd,30);
        canvas.drawPath(inner,Paint()..style=PaintingStyle.stroke..strokeWidth=.55..color=Colors.white.withValues(alpha:selected==i ? .095 : .022));
      }
    }
    for(var i=0;i<72;i++){
      final p=Offset(c.dx+(rnd.nextDouble()*2-1)*r*.84,c.dy+(rnd.nextDouble()*2-1)*r*.76);
      canvas.drawCircle(p,r*(.001+rnd.nextDouble()*.005),Paint()..color=Colors.white.withValues(alpha:.018+rnd.nextDouble()*.035));
    }
    for(var i=0;i<5;i++){
      final y=c.dy-r*.50+i*r*.22;
      canvas.drawArc(Rect.fromCenter(center:Offset(c.dx,y),width:r*1.70,height:r*.18),math.pi*.10,math.pi*.80,false,Paint()..style=PaintingStyle.stroke..strokeWidth=r*.015..color=Colors.white.withValues(alpha:.016));
    }
    canvas.restore();
    final sh=c+Offset(r*.52,r*.09);
    canvas.drawCircle(sh,r*.89,Paint()..shader=RadialGradient(colors:[Colors.transparent,Colors.black.withValues(alpha:.76)],stops:const[.34,1]).createShader(Rect.fromCircle(center:sh,radius:r*.89)));
    canvas.drawArc(Rect.fromCircle(center:c,radius:r*1.008),math.pi*.60,math.pi*.88,false,Paint()..style=PaintingStyle.stroke..strokeWidth=r*.010..color=Colors.white.withValues(alpha:.23));
    canvas.drawArc(Rect.fromCircle(center:c+Offset(-r*.03,-r*.03),radius:r*.94),math.pi*1.02,math.pi*.42,false,Paint()..style=PaintingStyle.stroke..strokeWidth=r*.030..color=Colors.white.withValues(alpha:.035));
  }
  Path _territory(Offset c,double w,double h,double rot,math.Random rnd,int n){final p=Path();for(var j=0;j<n;j++){final a=j/n*math.pi*2;final wave=math.sin(j*.62)*.10+math.sin(j*.27+1.2)*.07;final wob=.86+wave+rnd.nextDouble()*.10;final x=math.cos(a)*w*.5*wob,y=math.sin(a)*h*.5*(.91+.09*math.sin(a*3));final xr=x*math.cos(rot)-y*math.sin(rot),yr=x*math.sin(rot)+y*math.cos(rot);final pt=Offset(c.dx+xr,c.dy+yr);if(j==0)p.moveTo(pt.dx,pt.dy);else p.lineTo(pt.dx,pt.dy);}p.close();return p;}
  @override bool shouldRepaint(covariant _GamePlanetPainter oldDelegate)=>oldDelegate.selected!=selected;
}
class _GameSpacePainter extends CustomPainter{@override void paint(Canvas canvas,Size size){final rect=Offset.zero&size;canvas.drawRect(rect,Paint()..shader=const RadialGradient(center:Alignment(0,-.08),radius:1.1,colors:[Color(0xFF15162A),Color(0xFF060710),Color(0xFF010205)]).createShader(rect));final r=math.Random(711);for(var i=0;i<250;i++)canvas.drawCircle(Offset(r.nextDouble()*size.width,r.nextDouble()*size.height),.15+r.nextDouble()*.75,Paint()..color=Colors.white.withValues(alpha:.035+r.nextDouble()*.11));}@override bool shouldRepaint(covariant _GameSpacePainter oldDelegate)=>false;}
