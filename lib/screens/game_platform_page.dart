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
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 120))..repeat();
  int? selected;
  List<GamePlatform> get platforms => widget.groups.expand((g) => g.platforms).toList(growable: false);
  @override void dispose(){clock.dispose();super.dispose();}
  void enter(int i){
    final p=platforms[i];
    Navigator.of(context).push(MaterialPageRoute(builder:(_)=>GameListPage(
      territory:widget.territory, platform:p.name, externalPlatformIds:p.externalPlatformIds,
      navigationPlatforms:platforms, navigationIndex:i,
    )));
  }
  @override Widget build(BuildContext context){
    final compact=MediaQuery.sizeOf(context).width<820;
    return Scaffold(backgroundColor:const Color(0xFF02040A),body:AnimatedBuilder(animation:clock,builder:(_,__)=>Stack(fit:StackFit.expand,children:[
      CustomPaint(painter:_RealmSpace(clock.value)),
      SafeArea(child:Padding(padding:EdgeInsets.fromLTRB(compact?14:30,compact?12:24,compact?14:30,0),child:Row(children:[
        IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.arrow_back_ios_new,size:14)),const SizedBox(width:8),
        Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(widget.territory.toUpperCase(),style:const TextStyle(fontSize:16,letterSpacing:3.8)),
          const SizedBox(height:4),const Text('PLATFORM REALMS · DEEP ARCHIVE',style:TextStyle(fontSize:6.5,letterSpacing:2.1,color:Color(0x668D95A5))),
        ]),
      ]))),
      Center(child:LayoutBuilder(builder:(_,b){
        final w=math.min(b.maxWidth*(compact?.98:.90),1550.0),h=math.min(b.maxHeight*(compact?.72:.80),850.0);
        return SizedBox(width:w,height:h,child:Stack(children:[
          CustomPaint(size:Size(w,h),painter:_RealmAtlas(clock.value)),
          for(var i=0;i<platforms.length;i++) _RealmHit(platform:platforms[i],index:i,total:platforms.length,selected:selected==i,size:Size(w,h),phase:clock.value,onTap:()=>setState(()=>selected=selected==i?null:i),onOpen:()=>enter(i)),
        ]));
      })),
      Positioned(left:compact?14:30,right:compact?14:30,bottom:compact?14:28,child:selected==null?const _RealmHint():_RealmPanel(
        platform:platforms[selected!],index:selected!,total:platforms.length,onClose:()=>setState(()=>selected=null),onOpen:()=>enter(selected!))),
    ])));
  }
}

class GamePlatformGroup { final String name; final String subtitle; final List<GamePlatform> platforms; const GamePlatformGroup(this.name,this.subtitle,this.platforms); }
class GamePlatform { final String name; final List<int> externalPlatformIds; const GamePlatform(this.name,this.externalPlatformIds); }

class _RealmHit extends StatelessWidget{
  final GamePlatform platform; final int index,total; final bool selected; final Size size; final double phase; final VoidCallback onTap,onOpen;
  const _RealmHit({required this.platform,required this.index,required this.total,required this.selected,required this.size,required this.phase,required this.onTap,required this.onOpen});
  @override Widget build(BuildContext context){
    final p=_pos(index,total,size,phase),d=math.max(92,size.width*.12);
    return Positioned(left:p.dx-d*.55,top:p.dy-d*.38,width:d*1.1,height:d*.76,child:MouseRegion(cursor:SystemMouseCursors.click,child:GestureDetector(onTap:onTap,onDoubleTap:onOpen,child:CustomPaint(painter:_MiniRealm(seed:index,active:selected,label:platform.name)))));
  }
}
Offset _pos(int i,int total,Size s,double phase){
  final cols=math.min(5,math.max(3,total)),row=i~/cols,col=i%cols,rows=(total+cols-1)~/cols;
  return Offset(s.width*(.13+col*(.74/math.max(1,cols-1))),s.height*(.28+row*(.46/math.max(1,rows-1)))+math.sin(phase*math.pi*2+i)*7);
}

