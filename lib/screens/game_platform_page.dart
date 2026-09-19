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
    final center=Offset(s.width*.5,s.height*.42),w=s.width*.84,h=s.height*.48,rnd=math.Random(900+seed*71);
    final pts=<Offset>[];for(var i=0;i<14;i++){final a=i*math.pi*2/14,q=.82+rnd.nextDouble()*.18;pts.add(center+Offset(math.cos(a)*w*.5*q,math.sin(a)*h*.5*q));}
    final top=Path()..moveTo(pts[0].dx,pts[0].dy);for(final p in pts.skip(1)){top.lineTo(p.dx,p.dy);}top.close();
    c.drawPath(top.shift(Offset(0,h*.28)),Paint()..color=const Color(0xD0081118));
    c.drawPath(top,Paint()..shader=LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:_palette(seed)).createShader(top.getBounds()));
    for(var k=1;k<4;k++){final path=Path();for(var i=0;i<pts.length;i++){final p=center+(pts[i]-center)*(1-k*.12);if(i==0)path.moveTo(p.dx,p.dy);else path.lineTo(p.dx,p.dy);}path.close();c.drawPath(path,Paint()..style=PaintingStyle.stroke..strokeWidth=active?1.2:.6..color=Colors.white.withValues(alpha:active?.13:.055));}
    c.drawCircle(center,w*.13,Paint()..shader=RadialGradient(colors:[_accent(seed).withValues(alpha:active?.28:.10),Colors.transparent]).createShader(Rect.fromCircle(center:center,radius:w*.38)));
    c.drawCircle(center,w*.035,Paint()..color=_accent(seed).withValues(alpha:.75));
    final tp=TextPainter(text:TextSpan(text:label.toUpperCase(),style:TextStyle(color:Colors.white.withValues(alpha:active?.98:.62),fontSize:math.max(7,w*.065),letterSpacing:1.3)),textDirection:TextDirection.ltr)..layout(maxWidth:s.width);
    tp.paint(c,Offset(center.dx-tp.width/2,center.dy+h*.63));
  }
  List<Color> _palette(int i)=>const[[Color(0xFF58735E),Color(0xFF263D34),Color(0xFF17282A)],[Color(0xFF80674F),Color(0xFF4D4038),Color(0xFF252A29)],[Color(0xFF69758D),Color(0xFF39475E),Color(0xFF202938)],[Color(0xFF4C756C),Color(0xFF284E4A),Color(0xFF162C32)],[Color(0xFF665E78),Color(0xFF3C354E),Color(0xFF202031)],[Color(0xFF78827C),Color(0xFF404B48),Color(0xFF22292B)]][i%6];
  Color _accent(int i)=>const[Color(0xFFB9D69D),Color(0xFFD4A66B),Color(0xFFAEBCE0),Color(0xFF6BC2B1),Color(0xFFA58CDA),Color(0xFF9EB5AC)][i%6];
  @override bool shouldRepaint(covariant _MiniRealm o)=>o.seed!=seed||o.active!=active;
}

class _RealmAtlas extends CustomPainter{
  final double phase;const _RealmAtlas(this.phase);
  @override void paint(Canvas c,Size s){
    final r=Offset.zero&s;c.drawRect(r,Paint()..shader=const RadialGradient(center:Alignment(0,-.25),radius:1.05,colors:[Color(0xFF172B32),Color(0xFF07131D),Color(0xFF02040A)]).createShader(r));
    final rnd=math.Random(5512);for(var i=0;i<240;i++){final d=.2+rnd.nextDouble()*.8;c.drawCircle(Offset(rnd.nextDouble()*s.width,rnd.nextDouble()*s.height),.25+d*.8,Paint()..color=Colors.white.withValues(alpha:.018+d*.045));}
    final horizon=Path()..moveTo(0,s.height*.64);for(var i=0;i<=12;i++){horizon.lineTo(s.width*i/12,s.height*(.60+.035*math.sin(i*1.4)));}horizon.lineTo(s.width,s.height);horizon.lineTo(0,s.height);horizon.close();c.drawPath(horizon,Paint()..color=const Color(0x25101C21));
    final center=Offset(s.width*.5,s.height*.48);c.drawCircle(center,s.width*.12,Paint()..shader=RadialGradient(colors:const[Color(0x24A78BEA),Color(0x00000000)]).createShader(Rect.fromCircle(center:center,radius:s.width*.2)));
    for(var i=0;i<5;i++){final rr=s.width*(.12+i*.10);c.drawOval(Rect.fromCenter(center:center,width:rr*2,height:rr*.48),Paint()..style=PaintingStyle.stroke..strokeWidth:.5..color=const Color(0x183E7480));}
  }
  @override bool shouldRepaint(covariant _RealmAtlas o)=>o.phase!=phase;
}
class _RealmSpace extends CustomPainter{
  final double phase;const _RealmSpace(this.phase);
  @override void paint(Canvas c,Size s){c.drawRect(Offset.zero&s,Paint()..shader=const RadialGradient(center:Alignment(0,-.1),radius:1.1,colors:[Color(0xFF11182A),Color(0xFF040812),Color(0xFF010207)]).createShader(Offset.zero&s));}
  @override bool shouldRepaint(covariant _RealmSpace o)=>o.phase!=phase;
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
