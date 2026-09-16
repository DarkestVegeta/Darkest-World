import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/content_models.dart';
import '../core/darkest_world_archive_telemetry.dart';
import '../core/darkest_world_navigation_state.dart';

/// Shared archive telemetry presentation. Animation timing stays host-owned.
class ArchiveSignalTelemetryLens extends StatelessWidget {
  final DarkestWorldNavigationState state;
  final bool compact;
  final double phase;
  final ValueChanged<ContentItem>? onPreviousTap;
  final ValueChanged<ContentItem>? onNextTap;
  final ValueChanged<ContentItem>? onRelatedTap;

  const ArchiveSignalTelemetryLens({
    super.key,
    required this.state,
    this.compact = false,
    this.phase = 0,
    this.onPreviousTap,
    this.onNextTap,
    this.onRelatedTap,
  });

  @override
  Widget build(BuildContext context) {
    final telemetry = DarkestWorldArchiveTelemetry.fromNavigation(state);
    final border = Color.lerp(
      const Color(0x397F70B0),
      const Color(0x7F9A8AC4),
      telemetry.signalIntensity,
    )!;
    return Container(
      height: compact ? 164 : 180,
      decoration: BoxDecoration(
        color: const Color(0xB5050610),
        border: Border.all(color: border),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ArchiveSignalPainter(
                phase: phase,
                continuity: telemetry.continuityCount,
                related: telemetry.relatedCount,
                intensity: telemetry.signalIntensity,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 10 : 16),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _SignalCore(phase: phase, intensity: telemetry.signalIntensity),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              telemetry.signalTitle,
                              style: const TextStyle(fontSize: 7, letterSpacing: 2.1, color: Color(0x7F9AA6BE)),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              telemetry.signal,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, letterSpacing: 1.8, fontWeight: FontWeight.w300),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              telemetry.routeLabel.toUpperCase(),
                              style: const TextStyle(fontSize: 5.5, letterSpacing: 1.4, color: Color(0x667F8AA2)),
                            ),
                          ],
                        ),
                      ),
                      if (!compact) ...[
                        _Metric(label: 'CHAIN', value: telemetry.chainLabel),
                        const SizedBox(width: 14),
                        _Metric(label: 'RELATED', value: telemetry.relatedLabel),
                        const SizedBox(width: 14),
                        _Metric(label: 'MODE', value: telemetry.presentationMode),
                        const SizedBox(width: 14),
                        _Metric(label: 'ORIGIN', value: telemetry.originLabel),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _ContinuityRail(
                  state: state,
                  compact: compact,
                  onPreviousTap: onPreviousTap,
                  onNextTap: onNextTap,
                ),
                const SizedBox(height: 7),
                _RelatedRail(
                  state: state,
                  compact: compact,
                  onTap: onRelatedTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalCore extends StatelessWidget {
  final double phase;
  final double intensity;
  const _SignalCore({required this.phase, required this.intensity});

  @override
  Widget build(BuildContext context) {
    final pulse = .5 + .5 * math.sin(phase * math.pi * 2);
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Color.lerp(const Color(0x527F70B0), const Color(0xAA9A8AC4), intensity)!),
        boxShadow: [BoxShadow(color: const Color(0x247F70B0), blurRadius: 8 + pulse * 8)],
      ),
      child: const Icon(Icons.adjust, size: 14, color: Color(0xAA9A8AC4)),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: const TextStyle(fontSize: 5, letterSpacing: 1.4, color: Color(0x557F8AA2))),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 6.5, letterSpacing: 1.0, color: Color(0x8897A8BE))),
        ],
      );
}

class _ContinuityRail extends StatelessWidget {
  final DarkestWorldNavigationState state;
  final bool compact;
  final ValueChanged<ContentItem>? onPreviousTap;
  final ValueChanged<ContentItem>? onNextTap;
  const _ContinuityRail({required this.state, required this.compact, this.onPreviousTap, this.onNextTap});