class _MiniRealm extends CustomPainter{
  final int seed; final bool active; final String label;
  const _MiniRealm({required this.seed,required this.active,required this.label});
  @override void paint(Canvas c,Size s){
    final center=Offset(s.width*.5,s.height*.42);
    final rnd=math.Random(900+seed*71);
    final w=s.width*.94,h=s.height*.62;
    final pts=<Offset>[];
    for(var i=0;i<24;i++){
      final ang=i*math.pi*2/24;
      final q=.74+rnd.nextDouble()*.26+math.sin(ang*3+seed)*.045;
      pts.add(center+Offset(math.cos(ang)*w*.5*q,math.sin(ang)*h*.5*q));
    }
    final top=Path()..moveTo(pts[0].dx,pts[0].dy);
    for(final p in pts.skip(1)) top.lineTo(p.dx,p.dy);
    top.close();
    final underside=top.shift(Offset(0,h*.27));
    c.drawPath(underside,Paint()..color=const Color(0xF0071015));
    c.drawPath(Path.combine(PathOperation.difference,underside,top),Paint()..color=const Color(0xAA18242A));
    c.drawPath(top,Paint()..shader=LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:_palette(seed)).createShader(top.getBounds()));
    for(var k=0;k<5;k++){
      final p=Path(); final scale=1-k*.105;
      for(var i=0;i<pts.length;i++){final q=center+(pts[i]-center)*scale;if(i==0)p.moveTo(q.dx,q.dy);else p.lineTo(q.dx,q.dy);}
      p.close();
      c.drawPath(p,Paint()..style=PaintingStyle.stroke..strokeWidth=active?1.25:.65..color=Colors.white.withValues(alpha:active?.11:.045));
    }
    for(var i=0;i<6;i++){
      final x=center.dx+(-.30+i*.12)*w;
      final y=center.dy+math.sin(seed+i*1.7)*.06*h;
      final m=Path()..moveTo(x-w*.10,y+h*.10)..lineTo(x-w*.03,y-h*(.12+.025*(i%3)))..lineTo(x+w*.035,y-h*(.025+.04*(i%2)))..lineTo(x+w*.12,y+h*.10)..close();
      c.drawPath(m,Paint()..color=Colors.white.withValues(alpha:.045));
    }
    final ridge=Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=Colors.white.withValues(alpha:.065);
    for(var i=0;i<4;i++){
      final p=Path()..moveTo(center.dx-w*.30,center.dy+(i-2)*h*.07);
      p.cubicTo(center.dx-w*.12,center.dy-h*.12+i*2,center.dx+w*.08,center.dy+h*.10-i*3,center.dx+w*.31,center.dy-h*.01+i*3);
      c.drawPath(p,ridge);
    }
    final accent=_accent(seed);
    c.drawCircle(center,w*.13,Paint()..shader=RadialGradient(colors:[accent.withValues(alpha:active?.16:.055),Colors.transparent]).createShader(Rect.fromCircle(center:center,radius:w*.36)));
    final tp=TextPainter(text:TextSpan(text:label.toUpperCase(),style:TextStyle(color:Colors.white.withValues(alpha:active?.98:.64),fontSize:math.max(7,w*.048),letterSpacing:1.35)),textDirection:TextDirection.ltr)..layout(maxWidth:s.width);
    tp.paint(c,Offset(center.dx-tp.width/2,center.dy+h*.66));
    if(active)c.drawPath(top,Paint()..style=PaintingStyle.stroke..strokeWidth=1.8..color=Colors.white.withValues(alpha:.18));
  }
  List<Color> _palette(int i)=>const[
    [Color(0xFF526A58),Color(0xFF314A3E),Color(0xFF17292A)],
    [Color(0xFF806B55),Color(0xFF55483E),Color(0xFF252B2A)],
    [Color(0xFF657285),Color(0xFF3E4A5D),Color(0xFF202938)],
    [Color(0xFF4B7169),Color(0xFF294B49),Color(0xFF162B31)],
    [Color(0xFF615C73),Color(0xFF3B374B),Color(0xFF202031)],
    [Color(0xFF6E7974),Color(0xFF3F4B48),Color(0xFF22292B)],
  ][i%6];
  Color _accent(int i)=>const[Color(0xFFB9D69D),Color(0xFFD4A66B),Color(0xFFAEBCE0),Color(0xFF6BC2B1),Color(0xFFA58CDA),Color(0xFF9EB5AC)][i%6];
  @override bool shouldRepaint(covariant _MiniRealm o)=>o.seed!=seed||o.active!=active;
}

class _RealmAtlas extends CustomPainter {
  final double phase;
  const _RealmAtlas(this.phase);

  @override
  void paint(Canvas c, Size s) {
    final r = Offset.zero & s;
    _background(c, s);
    _distantLayers(c, s);
    _groundMist(c, s);
  }

