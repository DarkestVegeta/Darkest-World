import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Rare living-world Easter egg.
///
/// A tiny warning light appears first for exactly 1.4 seconds. If it is
/// clicked during that warning window, [onCaught] is fired. Otherwise the
/// meteor then crosses the world at very high speed.
class FallingStarEasterEgg extends StatefulWidget {
  final VoidCallback? onCaught;
  final VoidCallback? onMissed;

  const FallingStarEasterEgg({super.key, this.onCaught, this.onMissed});

  @override
  State<FallingStarEasterEgg> createState() => _FallingStarEasterEggState();
}

enum _StarPhase { idle, warning, meteor }

class _FallingStarEasterEggState extends State<FallingStarEasterEgg>
    with SingleTickerProviderStateMixin {
  static const warningDuration = Duration(milliseconds: 1400);
  static const meteorDuration = Duration(milliseconds: 260);
  static const minDelay = Duration(seconds: 8);
  static const maxDelay = Duration(seconds: 22);

  final _random = math.Random();
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: meteorDuration,
  );

  Timer? _spawnTimer;
  _StarPhase _phase = _StarPhase.idle;
  Offset _warningPosition = Offset.zero;
  Offset _meteorStart = Offset.zero;
  Offset _meteorEnd = Offset.zero;
  bool _caught = false;

  @override
  void initState() {
    super.initState();
    _scheduleNext();
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _scheduleNext() {
    _spawnTimer?.cancel();
    final delay = minDelay.inMilliseconds +
        _random.nextInt(maxDelay.inMilliseconds - minDelay.inMilliseconds + 1);
    _spawnTimer = Timer(Duration(milliseconds: delay), _startWarning);
  }

  void _startWarning() {
    if (!mounted) return;
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    setState(() {
      _phase = _StarPhase.warning;
      _caught = false;
      _warningPosition = Offset(
        width * (0.20 + _random.nextDouble() * 0.60),
        height * (0.18 + _random.nextDouble() * 0.50),
      );
    });

    _spawnTimer = Timer(warningDuration, _launchMeteor);
  }

  void _launchMeteor() {
    if (!mounted || _phase != _StarPhase.warning) return;

    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final start = Offset(
      width * (0.05 + _random.nextDouble() * 0.55),
      height * (0.08 + _random.nextDouble() * 0.35),
    );
    final end = Offset(
      width * (0.50 + _random.nextDouble() * 0.45),
      height * (0.55 + _random.nextDouble() * 0.35),
    );

    _meteorStart = start;
    _meteorEnd = end;
    _controller
      ..stop()
      ..reset();

    setState(() => _phase = _StarPhase.meteor);
    _controller.forward().whenCompleteOrCancel(() {
      if (!mounted) return;
      setState(() => _phase = _StarPhase.idle);
      widget.onMissed?.call();
      _scheduleNext();
    });
  }

  void _catchStar() {
    if (!mounted || _phase != _StarPhase.warning || _caught) return;
    _caught = true;
    _spawnTimer?.cancel();
    setState(() => _phase = _StarPhase.idle);
    widget.onCaught?.call();
    _scheduleNext();
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == _StarPhase.idle) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: _phase == _StarPhase.meteor,
        child: Stack(
          children: [
            if (_phase == _StarPhase.warning)
              Positioned(
                left: _warningPosition.dx - 16,
                top: _warningPosition.dy - 16,
                child: GestureDetector(
                  onTap: _catchStar,
                  child: const _WarningLight(),
                ),
              ),
            if (_phase == _StarPhase.meteor)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = Curves.easeInCubic.transform(_controller.value);
                  final position = Offset.lerp(_meteorStart, _meteorEnd, t)!;
                  final angle = math.atan2(
                    _meteorEnd.dy - _meteorStart.dy,
                    _meteorEnd.dx - _meteorStart.dx,
                  );
                  return Positioned(
                    left: position.dx,
                    top: position.dy,
                    child: Transform.rotate(
                      angle: angle,
                      alignment: Alignment.centerLeft,
                      child: child,
                    ),
                  );
                },
                child: const _Meteor(),
              ),
          ],
        ),
      ),
    );
  }
}

class _WarningLight extends StatelessWidget {
  const _WarningLight();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.65),
              blurRadius: 18,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _Meteor extends StatelessWidget {
  const _Meteor();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 18,
      child: CustomPaint(painter: _MeteorPainter()),
    );
  }
}

class _MeteorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final trail = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.transparent, Color(0xFF8E7CFF), Colors.white],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawOval(
      Rect.fromLTWH(0, centerY - 4, size.width * 0.86, 8),
      trail,
    );

    canvas.drawCircle(
      Offset(size.width * 0.90, centerY),
      6,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(size.width * 0.90, centerY),
      11,
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
