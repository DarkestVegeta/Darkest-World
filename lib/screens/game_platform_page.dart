import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_list_page.dart';

class GamePlatformPage extends StatefulWidget {
  final String territory;
  final List<GamePlatformGroup> groups;
  const GamePlatformPage({super.key, required this.territory, required this.groups});
  @override State<GamePlatformPage> createState() => _GamePlatformPageState();
}

class _GamePlatformPageState extends State<GamePlatformPage> with SingleTickerProviderStateMixin {
  int? selected;
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 30))..repeat();
  List<GamePlatform> get platforms => widget.groups.expand((g) => g.platforms).toList();
  @override void dispose() { clock.dispose(); super.dispose(); }
  void open(int i) { final p = platforms[i]; Navigator.of(context).push(MaterialPageRoute(builder: (_) => GameListPage(territory: widget.territory, platform: p.name, externalPlatformIds: p.externalPlatformIds, navigationPlatforms: platforms, navigationIndex: i))); }

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF010208),
    body: LayoutBuilder(builder: (context, box) {
      final compact = box.maxWidth < 900;
      final w = math.min(box.maxWidth * .94, 1400.0), h = math.min(box.maxHeight * .80, 790.0);
      final center = Offset(w / 2, h / 2);
      return AnimatedBuilder(animation: clock, builder: (_, __) {
        final pos = _positions(center, w, h, platforms.length, clock.value);
        return Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _SpacePainter(t: clock.value))),
          SafeArea(child: Padding(padding: EdgeInsets.fromLTRB(compact ? 14 : 28, 14, compact ? 14 : 28, 0), child: Row(children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, size: 16)),
            const SizedBox(width: 8), Text('${widget.territory.toUpperCase()} / PLATFORM WORLDS', style: const TextStyle(fontSize: 11, letterSpacing: 3)),
            const Spacer(), _Metric('WORLDS', '${platforms.length}'), const SizedBox(width: 20), _Metric('STATE', selected == null ? 'EXPLORE' : 'FOCUSED'),
          ]))),
          Center(child: SizedBox(width: w, height: h, child: Stack(children: [
            CustomPaint(size: Size(w, h), painter: _OrbitPainter(center: center, positions: pos, selected: selected, t: clock.value)),
            Positioned(left: center.dx - 126, top: center.dy - 126, child: _Core(territory: widget.territory, count: platforms.length, active: selected != null)),
            for (var i = 0; i < platforms.length; i++) Positioned(left: pos[i].dx - (selected == i ? 61 : 51), top: pos[i].dy - (selected == i ? 61 : 51), child: _WorldNode(platforms[i], i, selected == i, () => open(i), () => setState(() => selected = i))),
            for (var i = 0; i < widget.groups.length; i++) _Group(group: widget.groups[i], index: i, total: widget.groups.length, center: center, width: w, height: h),
            Positioned(left: 20, bottom: 20, child: _Legend()),
          ]))),
          if (selected != null) Positioned(left: compact ? 12 : 34, right: compact ? 12 : 34, bottom: compact ? 42 : 52, child: Center(child: _Panel(platforms[selected!], widget.territory, selected!, platforms.length, () => open(selected!), () => setState(() => selected = null)))),
          Positioned(left: compact ? 16 : 30, bottom: compact ? 16 : 24, child: Text(selected == null ? 'SELECT A PLATFORM WORLD  •  FOLLOW THE ORBITS' : 'WORLD SELECTED  •  ENTER TO OPEN  •  CLOSE TO RETURN', style: const TextStyle(fontSize: 8, letterSpacing: 2.3, color: Colors.white24))),
        ]);
      });
    }),
  );

  List<Offset> _positions(Offset c, double w, double h, int count, double t) => List.generate(count, (i) {
    final a = -math.pi / 2 + i * math.pi * 2 / math.max(1, count) + t * math.pi * .30;
    final ring = i % 4;
    final rx = w * (.20 + ring * .070), ry = h * (.17 + ring * .060);
    return Offset(c.dx + math.cos(a) * rx + math.sin(t * math.pi * 2 + i) * 7, c.dy + math.sin(a) * ry + math.cos(t * math.pi * 2 + i) * 5);
  });
}

