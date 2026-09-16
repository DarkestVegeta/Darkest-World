import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/darkest_world_navigation_state.dart';

/// Compact cinematic telemetry lens for archive/detail surfaces.
class DarkestWorldArchiveSignalLens extends StatelessWidget {
  final DarkestWorldNavigationState state;
  final bool compact;
  final double phase;

  const DarkestWorldArchiveSignalLens({
    super.key,
    required this.state,
    this.compact = false,
    this.phase = 0,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final dense = compact || width < 600;
    return Container(
      height: dense ? 54 : 64,
      decoration: BoxDecoration(
        color: const Color(0xB8050610),
        border: Border.all(color: const Color(0x397F70B0)),
      ),
      child: CustomPaint(
        painter: _ArchiveSignalLensPainter(
          phase: phase,
          continuity: state.continuityCount,
          related: state.related.length,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: dense ? 10 : 16),
          child: Row(
            children: [
              _SignalCore(phase: phase),
              SizedBox(width: dense ? 9 : 13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dense ? 'ARCHIVE SIGNAL' : 'ARCHIVE SIGNAL / NAVIGATION TELEMETRY',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 6.5, letterSpacing: 2.1, color: Color(0x788F82A9)),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      state.archiveSignal,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(fontSize: 9, letterSpacing: 1.7, color: Color(0xD9E3E6F2), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              if (!dense) ...[
                _Telemetry(label: 'POSITION', value: state.navigationPosition),
                const SizedBox(width: 18),
              ],
              _Telemetry(label: 'LINKS', value: '${state.continuityCount}'),
              if (!dense) const SizedBox(width: 14),
              if (!dense || width >= 440) _Telemetry(label: 'REL', value: '${state.related.length}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignalCore extends StatelessWidget {
  final double phase;
  const _SignalCore({required this.phase});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 20,
        height: 20,
        child: CustomPaint(painter: _SignalCorePainter(phase)),
      );
}

class _Telemetry extends StatelessWidget {
  final String label;
  final String value;
  const _Telemetry({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: const TextStyle(fontSize: 5.5, letterSpacing: 1.6, color: Color(0x557F8AA2))),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 7, letterSpacing: 1.2, color: Color(0xA8A7B4C9))),
        ],
      );
}

class _SignalCorePainter extends CustomPainter {
  final double phase;
  const _SignalCorePainter(this.phase);

  static final Paint _outerPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = const Color(0x357F70B0);
  static final Paint _corePaint = Paint()..color = const Color(0xB38F82A9);
  static final Paint _pulsePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = .7
    ..color = const Color(0x3C9DA8D0);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final pulse = .62 + .18 * math.sin(phase * math.pi * 2);
    canvas.drawCircle(center, 8, _outerPaint);
    canvas.drawCircle(center, 3.2, _corePaint);
    canvas.drawCircle(center, 5.5 * pulse, _pulsePaint);
  }

  @override
  bool shouldRepaint(covariant _SignalCorePainter oldDelegate) => oldDelegate.phase != phase;
}

class _ArchiveSignalLensPainter extends CustomPainter {
  final double phase;
  final int continuity;
  final int related;

  const _ArchiveSignalLensPainter({required this.phase, required this.continuity, required this.related});

  static final Paint _linePaint = Paint()..strokeWidth = 1;
  static final Paint _nodePaint = Paint()..color = const Color(0x3D8F82A9);

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * .5;
    final sweep = (phase * size.width * 1.35) % (size.width + 80) - 40;
    _linePaint.color = const Color(0x126F6595);
    canvas.drawLine(Offset(0, y), Offset(size.width, y), _linePaint);
    _linePaint.color = const Color(0x287F70B0);
    canvas.drawLine(Offset(sweep, 0), Offset(sweep + 22, size.height), _linePaint);

    final nodes = math.max(1, continuity + related);
    for (var i = 0; i < nodes && i < 8; i++) {
      final x = 28.0 + (i * (size.width - 56)) / math.max(1, nodes - 1);
      final radius = i < continuity ? 1.8 : 1.15;
      _nodePaint.strokeWidth = radius;
      canvas.drawCircle(Offset(x, y), radius, _nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArchiveSignalLensPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.continuity != continuity || oldDelegate.related != related;
}
