import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Cinematic presentation layer for transparent 3D game artboxes.
/// The source image remains untouched; Flutter supplies the environment,
/// contact shadow, reflection and restrained parallax around it.
class DarkestWorldArtbox extends StatefulWidget {
  final String? imageUrl;
  final String title;
  final double phase;
  final bool compact;
  const DarkestWorldArtbox({super.key, required this.imageUrl, required this.title, required this.phase, this.compact = false});
  @override State<DarkestWorldArtbox> createState() => _DarkestWorldArtboxState();
}

class _DarkestWorldArtboxState extends State<DarkestWorldArtbox> {
  Offset _pointer = Offset.zero;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final maxW = box.maxWidth;
      final maxH = box.maxHeight;
      final tiltX = ((_pointer.dy / math.max(1, maxH)) - .5) * -.055;
      final tiltY = ((_pointer.dx / math.max(1, maxW)) - .5) * .075;
      final drift = math.sin(widget.phase * math.pi * 2) * .008;
      return MouseRegion(
        onHover: (event) => setState(() => _pointer = event.localPosition),
        onExit: (_) => setState(() => _pointer = Offset.zero),
        child: Stack(alignment: Alignment.center, children: [
          Positioned(left: maxW * .18, right: maxW * .18, bottom: maxH * .13, height: maxH * .10,
            child: DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), color: Colors.black.withValues(alpha: .52), boxShadow: const [BoxShadow(blurRadius: 28, spreadRadius: 4, color: Colors.black)]))),
          Positioned(left: maxW * .20, right: maxW * .20, bottom: maxH * .08, height: maxH * .12,
            child: IgnorePointer(child: Opacity(opacity: .14, child: Transform.scale(scaleY: -.30, child: _image())))),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..setEntry(3, 2, .0012)..rotateX(tiltX)..rotateY(tiltY + drift),
            child: Stack(alignment: Alignment.center, children: [
              Container(width: maxW * (widget.compact ? .64 : .58), height: maxH * .76,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), boxShadow: [BoxShadow(color: const Color(0xFF4D3D73).withValues(alpha: .18), blurRadius: 32, spreadRadius: 2)])),
              SizedBox(width: maxW * (widget.compact ? .72 : .66), height: maxH * .80, child: _image()),
            ]),
          ),
          Positioned(top: 10, left: 10, child: _badge('ARTBOX / 3D')),
          Positioned(top: 10, right: 10, child: _badge('TRANSPARENT')),
          if (widget.imageUrl == null) Center(child: Text(widget.title.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, letterSpacing: 2, color: Color(0x668F82A9)))),
        ]),
      );
    });
  }

  Widget _image() {
    if (widget.imageUrl == null) return const SizedBox.shrink();
    return Image.network(widget.imageUrl!, fit: BoxFit.contain, filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => Center(child: Text(widget.title.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, letterSpacing: 1.5, color: Color(0x557F8AA2)))));
  }

  Widget _badge(String text) => DecoratedBox(decoration: const BoxDecoration(color: Color(0xCC05060D)), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), child: Text(text, style: const TextStyle(fontSize: 5.5, letterSpacing: 1.8, color: Color(0x667F8AA2)))));
}