class GamePlatformGroup { final String name; final String subtitle; final List<GamePlatform> platforms; const GamePlatformGroup(this.name, this.subtitle, this.platforms); }
class GamePlatform { final String name; final List<int> externalPlatformIds; const GamePlatform(this.name, this.externalPlatformIds); }

class _Metric extends StatelessWidget { final String a,b; const _Metric(this.a,this.b); @override Widget build(BuildContext c) => Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(a,style:const TextStyle(fontSize:6,letterSpacing:2,color:Colors.white24)),const SizedBox(height:3),Text(b,style:const TextStyle(fontSize:9,letterSpacing:1.4,color:Colors.white54))]); }

class _WorldNode extends StatelessWidget {
  final GamePlatform p; final int index; final bool active; final VoidCallback tap, hover;
  const _WorldNode(this.p,this.index,this.active,this.tap,this.hover);
  @override Widget build(BuildContext c) => MouseRegion(cursor:SystemMouseCursors.click,onEnter:(_)=>hover(),child:GestureDetector(onTap:tap,child:AnimatedContainer(duration:const Duration(milliseconds:260),width:active?122:102,height:active?122:102,decoration:BoxDecoration(shape:BoxShape.circle,gradient:RadialGradient(center:const Alignment(-.25,-.35),colors:active?const[Color(0xFFC4B9DF),Color(0xFF5B5078),Color(0xFF181526),Color(0xFF020309)]:const[Color(0xFF786D99),Color(0xFF342D49),Color(0xFF0B0A12),Color(0xFF020309)],stops:const[0,.28,.68,1]),border:Border.all(color:Colors.white.withValues(alpha:active?.40:.11),width:active?1.5:.7),boxShadow:active?const[BoxShadow(color:Color(0x667F70B0),blurRadius:34)]:const[]),child:Stack(alignment:Alignment.center,children:[CustomPaint(size:Size(active?122:102,active?122:102),painter:_Relief(seed:index+17,active:active)),Column(mainAxisSize:MainAxisSize.min,children:[Text('${index+1}'.padLeft(2,'0'),style:const TextStyle(fontSize:6,color:Colors.white24)),const SizedBox(height:5),Text(p.name,textAlign:TextAlign.center,maxLines:2,style:TextStyle(fontSize:active?10:8,letterSpacing:1.1,color:Colors.white.withValues(alpha:active?.98:.65))),const SizedBox(height:5),const Text('WORLD',style:TextStyle(fontSize:5,letterSpacing:1.8,color:Colors.white24))])]))));
}

class _Relief extends CustomPainter { final int seed; final bool active; const _Relief({required this.seed,required this.active}); @override void paint(Canvas c,Size s){final r=math.Random(seed),p=Paint()..style=PaintingStyle.stroke..strokeWidth=.65..color=Colors.white.withValues(alpha:active?.10:.045);for(var k=0;k<4;k++){final path=Path();for(var i=0;i<=22;i++){final a=i/22*math.pi*2;final rad=s.width*(.25+k*.075)+math.sin(a*3+seed)*4+math.cos(a*5+r.nextDouble())*2;final q=Offset(s.center.dx+math.cos(a)*rad,s.center.dy+math.sin(a)*rad*.72);if(i==0)path.moveTo(q.dx,q.dy);else path.lineTo(q.dx,q.dy);}c.drawPath(path,p);}}@override bool shouldRepaint(covariant _Relief old)=>old.active!=active;}