  void _background(Canvas c, Size s) {
    final r = Offset.zero & s;
    c.drawRect(r, Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF030714), Color(0xFF07151E), Color(0xFF02060B)],
      ).createShader(r));
    final glow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -.18), radius: 1.0,
        colors: const [Color(0x244E6B8A), Color(0x101B3150), Colors.transparent],
      ).createShader(r);
    c.drawRect(r, glow);
    final rnd = math.Random(5512);
    for (var i = 0; i < 170; i++) {
      final p = Offset(rnd.nextDouble()*s.width, rnd.nextDouble()*s.height*.68);
      final a = .018 + rnd.nextDouble()*.045;
      c.drawCircle(p, .35+rnd.nextDouble()*.8, Paint()..color=Colors.white.withValues(alpha:a));
    }
  }

  void _distantLayers(Canvas c, Size s) {
    final far = Paint()..color=const Color(0x251B3035);
    final mid = Paint()..color=const Color(0x3515252B);
    _ridge(c,s,.22,.055,far,1.6);
    _ridge(c,s,.34,.085,mid,2.0);
    _ridge(c,s,.47,.105,Paint()..color=const Color(0x45101C20),2.4);
  }

  void _ridge(Canvas c, Size s, double base, double amp, Paint p, double seed) {
    final path=Path()..moveTo(0,s.height*base);
    for(var i=0;i<=18;i++){
      final x=s.width*i/18;
      final y=s.height*(base-amp*(.25+.75*((math.sin(i*1.17+seed)+1)/2)));
      path.lineTo(x,y);
    }
    path.lineTo(s.width,s.height*.63); path.lineTo(0,s.height*.63); path.close();
    c.drawPath(path,p);
  }

  void _groundMist(Canvas c, Size s) {
    for(var i=0;i<8;i++){
      final y=s.height*(.52+i*.045);
      c.drawOval(
        Rect.fromCenter(center:Offset(s.width*(.15+i*.11),y),width:s.width*.32,height:s.height*.07),
        Paint()..color=const Color(0x0EBCD2D3),
      );
    }
  }

  @override bool shouldRepaint(covariant _RealmAtlas oldDelegate)=>oldDelegate.phase!=phase;
}

class _RealmPanel extends StatelessWidget{
  final GamePlatform platform;final int index,total;final VoidCallback onClose,onOpen;
  const _RealmPanel({required this.platform,required this.index,required this.total,required this.onClose,required this.onOpen});
  @override Widget build(BuildContext c)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:const Color(0xEF050912),border:Border.all(color:const Color(0x357B94A3)),borderRadius:BorderRadius.circular(16),boxShadow:const[BoxShadow(color:Colors.black87,blurRadius:32)]),child:Row(children:[
    Container(width:46,height:46,decoration:BoxDecoration(shape:BoxShape.circle,gradient:RadialGradient(colors:[_accent(index),const Color(0xFF3B4550),const Color(0xFF080A0E)]))),
    const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('REALM '+(index+1).toString()+'/'+total.toString(),style:const TextStyle(fontSize:6.5,letterSpacing:2,color:Color(0x6688939E))),const SizedBox(height:4),
      Text(platform.name,style:const TextStyle(fontSize:17,letterSpacing:2.3)),const SizedBox(height:3),
      Text(platform.externalPlatformIds.length.toString().padLeft(2,'0')+' SOURCES · ARCHIVE READY',style:const TextStyle(fontSize:6,color:Color(0x557F8A96),letterSpacing:1.4))
    ])),IconButton(onPressed:onClose,icon:const Icon(Icons.close,size:16,color:Colors.white54)),FilledButton(onPressed:onOpen,child:const Text('ENTER ARCHIVE'))
  ]));
}
Color _accent(int i)=>const[Color(0xFFB9D69D),Color(0xFFD4A66B),Color(0xFFAEBCE0),Color(0xFF6BC2B1),Color(0xFFA58CDA),Color(0xFF9EB5AC)][i%6];
class _RealmHint extends StatelessWidget{const _RealmHint();@override Widget build(BuildContext c)=>Container(padding:const EdgeInsets.symmetric(horizontal:18,vertical:10),decoration:BoxDecoration(color:const Color(0xB8070B12),border:Border.all(color:const Color(0x263B4A56)),borderRadius:BorderRadius.circular(14)),child:const Text('SELECT A PLATFORM REALM · DOUBLE-CLICK TO ENTER',style:TextStyle(fontSize:6.5,letterSpacing:1.7,color:Color(0x687D8994))));}