  @override
  Widget build(BuildContext context) {
    final telemetry = DarkestWorldArchiveTelemetry.fromNavigation(state);
    final labels = [telemetry.previousActionLabel, telemetry.currentActionLabel.toUpperCase(), telemetry.nextActionLabel];
    final items = [state.previous, state.current, state.next];
    final actions = [onPreviousTap, null, onNextTap];
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: 5),
          Expanded(
            child: InkWell(
              onTap: actions[i] == null || items[i] == null ? null : () => actions[i]!(items[i]!),
              child: Container(
                height: compact ? 23 : 26,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: i == 1 ? const Color(0x287F70B0) : const Color(0x0C7F70B0),
                  border: Border.all(color: i == 1 ? const Color(0x4C9A8AC4) : const Color(0x1D7F70B0)),
                ),
                child: Row(
                  children: [
                    Text(i == 0 ? 'P' : i == 1 ? 'C' : 'N', style: const TextStyle(fontSize: 6, color: Color(0x778F82A9))),
                    const SizedBox(width: 6),
                    Expanded(child: Text(labels[i], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 5.5, letterSpacing: 1.0, color: Color(0x8897A8BE)))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RelatedRail extends StatelessWidget {
  final DarkestWorldNavigationState state;
  final bool compact;
  final ValueChanged<ContentItem>? onTap;
  const _RelatedRail({required this.state, required this.compact, this.onTap});

  @override
  Widget build(BuildContext context) {
    final telemetry = DarkestWorldArchiveTelemetry.fromNavigation(state);
    if (!telemetry.hasRelated) {
      return Container(
        height: compact ? 21 : 24,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(color: const Color(0x087F70B0), border: Border.all(color: const Color(0x147F70B0))),
        child: const Text('NO RELATED SIGNALS', style: TextStyle(fontSize: 5.5, letterSpacing: 1.3, color: Color(0x557F8AA2))),
      );
    }
    final count = compact ? telemetry.compactVisibleRelatedCount : telemetry.visibleRelatedCount;
    final overflow = compact ? telemetry.compactRelatedOverflowLabel : telemetry.relatedOverflowLabel;
    final visible = state.related.take(count).toList(growable: false);
    return Row(
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          if (i > 0) const SizedBox(width: 5),
          Expanded(
            child: InkWell(
              onTap: onTap == null ? null : () => onTap!(visible[i]),
              child: Container(
                height: compact ? 21 : 24,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(color: const Color(0x0C7F70B0), border: Border.all(color: const Color(0x287F70B0))),
                child: Text(visible[i].title.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 5.2, letterSpacing: .8, color: Color(0x667F8AA2))),
              ),
            ),
          ),
        ],
        if (overflow.isNotEmpty) ...[
          const SizedBox(width: 5),
          Text(overflow, style: const TextStyle(fontSize: 5.5, color: Color(0x557F8AA2))),
        ],
      ],
    );
  }
}

class _ArchiveSignalPainter extends CustomPainter {
  final double phase;
  final int continuity;
  final int related;
  final double intensity;
  const _ArchiveSignalPainter({required this.phase, required this.continuity, required this.related, required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = Offset(size.width * .5, size.height * .48);
    final ring = Paint()..style = PaintingStyle.stroke..strokeWidth = .6..color = Color.lerp(const Color(0x147F70B0), const Color(0x397F70B0), intensity)!;
    for (var i = 0; i < 5; i++) {
      final w = size.width * (.28 + i * .11);
      canvas.drawOval(Rect.fromCenter(center: center, width: w, height: w * .16), ring);
    }
    final sweep = (phase * size.width * 1.15) % (size.width + 80) - 40;
    canvas.drawLine(Offset(sweep, 0), Offset(sweep + 26, size.height), Paint()..color = const Color(0x247F70B0));
    final nodes = math.min(8, math.max(1, continuity + related));
    for (var i = 0; i < nodes; i++) {
      final x = size.width * (.18 + i * .64 / math.max(1, nodes - 1));
      canvas.drawCircle(Offset(x, center.dy), i < continuity ? 1.7 : 1.1, Paint()..color = const Color(0x4C9A8AC4));
    }
    canvas.drawRect(rect, Paint()..shader = RadialGradient(colors: [const Color(0x00000000), const Color(0x55000000)]).createShader(rect));
  }

  @override
  bool shouldRepaint(covariant _ArchiveSignalPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.continuity != continuity || oldDelegate.related != related || oldDelegate.intensity != intensity;
}