class _Core extends StatelessWidget { final String territory; final int count; final bool active; const _Core({required this.territory,required this.count,required this.active}); @override Widget build(BuildContext c)=>AnimatedContainer(duration:const Duration(milliseconds:450),width:252,height:252,decoration:BoxDecoration(shape:BoxShape.circle,gradient:RadialGradient(center:const Alignment(-.2,-.3),colors:active?const[Color(0xFF655D7C),Color(0xFF282137),Color(0xFF090812),Color(0xFF010207)]:const[Color(0xFF473F5C),Color(0xFF191522),Color(0xFF07070E),Color(0xFF010207)]),border:Border.all(color:Colors.white.withValues(alpha:active?.30:.16),width:active?1.4:.8),boxShadow:const[BoxShadow(color:Color(0x88000000),blurRadius:52),BoxShadow(color:Color(0x332C214A),blurRadius:90)]),child:Stack(alignment:Alignment.center,children:[CustomPaint(size:const Size(252,252),painter:_CoreLines(active)),Column(mainAxisSize:MainAxisSize.min,children:[Text(territory,style:const TextStyle(fontSize:13,letterSpacing:3.3)),const SizedBox(height:8),const Text('PLATFORM WORLD',style:TextStyle(fontSize:6,letterSpacing:2.5,color:Colors.white38)),const SizedBox(height:12),Text('$count CONNECTED WORLDS',style:const TextStyle(fontSize:7,letterSpacing:2,color:Colors.white24))])]))); }
class _CoreLines extends CustomPainter { final bool active; const _CoreLines(this.active); @override void paint(Canvas c,Size s){final p=Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=Colors.white.withValues(alpha:active?.07:.04);for(var i=0;i<8;i++)c.drawOval(Rect.fromCenter(center:s.center,width:s.width*(.35+i*.075),height:s.height*(.18+i*.09)),p);c.drawCircle(s.center,s.width*.30,Paint()..style=PaintingStyle.stroke..strokeWidth=1.4..color=const Color(0x229A8CC0));}@override bool shouldRepaint(covariant _CoreLines old)=>old.active!=active;}

class _Group extends StatelessWidget { final GamePlatformGroup group; final int index,total; final Offset center; final double width,height; const _Group({required this.group,required this.index,required this.total,required this.center,required this.width,required this.height}); @override Widget build(BuildContext c){final a=-math.pi/2+index*math.pi*2/math.max(1,total)+.3,p=Offset(center.dx+math.cos(a)*width*.41,center.dy+math.sin(a)*height*.38);return Positioned(left:p.dx-100,top:p.dy-16,width:200,child:IgnorePointer(child:Column(children:[Text(group.name,textAlign:TextAlign.center,style:const TextStyle(fontSize:7,letterSpacing:2.5,color:Colors.white30)),const SizedBox(height:4),Text(group.subtitle,textAlign:TextAlign.center,style:const TextStyle(fontSize:6,letterSpacing:1,color:Colors.white14))])));}}

class _Panel extends StatelessWidget { final GamePlatform p; final String territory; final int index,total; final VoidCallback open,close; const _Panel(this.p,this.territory,this.index,this.total,this.open,this.close); @override Widget build(BuildContext c)=>Container(constraints:const BoxConstraints(maxWidth:780),padding:const EdgeInsets.fromLTRB(18,14,12,14),decoration:BoxDecoration(color:const Color(0xF20A0A13),borderRadius:BorderRadius.circular(18),border:Border.all(color:const Color(0x557F70B0)),boxShadow:const[BoxShadow(color:Color(0xAA000000),blurRadius:38,offset:Offset(0,16))]),child:Row(children:[Container(width:3,height:46,decoration:BoxDecoration(color:const Color(0xAA9A8AC5),borderRadius:BorderRadius.circular(3))),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(p.name.toUpperCase(),style:const TextStyle(fontSize:14,letterSpacing:2.8)),const SizedBox(height:5),Text('$territory  •  PLATFORM WORLD  •  ${index+1}/$total',style:const TextStyle(fontSize:7,letterSpacing:1.8,color:Colors.white38))])),TextButton(onPressed:close,child:const Text('CLOSE')),const SizedBox(width:4),FilledButton(onPressed:open,child:const Text('ENTER'))])); }

