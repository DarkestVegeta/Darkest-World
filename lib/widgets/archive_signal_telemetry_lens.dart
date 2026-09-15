import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/darkest_world_navigation_state.dart';

/// Cinematic telemetry lens for archive navigation state.
/// The host owns animation timing; this widget does not create a second clock.
class ArchiveSignalTelemetryLens extends StatelessWidget {
  final DarkestWorldNavigationState state;
  final bool compact;
  final double phase;

  const ArchiveSignalTelemetryLens({
    super.key,
    required this.state,
    this.compact = false,
    this.phase = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 92 : 108,
      decoration: BoxDecoration(
        color: const Color(0xB5050610),
        border: Border.all(color: const Color(0x397F70B0)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ArchiveSignalPainter(phase, state.continuityCount),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 18,
              vertical: 12,
            ),
            child: Row(
              children: [
                _SignalCore(active: state.continuityCount > 0),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'ARCHIVE SIGNAL',
                        style: TextStyle(
                          fontSize: 7,
                          letterSpacing: 2.5,
                          color: Color(0x7F9AA6BE),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        state.archiveSignal,
                        style: const TextStyle(
                          fontSize: 13,
                          letterSpacing: 2.1,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!compact) _SignalMetrics(state: state),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalCore extends StatelessWidget {
  final bool active;
  const _SignalCore({required this.active});

  @override
  Widget build(BuildContext context) => Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x527F70B0)),
          boxShadow: active
              ? const [BoxShadow(color: Color(0x247F70B0), blurRadius: 12)]
              : null,
        ),
        child: Icon(
          Icons.adjust,
          size: 14,
          color: active ? const Color(0xAA9A8AC4) : const Color(0x556F7890),
        ),
      );
}

class _SignalMetrics extends StatelessWidget {
  final DarkestWorldNavigationState state;
  const _SignalMetrics({required this.state});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _Metric(label: 'CHAIN', value: '${state.continuityCount}/2'),
          const SizedBox(width: 18),
          _Metric(label: 'RELATED', value: '${state.related.length}'),
          const SizedBox(width: 18),
          _Metric(label: 'POSITION', value: state.navigationPosition),
        ],
      );
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 5.5, letterSpacing: 1.8, color: Color(0x557F8AA2))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 7, letterSpacing: 1.3, color: Color(0x8897A8BE))),
        ],
      );
}

class _ArchiveSignalPainter extends CustomPainter {
  final double phase;
  final int links;
  const _ArchiveSignalPainter(this.phase, this.links);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .18, size.height * .5);
    final radius = math.min(size.height * .34, 30.0);
    final sweep = phase * math.pi * 2;

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x227F70B0);
    canvas.drawCircle(center, radius, ring);
    canvas.drawCircle(center, radius * .62, ring);

    final sweepPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0x3C9A8AC4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      sweep,
      math.pi * .42,
      false,
      sweepPaint,
    );

    for (var i = 0; i < links.clamp(0, 2); i++) {
      final angle = sweep + math.pi * (i == 0 ? .72 : 1.28);
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.drawCircle(point, 2.1, Paint()..color = const Color(0x609A8AC4));
    }
  }

  @override
  bool shouldRepaint(covariant _ArchiveSignalPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.links != links;
}
