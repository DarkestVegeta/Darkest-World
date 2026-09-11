import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_platform_page.dart';

class GameWorldPlanetPage extends StatefulWidget {
  const GameWorldPlanetPage({super.key});
  @override State<GameWorldPlanetPage> createState() => _GameWorldPlanetPageState();
}

class _TerritoryData {
  final String name, description;
  final int accent;
  final List<GamePlatformGroup> groups;
  const _TerritoryData(this.name, this.description, this.accent, this.groups);
}

class _GameWorldPlanetPageState extends State<GameWorldPlanetPage> {
  int? hovered;
  int? selected;

  static const territories = <_TerritoryData>[
    _TerritoryData('NINTENDO', 'Forests, mountains, villages and old frontiers.', 0xFF8B73D6, [
      GamePlatformGroup('HOME CONSOLES', 'Generations of Nintendo hardware.', [GamePlatform('NES', [18]), GamePlatform('SNES', [19]), GamePlatform('N64', [4]), GamePlatform('GameCube', [21]), GamePlatform('Wii', [5]), GamePlatform('Wii U', [41]), GamePlatform('Switch', [130])]),
      GamePlatformGroup('HANDHELD', 'Portable generations.', [GamePlatform('Game Boy', [33]), GamePlatform('Game Boy Color', [22]), GamePlatform('Game Boy Advance', [24]), GamePlatform('DS', [20]), GamePlatform('3DS', [37])]),
    ]),
    _TerritoryData('SEGA', 'Dry plains, strange cities and arcade country.', 0xFF4D82C4, [
      GamePlatformGroup('CONSOLES', 'Sega hardware generations.', [GamePlatform('Master System', [64]), GamePlatform('Mega Drive', [29]), GamePlatform('Saturn', [32]), GamePlatform('Dreamcast', [23])]),
      GamePlatformGroup('PORTABLE', 'Sega handheld history.', [GamePlatform('Game Gear', [35])]),
    ]),
    _TerritoryData('PLAYSTATION', 'Fog, ruins, industry and darker unexplored ground.', 0xFF756A9E, [
      GamePlatformGroup('PLAYSTATION GENERATIONS', 'Main PlayStation generations.', [GamePlatform('PlayStation', [7]), GamePlatform('PlayStation 2', [8]), GamePlatform('PlayStation 3', [9]), GamePlatform('PlayStation 4', [48]), GamePlatform('PlayStation 5', [167])]),
    ]),
    _TerritoryData('XBOX', 'A vast frontier beyond the older territories.', 0xFF4F8A86, [
      GamePlatformGroup('XBOX GENERATIONS', 'Microsoft console generations.', [GamePlatform('Xbox', [11]), GamePlatform('Xbox 360', [12]), GamePlatform('Xbox One', [49]), GamePlatform('Xbox Series', [169])]),
    ]),
  ];

  void _open(int i) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GamePlatformPage(territory: territories[i].name, groups: territories[i].groups)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010307),
      body: LayoutBuilder(builder: (context, box) {
        final compact = box.maxWidth < 760;
        final diameter = math.min(box.maxWidth * (compact ? .86 : .62), box.maxHeight * (compact ? .66 : .76));
        return Stack(children: [
          const Positioned.fill(child: CustomPaint(painter: _GameSpacePainter())),
          SafeArea(child: Padding(padding: EdgeInsets.all(compact ? 14 : 28), child: Row(children: [
            _BackButton(onTap: () => Navigator.of(context).pop()),
            const SizedBox(width: 12),
            const Text('GAME-WORLD', style: TextStyle(fontSize: 17, letterSpacing: 4.5)),
            const Spacer(),
            Text('TERRITORIES', style: TextStyle(fontSize: 8, letterSpacing: 2.8, color: Colors.white.withValues(alpha: .28))),
          ]))),
          Center(child: SizedBox(width: diameter, height: diameter, child: Stack(clipBehavior: Clip.none, children: [
            Positioned.fill(child: CustomPaint(painter: _GamePlanetPainter(diameter))),
            for (var i = 0; i < territories.length; i++)
              _TerritoryButton(
                data: territories[i], index: i, hovered: hovered == i, muted: selected != null && selected != i, diameter: diameter,
                onEnter: () => setState(() => hovered = i), onExit: () => setState(() => hovered = null),
                onTap: () => setState(() => selected = selected == i ? null : i),
              ),
            Center(child: IgnorePointer(child: AnimatedOpacity(duration: const Duration(milliseconds: 240), opacity: selected == null ? 1 : .35, child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('GAME', style: TextStyle(fontSize: compact ? 15 : 20, letterSpacing: 7, color: Colors.white.withValues(alpha: .70))),
              const SizedBox(height: 5),
              Text('WORLD', style: TextStyle(fontSize: compact ? 8 : 10, letterSpacing: 5, color: Colors.white.withValues(alpha: .28))),
            ]))),
          ]))),
          if (selected != null)
            _TerritoryInfo(data: territories[selected!], compact: compact, onEnter: () => _open(selected!)),
          Positioned(left: compact ? 18 : 30, bottom: compact ? 18 : 26, child: Text(selected == null ? 'SELECT A TERRITORY' : 'SELECTED TERRITORY  •  ENTER TO OPEN', style: TextStyle(fontSize: 8, letterSpacing: 2.6, color: Colors.white.withValues(alpha: .22)))),
        ]);
      }),
    );
  }
}