class _Legend extends StatelessWidget { @override Widget build(BuildContext c)=>Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:8),decoration:BoxDecoration(color:const Color(0x6606070D),borderRadius:BorderRadius.circular(10),border:Border.all(color:Colors.white.withValues(alpha:.06))),child:const Row(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.circle,size:4,color:Color(0x889A8CC0)),SizedBox(width:7),Text('CONNECTED WORLDS  •  LIVE ORBIT',style:TextStyle(fontSize:6,letterSpacing:1.7,color:Colors.white24))])); }

class _SpacePainter extends CustomPainter { final double t; const _SpacePainter({required this.t}); @override void paint(Canvas c,Size s){final r=math.Random(412),rect=Offset.zero&s;c.drawRect(rect,Paint()..shader=const RadialGradient(center:Alignment(0,-.1),radius:1.1,colors:[Color(0xFF19152B),Color(0xFF07070F),Color(0xFF010106)]).createShader(rect));for(var i=0;i<360;i++){final x=(r.nextDouble()*s.width+t*s.width*.025)%s.width,y=(r.nextDouble()*s.height+math.sin(t*math.pi*2+i)*3)%s.height;c.drawCircle(Offset(x,y),.15+r.nextDouble()*.8,Paint()..color=Colors.white.withValues(alpha:.012+r.nextDouble()*.065));}for(var i=0;i<5;i++){c.drawCircle(Offset(s.width*(.12+i*.19)+math.sin(t*math.pi*2+i)*18,s.height*(.2+(i%3)*.25)),70+i*24.0,Paint()..color=const Color(0x089A8CC0));}c.drawCircle(Offset(s.width*.5,s.height*.52),math.min(s.width,s.height)*.47,Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0x129B8FC2));}@override bool shouldRepaint(covariant _SpacePainter old)=>old.t!=t;}

class _OrbitPainter extends CustomPainter { final Offset center; final List<Offset> positions; final int? selected; final double t; const _OrbitPainter({required this.center,required this.positions,required this.selected,required this.t}); @override void paint(Canvas c,Size s){final m=math.min(s.width,s.height);for(var i=0;i<4;i++){final r=Rect.fromCenter(center:center,width:m*(.42+i*.17),height:m*(.28+i*.115));c.drawOval(r,Paint()..style=PaintingStyle.stroke..strokeWidth=i==1?1.1:.65..color=Colors.white.withValues(alpha:i==1?.07:.028));}for(var i=0;i<positions.length;i++){final p=positions[i],mid=Offset((center.dx+p.dx)/2+math.sin(i+t*math.pi*2)*20,(center.dy+p.dy)/2-14),path=Path()..moveTo(center.dx,center.dy)..quadraticBezierTo(mid.dx,mid.dy,p.dx,p.dy);c.drawPath(path,Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0x287F72A0));final u=(t*1.8+i*.19)%1.0,q=_q(center,mid,p,u);c.drawCircle(q,1.4,Paint()..color=const Color(0x669A8CC0));if(selected==i){c.drawCircle(p,75,Paint()..style=PaintingStyle.stroke..strokeWidth=1.2..color=const Color(0x557F70B0));c.drawCircle(p,87,Paint()..style=PaintingStyle.stroke..strokeWidth=.7..color=const Color(0x227F70B0));}}}Offset _q(Offset a,Offset b,Offset c,double t){final u=1-t;return Offset(u*u*a.dx+2*u*t*b.dx+t*t*c.dx,u*u*a.dy+2*u*t*b.dy+t*t*c.dy);}@override bool shouldRepaint(covariant _OrbitPainter old)=>old.t!=t||old.selected!=selected||old.positions!=positions;}
