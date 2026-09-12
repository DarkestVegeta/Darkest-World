import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_platform_page.dart';

class GameWorldPlanetPage extends StatefulWidget {
  const GameWorldPlanetPage({super.key});
  @override State<GameWorldPlanetPage> createState() => _GameWorldPlanetPageState();
}

class _TerritoryData {
  final String name, description;
  final List<GamePlatformGroup> groups;
  _TerritoryData(this.name, this.description, this.groups);
}

class _GameWorldPlanetPageState extends State<GameWorldPlanetPage> {
  int? selected;
  late final territories = <_TerritoryData>[
    _TerritoryData('NINTENDO','Nintendo generations.',[
      GamePlatformGroup('HOME CONSOLES','Home generations.',[GamePlatform('NES',[18]),GamePlatform('SNES',[19]),GamePlatform('N64',[4]),GamePlatform('GameCube',[21]),GamePlatform('Wii',[5]),GamePlatform('Wii U',[41]),GamePlatform('Switch',[130])]),
      GamePlatformGroup('HANDHELD','Portable generations.',[GamePlatform('Game Boy',[33]),GamePlatform('Game Boy Color',[22]),GamePlatform('Game Boy Advance',[24]),GamePlatform('DS',[20]),GamePlatform('3DS',[37])]),
    ]),
    _TerritoryData('SEGA','Sega generations.',[
      GamePlatformGroup('CONSOLES','Console generations.',[GamePlatform('Master System',[64]),GamePlatform('Mega Drive',[29]),GamePlatform('Saturn',[32]),GamePlatform('Dreamcast',[23])]),
      GamePlatformGroup('PORTABLE','Portable generation.',[GamePlatform('Game Gear',[35])]),
    ]),
    _TerritoryData('PLAYSTATION','PlayStation generations.',[GamePlatformGroup('GENERATIONS','Main generations.',[GamePlatform('PlayStation',[7]),GamePlatform('PlayStation 2',[8]),GamePlatform('PlayStation 3',[9]),GamePlatform('PlayStation 4',[48]),GamePlatform('PlayStation 5',[167])])]),
    _TerritoryData('XBOX','Xbox generations.',[GamePlatformGroup('GENERATIONS','Main generations.',[GamePlatform('Xbox',[11]),GamePlatform('Xbox 360',[12]),GamePlatform('Xbox One',[49]),GamePlatform('Xbox Series',[169])])]),
  ];

  void enter(int i) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GamePlatformPage(territory: territories[i].name, groups: territories[i].groups)));

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF010307),
    body: LayoutBuilder(builder: (context,box){
      final compact=box.maxWidth<760, d=math.min(box.maxWidth*.86,box.maxHeight*.86);
      return Stack(children:[
        Positioned.fill(child:CustomPaint(painter:_GameSpacePainter())),
        SafeArea(child:Padding(padding:EdgeInsets.all(compact?14:28),child:Row(children:[
          IconButton(onPressed:()=>Navigator.of(context).pop(),icon:const Icon(Icons.arrow_back_ios_new,size:16)),
          const SizedBox(width:10),const Text('GAME-WORLD',style:TextStyle(fontSize:16,letterSpacing:4)),const Spacer(),
          const Text('WORLD',style:TextStyle(fontSize:8,letterSpacing:3,color:Colors.white30)),
        ]))),
        Center(child:SizedBox(width:d,height:d,child:GestureDetector(
          onTapUp:(e){final h=_hit(e.localPosition,d);if(h!=null)setState(()=>selected=selected==h?null:h);},
          child:CustomPaint(painter:_GamePlanetPainter(selected:selected),child:Stack(children:[
            _label('NINTENDO',.25,.22,0,d),_label('SEGA',.73,.27,1,d),_label('PLAYSTATION',.27,.73,2,d),_label('XBOX',.73,.66,3,d),
            Center(child:Opacity(opacity:selected==null?1:.10,child:const Text('GAME-WORLD',style:TextStyle(fontSize:12,letterSpacing:5,color:Colors.white54)))),
          ])),
        ))),
        if(selected!=null)Positioned(left:compact?14:30,right:compact?14:30,bottom:compact?45:58,child:Center(child:Container(
          padding:const EdgeInsets.all(16),constraints:const BoxConstraints(maxWidth:620),
          decoration:BoxDecoration(color:const Color(0xE6090913),borderRadius:BorderRadius.circular(16),border:Border.all(color:const Color(0x337F70B0)),boxShadow:const[BoxShadow(color:Color(0x55000000),blurRadius:24,offset:Offset(0,10))]),
          child:Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(territories[selected!].name,style:const TextStyle(fontSize:13,letterSpacing:3)),const SizedBox(height:5),Text(territories[selected!].description,style:const TextStyle(fontSize:9,color:Colors.white38))])),TextButton(onPressed:()=>enter(selected!),child:const Text('ENTER'))]),
        ))),
        Positioned(left:compact?16:30,bottom:compact?18:26,child:Text(selected==null?'SELECT A REGION':'SELECTED REGION  •  ENTER TO OPEN',style:const TextStyle(fontSize:8,letterSpacing:2.4,color:Colors.white24))),
      ];
    }),
  );

  Widget _label(String text,double x,double y,int i,double d){final a=selected==null||selected==i?.78:.08;return Positioned(left:d*x-95,top:d*y-22,width:190,child:IgnorePointer(child:Center(child:Text(text,style:TextStyle(fontSize:selected==i?11:9,letterSpacing:2.4,color:Colors.white.withValues(alpha:a))))));}
  int? _hit(Offset p,double d){final o=Offset(d/2,d/2),r=d*.49;const centers=[Offset(-.22,-.25),Offset(.27,-.18),Offset(-.20,.27),Offset(.23,.23)];const scales=[.38,.32,.40,.33];for(var i=0;i<4;i++){final q=o+Offset(centers[i].dx*r,centers[i].dy*r);if((p-q).distance<r*scales[i])return i;}return null;}
}