class _TerritoryInfo extends StatelessWidget {
  final _TerritoryData data;
  final bool compact;
  final VoidCallback onEnter;
  const _TerritoryInfo({required this.data, required this.compact, required this.onEnter});
  @override Widget build(BuildContext context) {
    return Positioned(left: compact ? 16 : 30, right: compact ? 16 : 30, bottom: compact ? 52 : 62, child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 620), child: Material(color: Colors.transparent, child: Container(padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 26, vertical: compact ? 14 : 18), decoration: BoxDecoration(color: Colors.black.withValues(alpha: .68), borderRadius: BorderRadius.circular(18), border: Border.all(color: Color(data.accent).withValues(alpha: .22))), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data.name, style: TextStyle(fontSize: 13, letterSpacing: 3.4, color: Colors.white.withValues(alpha: .88))), const SizedBox(height: 6), Text(data.description, style: TextStyle(fontSize: 10, height: 1.35, color: Colors.white.withValues(alpha: .42)))])), const SizedBox(width: 18), TextButton(onPressed: onEnter, child: const Text('ENTER', style: TextStyle(fontSize: 9, letterSpacing: 2.4))) ])))));
  }
}

class _TerritoryButton extends StatelessWidget {
  final _TerritoryData data; final int index; final bool hovered, muted; final double diameter;
  final VoidCallback onEnter, onExit, onTap;
  const _TerritoryButton({required this.data, required this.index, required this.hovered, required this.muted, required this.diameter, required this.onEnter, required this.onExit, required this.onTap});
  @override Widget build(BuildContext context) {
    final points = [Offset(diameter*.30,diameter*.27), Offset(diameter*.70,diameter*.27), Offset(diameter*.28,diameter*.70), Offset(diameter*.72,diameter*.69)];
    final p = points[index]; final w = hovered ? 145.0 : 118.0;
    return Positioned(left:p.dx-w/2,top:p.dy-42,child: AnimatedOpacity(duration: const Duration(milliseconds: 220), opacity: muted ? .22 : 1, child: MouseRegion(cursor:SystemMouseCursors.click,onEnter:(_)=>onEnter(),onExit:(_)=>onExit(),child:GestureDetector(onTap:onTap,child:AnimatedContainer(duration:const Duration(milliseconds:220),width:w,height:84,decoration:BoxDecoration(color:Colors.black.withValues(alpha:hovered?.52:.30),borderRadius:BorderRadius.circular(50),border:Border.all(color:Color(data.accent).withValues(alpha:hovered?.48:.15)),boxShadow:hovered?[BoxShadow(color:Color(data.accent).withValues(alpha:.20),blurRadius:26)]:null),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text(data.name,style:TextStyle(fontSize:hovered?11:9,letterSpacing:2.8,color:Colors.white.withValues(alpha:hovered?.90:.58))),if (hovered) ...[const SizedBox(height:5),Text('SELECT TERRITORY',style:TextStyle(fontSize:6,letterSpacing:1.8,color:Colors.white.withValues(alpha:.34)))] ]))))));
  }
}

class _BackButton extends StatelessWidget { final VoidCallback onTap; const _BackButton({required this.onTap}); @override Widget build(BuildContext context)=>Material(color:Colors.transparent,child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(20),child:Container(width:36,height:36,decoration:BoxDecoration(color:Colors.black.withValues(alpha:.28),shape:BoxShape.circle,border:Border.all(color:Colors.white.withValues(alpha:.10))),child:const Icon(Icons.arrow_back_ios_new,size:14)))); }

class _GameSpacePainter extends CustomPainter {
  const _GameSpacePainter();
  @override void paint(Canvas c,Size s){final rect=Offset.zero&s;c.drawRect(rect,Paint()..shader=const RadialGradient(center:Alignment(0,0),radius:1.15,colors:[Color(0xFF15162A),Color(0xFF060710),Color(0xFF010205)]).createShader(rect));final q=math.Random(711);final p=Paint();for(var i=0;i<240;i++){p.color=Colors.white.withValues(alpha:.04+q.nextDouble()*.16);c.drawCircle(Offset(q.nextDouble()*s.width,q.nextDouble()*s.height),.2+q.nextDouble()*.7,p);}}
  @override bool shouldRepaint(covariant _GameSpacePainter old)=>false;
}

class _GamePlanetPainter extends CustomPainter {
  final double diameter; const _GamePlanetPainter(this.diameter);
  @override void paint(Canvas c,Size s){final o=s.center;final r=diameter*.49;final planet=Rect.fromCircle(center:o,radius:r);c.drawCircle(o,r*1.04,Paint()..shader=RadialGradient(colors:[const Color(0xFF6679A5).withValues(alpha:.12),Colors.transparent],stops:const[.18,1]).createShader(Rect.fromCircle(center:o,radius:r*1.08)));c.drawCircle(o,r,Paint()..shader=const RadialGradient(center:Alignment(-.34,-.38),radius:1.05,colors:[Color(0xFF26364B),Color(0xFF172538),Color(0xFF070D16)],stops:[0,.55,1]).createShader(planet));c.save();c.clipPath(Path()..addOval(planet));final q=math.Random(9121);final colors=[const Color(0xFF7167A3),const Color(0xFF47758A),const Color(0xFF6C6B83),const Color(0xFF4C786E)];for(var i=0;i<38;i++){final a=q.nextDouble()*math.pi*2,d=math.sqrt(q.nextDouble())*r*.72,at=o+Offset(math.cos(a)*d,math.sin(a)*d),rx=r*(.025+q.nextDouble()*.13),ry=r*(.018+q.nextDouble()*.075),rot=q.nextDouble()*math.pi;c.drawPath(_blob(at,rx,ry,rot,q),Paint()..color=colors[i%colors.length].withValues(alpha:.10+q.nextDouble()*.12));}for(var i=0;i<90;i++){final a=q.nextDouble()*math.pi*2,d=math.sqrt(q.nextDouble())*r*.88,at=o+Offset(math.cos(a)*d,math.sin(a)*d);final rr=r*(.002+q.nextDouble()*.015);c.drawCircle(at,rr,Paint()..color=Colors.white.withValues(alpha:.008+q.nextDouble()*.018));}c.drawOval(Rect.fromCenter(center:o+Offset(-r*.18,-r*.05),width:r*1.55,height:r*.25),Paint()..color=Colors.white.withValues(alpha:.018));c.drawCircle(o+Offset(r*.38,r*.08),r*.82,Paint()..shader=RadialGradient(colors:[Colors.transparent,const Color(0xFF000000).withValues(alpha:.30)]).createShader(Rect.fromCircle(center:o+Offset(r*.38,r*.08),radius:r*.82)));c.restore();c.drawArc(planet,math.pi*1.08,math.pi*.78,false,Paint()..style=PaintingStyle.stroke..strokeWidth=math.max(1,r*.008)..color=Colors.white.withValues(alpha:.08));}
  Path _blob(Offset o,double rx,double ry,double rot,math.Random q){final p=Path(),co=math.cos(rot),si=math.sin(rot);for(var i=0;i<=18;i++){final a=math.pi*2*i/18,w=.55+q.nextDouble()*.9,x=math.cos(a)*rx*w,y=math.sin(a)*ry*w,px=o.dx+x*co-y*si,py=o.dy+x*si+y*co;if(i==0)p.moveTo(px,py);else p.lineTo(px,py);}p.close();return p;}
  @override bool shouldRepaint(covariant _GamePlanetPainter old)=>false;
}