class _GamePlanetPainter extends CustomPainter {
  final int? selected;
  const _GamePlanetPainter({required this.selected});
  static const centers=[Offset(-.22,-.25),Offset(.27,-.18),Offset(-.20,.27),Offset(.23,.23)];
  static const sizes=[Offset(.70,.45),Offset(.50,.38),Offset(.64,.47),Offset(.50,.40)];
  static const colors=[Color(0xFF9175A9),Color(0xFF66829A),Color(0xFF786C98),Color(0xFF5D847A)];

  @override void paint(Canvas canvas,Size size){
    final c=Offset(size.width*.5,size.height*.5),r=size.shortestSide*.47;
    final sphere=Rect.fromCircle(center:c,radius:r);
    final rnd=math.Random(442);

    // Deep-space field and broad atmospheric halo.
    canvas.drawCircle(c,r*1.55,Paint()..shader=const RadialGradient(colors:[Color(0x506A7FA5),Color(0x1C586D91),Colors.transparent],stops:[0,.48,1]).createShader(Rect.fromCircle(center:c,radius:r*1.55)));
    canvas.drawCircle(c,r*1.03,Paint()..shader=const RadialGradient(center:Alignment(-.55,-.62),radius:1.12,colors:[Color(0xFFE2D7C8),Color(0xFFAAA19A),Color(0xFF686974),Color(0xFF292C37),Color(0xFF070910)],stops:[0,.12,.34,.68,1]).createShader(sphere)));

    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));

    // Large-scale planetary structure: subtle plates/regions beneath the named territories.
    for(var i=0;i<10;i++){
      final a=-1.35+i*.31;
      final y=c.dy+math.sin(a)*r*.16;
      final width=r*(1.45-math.sin(a).abs()*.45);
      canvas.drawArc(Rect.fromCenter(center:Offset(c.dx,y),width:width,height:r*.48),math.pi*.08,math.pi*.84,false,Paint()..style=PaintingStyle.stroke..strokeWidth=r*.004..color=Colors.white.withValues(alpha:.010));
    }

    for(var i=0;i<4;i++){
      final tc=c+Offset(centers[i].dx*r,centers[i].dy*r);
      final depth=(tc.dy-c.dy)/r;
      final side=(tc.dx-c.dx)/r;
      final w=r*sizes[i].dx;
      final h=r*sizes[i].dy;
      final perspective=.70+.30*(1-depth.abs());
      final longitude=.78+.22*math.sqrt(math.max(.04,1-side*side));
      final latitude=.82+.18*math.sqrt(math.max(.04,1-depth*depth));
      final center=tc+Offset(-side*r*.045,depth*r*.025);
      final pw=w*perspective*longitude;
      final ph=h*perspective*latitude;
      final rotation=(i==0?.18:i==1?-.22:i==2?-.08:.24);
      final alpha=selected==null?.30:selected==i?.76:.012;

      // Elevated base and cast edge.
      final base=_territory(center+Offset(r*.014,r*.026),pw*1.025,ph*1.04,rotation,1900+i*41,.96);
      canvas.drawPath(base,Paint()..color=Colors.black.withValues(alpha:selected==i?.30:.16));
      final baseEdge=_territory(center+Offset(r*.006,r*.017),pw*1.008,ph*1.01,rotation,1950+i*41,.98);
      canvas.drawPath(baseEdge,Paint()..style=PaintingStyle.stroke..strokeWidth=r*.010..color=Colors.black.withValues(alpha:selected==i?.34:.10));

      // Main geographic mass.
      final path=_territory(center,pw,ph,rotation,700+i*19,1);
      canvas.drawPath(path,Paint()..color=colors[i].withValues(alpha:alpha));
      canvas.drawPath(path,Paint()..style=PaintingStyle.stroke..strokeWidth=r*(selected==i?.014:.006)..color=Colors.white.withValues(alpha:selected==i?.38:.065));

      // Uneven inner terrain levels, compressed toward the globe edges.
      for(var q=1;q<=8;q++){
        final scale=1-q*.085;
        final drift=Offset(-side*r*.006*q,depth*r*.004*q);
        final inner=_territory(center+drift,pw*scale,ph*scale,rotation,720+i*19+q*17,1-q*.015);
        canvas.drawPath(inner,Paint()..style=PaintingStyle.stroke..strokeWidth=r*.0032..color=Colors.white.withValues(alpha:selected==i?.085:.014));
      }

      // Curved terrain bands following the globe rather than horizontal map lines.
      for(var band=0;band<7;band++){
        final t=(band-3)*.145;
        final bandY=center.dy+t*ph;
        final edgeCurve=(1-t.abs()*1.05).clamp(.05,1.0)*.20;
        final left=center.dx-pw*.44;
        final right=center.dx+pw*.44;
        final p=Path()..moveTo(left,bandY);
        for(var step=1;step<=18;step++){
          final u=step/18;
          final x=left+(right-left)*u;
          final globeBend=math.sin(u*math.pi)*ph*edgeCurve;
          final terrainWave=math.sin(u*math.pi*2.0+band*1.7+i)*ph*.020;
          p.lineTo(x,bandY-globeBend+terrainWave);
        }
        canvas.drawPath(p,Paint()..style=PaintingStyle.stroke..strokeWidth=r*.0035..color=Colors.white.withValues(alpha:selected==i?.065:.018));
      }

      // Dark lower elevation rim + bright upper terrain edge.
      final lower=_territory(center+Offset(r*.006,r*.018),pw*.99,ph*.99,rotation,1600+i*23,.99);
      canvas.drawPath(lower,Paint()..style=PaintingStyle.stroke..strokeWidth=r*.007..color=Colors.black.withValues(alpha:selected==i?.24:.065));
      final upper=_territory(center+Offset(-r*.004,-r*.006),pw*.975,ph*.975,rotation,1700+i*29,.99);
      canvas.drawPath(upper,Paint()..style=PaintingStyle.stroke..strokeWidth=r*.004..color=Colors.white.withValues(alpha:selected==i?.10:.026));

      // A few larger geological cuts keep the shapes organic and non-quadrant-like.
      for(var ridge=0;ridge<3;ridge++){
        final y=center.dy+(ridge-1)*ph*.19;
        final p=Path()..moveTo(center.dx-pw*.32,y);
        for(var s=1;s<=9;s++){
          final u=s/9;
          p.lineTo(center.dx-pw*.32+pw*.64*u,y+math.sin(u*math.pi*2.4+ridge+i)*ph*.075);
        }
        canvas.drawPath(p,Paint()..style=PaintingStyle.stroke..strokeWidth=r*.004..color=Colors.black.withValues(alpha:selected==i?.10:.025));
      }
    }

    // Planetary longitude/latitude traces, kept very faint so the world remains calm.
    for(var i=0;i<9;i++){
      final t=-.80+i*.20;
      final half=r*math.sqrt(math.max(0,1-t*t));
      canvas.drawOval(Rect.fromCenter(center:Offset(c.dx+t*r*.18,c.dy),width:half*1.48,height:r*.028),Paint()..style=PaintingStyle.stroke..strokeWidth=r*.0028..color=Colors.white.withValues(alpha:.011));
    }
    for(var i=0;i<7;i++){
      final t=-.70+i*.233;
      final half=r*math.sqrt(math.max(0,1-t*t));
      canvas.drawArc(Rect.fromCenter(center:Offset(c.dx,c.dy+t*r*.10),width:r*1.90,height:half*1.22),math.pi*.08,math.pi*.84,false,Paint()..style=PaintingStyle.stroke..strokeWidth=r*.0035..color=Colors.white.withValues(alpha:.012));
    }

    // Sparse surface texture.
    for(var i=0;i<125;i++){
      final a=rnd.nextDouble()*math.pi*2;
      final rr=r*(.12+rnd.nextDouble()*.79);
      final x=c.dx+math.cos(a)*rr;
      final y=c.dy+math.sin(a)*rr*.78;
      canvas.drawCircle(Offset(x,y),r*(.0007+rnd.nextDouble()*.0035),Paint()..color=Colors.white.withValues(alpha:.005+rnd.nextDouble()*.018));
    }
    canvas.restore();

    // Stronger spherical depth: daylight rim, atmospheric rim and night terminator.
    final nightCenter=c+Offset(r*.58,r*.10);
    canvas.drawCircle(nightCenter,r*.96,Paint()..shader=const RadialGradient(colors:[Colors.transparent,Color(0xDD000208)],stops:[.25,1]).createShader(Rect.fromCircle(center:nightCenter,radius:r*.96)));
    canvas.drawArc(Rect.fromCircle(center:c,radius:r*1.008),math.pi*.59,math.pi*.92,false,Paint()..style=PaintingStyle.stroke..strokeWidth=r*.014..color=Colors.white.withValues(alpha:.30));
    canvas.drawArc(Rect.fromCircle(center:c+Offset(-r*.035,-r*.035),radius:r*.975),math.pi*1.03,math.pi*.52,false,Paint()..style=PaintingStyle.stroke..strokeWidth=r*.030..color=Colors.white.withValues(alpha:.040));
    canvas.drawArc(Rect.fromCircle(center:c,radius:r*1.020),math.pi*1.04,math.pi*.86,false,Paint()..style=PaintingStyle.stroke..strokeWidth=r*.019..color=const Color(0x668CA4C7));
  }

  Path _territory(Offset center,double width,double height,double rotation,int seed,double shape){
    final rnd=math.Random(seed);const n=30;final pts=<Offset>[];
    for(var i=0;i<n;i++){
      final a=i/n*math.pi*2;
      final wave=math.sin(a*2.1+seed)*.14+math.sin(a*3.6+seed*.11)*.09+math.sin(a*6.7+seed*.07)*.045;
      final notch=math.sin(a*5.0+seed*.31)*.025;
      final rad=(.80+wave+notch+rnd.nextDouble()*.075)*shape;
      final x=math.cos(a)*width*.5*rad;
      final y=math.sin(a)*height*.5*rad*(.88+.12*math.sin(a*2.6+seed));
      final xr=x*math.cos(rotation)-y*math.sin(rotation);
      final yr=x*math.sin(rotation)+y*math.cos(rotation);
      pts.add(Offset(center.dx+xr,center.dy+yr));
    }
    final p=Path()..moveTo(pts[0].dx,pts[0].dy);
    for(var i=0;i<n;i++){
      final a=pts[i],b=pts[(i+1)%n],m=Offset((a.dx+b.dx)/2,(a.dy+b.dy)/2);
      p.quadraticBezierTo(a.dx,a.dy,m.dx,m.dy);
    }
    p.close();
    return p;
  }

  @override bool shouldRepaint(covariant _GamePlanetPainter oldDelegate)=>oldDelegate.selected!=selected;
}

class _GameSpacePainter extends CustomPainter {
  @override void paint(Canvas canvas,Size size){
    final rect=Offset.zero&size;
    canvas.drawRect(rect,Paint()..shader=const RadialGradient(center:Alignment(0,-.08),radius:1.12,colors:[Color(0xFF15162A),Color(0xFF060710),Color(0xFF010205)]).createShader(rect));
    final r=math.Random(711);
    for(var i=0;i<280;i++)canvas.drawCircle(Offset(r.nextDouble()*size.width,r.nextDouble()*size.height),.15+r.nextDouble()*.75,Paint()..color=Colors.white.withValues(alpha:.028+r.nextDouble()*.11));
  }
  @override bool shouldRepaint(covariant _GameSpacePainter oldDelegate)=>false;
}
