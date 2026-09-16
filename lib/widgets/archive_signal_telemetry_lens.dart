import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/content_models.dart';
import '../core/darkest_world_archive_telemetry.dart';
import '../core/darkest_world_navigation_state.dart';

/// Cinematic telemetry lens for archive navigation state.
/// The host owns animation timing; this widget does not create a second clock.
class ArchiveSignalTelemetryLens extends StatelessWidget {
  final DarkestWorldNavigationState state;
  final bool compact;
  final double phase;
  final ValueChanged<ContentItem>? onPreviousTap;
  final ValueChanged<ContentItem>? onNextTap;
  final ValueChanged<ContentItem>? onRelatedTap;

  const ArchiveSignalTelemetryLens({super.key, required this.state, this.compact = false, this.phase = 0, this.onPreviousTap, this.onNextTap, this.onRelatedTap});

  @override
  Widget build(BuildContext context) {
    final telemetry = DarkestWorldArchiveTelemetry.fromNavigation(state);
    return Container(
      height: compact ? 164 : 180,
      decoration: BoxDecoration(color: const Color(0xB5050610), border: Border.all(color: Color.lerp(const Color(0x397F70B0), const Color(0x597F70B0), telemetry.signalIntensity)!)),
      child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _ArchiveSignalPainter(phase, telemetry.continuityCount, telemetry.relatedCount, telemetry.signalIntensity))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 18, vertical: 12),
          child: Column(children: [
            Expanded(child: Row(children: [
              _SignalCore(active: telemetry.hasContinuity, phase: phase, intensity: telemetry.signalIntensity),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('ARCHIVE SIGNAL', style: TextStyle(fontSize: 7, letterSpacing: 2.5, color: Color(0x7F9AA6BE))),
                const SizedBox(height: 5),
                Text(telemetry.signal, style: const TextStyle(fontSize: 13, letterSpacing: 2.1, fontWeight: FontWeight.w300)),
                const SizedBox(height: 5),
                Text(telemetry.routeLabel.toUpperCase(), style: const TextStyle(fontSize: 5.5, letterSpacing: 1.6, color: Color(0x667F8AA2))),
                const SizedBox(height: 4),
                Text(telemetry.continuityState, style: const TextStyle(fontSize: 5.5, letterSpacing: 1.1, color: Color(0x557F8AA2))),
                if (!compact) ...[const SizedBox(height: 4), Text('ID ${telemetry.currentLabel}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 5, letterSpacing: 1.0, color: Color(0x447F8AA2)))],
              ])),
              if (!compact) _SignalMetrics(telemetry: telemetry),
            ])),
            const SizedBox(height: 9),
            _ContinuityRail(state: state, compact: compact, phase: phase, onPreviousTap: onPreviousTap, onNextTap: onNextTap),
            const SizedBox(height: 8),
            _RelatedRail(state: state, compact: compact, phase: phase, onTap: onRelatedTap),
          ]),
        ),
      ]),
    );
  }
}

class _SignalCore extends StatelessWidget {
  final bool active; final double phase; final double intensity;
  const _SignalCore({required this.active, required this.phase, required this.intensity});
  @override
  Widget build(BuildContext context) {
    final pulse = .5 + .5 * math.sin(phase * math.pi * 2);
    final glow = (10 + pulse * 6) * (.65 + intensity * .35);
    return Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Color.lerp(const Color(0x527F70B0), const Color(0x7F9A8AC4), intensity)!), boxShadow: active ? [BoxShadow(color: const Color(0x247F70B0), blurRadius: glow)] : null), child: Icon(Icons.adjust, size: 14, color: active ? Color.lerp(const Color(0x779A8AC4), const Color(0xCCB2A5D8), pulse * intensity)! : const Color(0x556F7890)));
  }
}

class _SignalMetrics extends StatelessWidget {
  final DarkestWorldArchiveTelemetry telemetry;
  const _SignalMetrics({required this.telemetry});
  @override
  Widget build(BuildContext context) => Row(children: [
    _Metric(label: 'CHAIN', value: telemetry.chainLabel), const SizedBox(width: 18),
    _Metric(label: 'RELATED', value: telemetry.relatedLabel), const SizedBox(width: 18),
    _Metric(label: 'POSITION', value: telemetry.position), const SizedBox(width: 18),
    _Metric(label: 'SIGNAL', value: telemetry.signalBand), const SizedBox(width: 18),
    _Metric(label: 'MODE', value: telemetry.presentationMode), const SizedBox(width: 18),
    _Metric(label: 'ORIGIN', value: telemetry.originLabel),
  ]);
}

class _Metric extends StatelessWidget {
  final String label; final String value;
  const _Metric({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [Text(label, style: const TextStyle(fontSize: 5.5, letterSpacing: 1.8, color: Color(0x557F8AA2))), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 7, letterSpacing: 1.3, color: Color(0x8897A8BE)))]);
}

class _ContinuityRail extends StatelessWidget {
  final DarkestWorldNavigationState state; final bool compact; final double phase; final ValueChanged<ContentItem>? onPreviousTap; final ValueChanged<ContentItem>? onNextTap;
  const _ContinuityRail({required this.state, required this.compact, required this.phase, this.onPreviousTap, this.onNextTap});
  String _label(String? value, String fallback) { if (value == null || value.trim().isEmpty) return fallback; final text = value.trim().toUpperCase(); return text.length > 24 ? '${text.substring(0, 21)}…' : text; }
  @override
  Widget build(BuildContext context) {
    final telemetry = DarkestWorldArchiveTelemetry.fromNavigation(state);
    final slots = <String>[_label(state.previous?.title, 'NO PREVIOUS'), _label(state.current.title, 'CURRENT'), _label(state.next?.title, 'NO NEXT')];
    final actions = <ValueChanged<ContentItem>?>[telemetry.canGoPrevious ? onPreviousTap : null, null, telemetry.canGoNext ? onNextTap : null];
    final items = <ContentItem?>[state.previous, state.current, state.next];
    return Row(children: [for (var i = 0; i < slots.length; i++) ...[if (i > 0) const SizedBox(width: 5), Expanded(child: Material(color: Colors.transparent, child: InkWell(onTap: actions[i] == null || items[i] == null ? null : () => actions[i]!(items[i]!), splashColor: const Color(0x227F70B0), highlightColor: i == 1 ? Colors.transparent : const Color(0x147F70B0), child: Container(height: compact ? 24 : 27, padding: const EdgeInsets.symmetric(horizontal: 7), alignment: Alignment.centerLeft, decoration: BoxDecoration(color: i == 1 ? const Color(0x287F70B0) : const Color(0x0C7F70B0), border: Border.all(color: i == 1 ? const Color(0x4C9A8AC4) : const Color(0x1D7F70B0))), child: Row(children: [Text(i == 0 ? 'P' : i == 1 ? 'C' : 'N', style: TextStyle(fontSize: 6, letterSpacing: 1.2, color: i == 1 ? const Color(0xAA9A8AC4) : const Color(0x557F8AA2))), const SizedBox(width: 6), Expanded(child: Text(slots[i], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 5.5, letterSpacing: 1.1, color: i == 1 ? const Color(0xAA97A8BE) : const Color(0x667F8AA2)))), if (i == 1 && telemetry.hasContinuity) Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: Color.lerp(const Color(0x557F70B0), const Color(0xAA9A8AC4), .5 + .5 * math.sin(phase * math.pi * 2))))]))))]],);
  }
}

class _RelatedRail extends StatelessWidget {
  final DarkestWorldNavigationState state; final bool compact; final double phase; final ValueChanged<ContentItem>? onTap;
  const _RelatedRail({required this.state, required this.compact, required this.phase, this.onTap});
  String _label(String value) { final text = value.trim().toUpperCase(); if (text.isEmpty) return 'RELATED WORLD'; return text.length > 28 ? '${text.substring(0, 25)}…' : text; }
  @override
  Widget build(BuildContext context) {
    final telemetry = DarkestWorldArchiveTelemetry.fromNavigation(state);
    if (!telemetry.hasRelated) return Container(height: compact ? 22 : 25, alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 7), decoration: BoxDecoration(color: const Color(0x087F70B0), border: Border.all(color: const Color(0x147F70B0))), child: const Text('NO RELATED SIGNALS', style: TextStyle(fontSize: 5.5, letterSpacing: 1.4, color: Color(0x557F8AA2))));
    final visibleCount = compact ? telemetry.compactVisibleRelatedCount : telemetry.visibleRelatedCount;
    final overflowCount = compact ? telemetry.compactRelatedOverflowCount : telemetry.relatedOverflowCount;
    final visible = state.related.take(visibleCount).toList(growable: false);
    final pulse = .5 + .5 * math.sin(phase * math.pi * 2);
    return Row(children: [for (var i = 0; i < visible.length; i++) ...[if (i > 0) const SizedBox(width: 5), Expanded(child: Material(color: Colors.transparent, child: InkWell(onTap: onTap == null ? null : () => onTap!(visible[i]), splashColor: const Color(0x227F70B0), highlightColor: const Color(0x147F70B0), child: Container(height: compact ? 22 : 25, padding: const EdgeInsets.symmetric(horizontal: 7), decoration: BoxDecoration(color: const Color(0x0C7F70B0), border: Border.all(color: Color.lerp(const Color(0x147F70B0), const Color(0x397F70B0), pulse)!)), child: Row(children: [Container(width: 3, height: 3, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0x667F70B0), boxShadow: [BoxShadow(color: const Color(0x247F70B0), blurRadius: 4 + pulse * 3)])), const SizedBox(width: 6), Expanded(child: Text(_label(visible[i].title), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 5.2, letterSpacing: 1.0, color: Color(0x667F8AA2))))])))))], if (overflowCount > 0) ...[const SizedBox(width: 5), Text('+$overflowCount', style: const TextStyle(fontSize: 5.5, letterSpacing: 1.1, color: Color(0x557F8AA2)))]]);
  }
}

class _ArchiveSignalPainter extends CustomPainter {
  final double phase; final int links; final int related; final double intensity;
  const _ArchiveSignalPainter(this.phase, this.links, this.related, this.intensity);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .18, size.height * .31);
    final radius = math.min(size.height * .21, 30.0);
    final sweep = phase * math.pi * 2;
    final ring = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = Color.lerp(const Color(0x227F70B0), const Color(0x4A9A8AC4), intensity)!;
    canvas.drawCircle(center, radius, ring); canvas.drawCircle(center, radius * .62, ring);
    final sweepPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = Color.lerp(const Color(0x3C9A8AC4), const Color(0x6C9A8AC4), intensity)!;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), sweep, math.pi * .42, false, sweepPaint);
    for (var i = 0; i < links.clamp(0, 2); i++) { final angle = sweep + math.pi * (i == 0 ? .72 : 1.28); final point = Offset(center.dx + math.cos(angle) * radius, center.dy + math.sin(angle) * radius); canvas.drawCircle(point, 2.1 + intensity * .7, Paint()..color = const Color(0x609A8AC4)); }
    final relatedCount = related.clamp(0, 6);
    if (relatedCount > 0) { final relatedPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = .7..color = Color.lerp(const Color(0x187F70B0), const Color(0x3A7F70B0), intensity)!; final relatedRadius = radius + 7 + intensity * 3; canvas.drawCircle(center, relatedRadius, relatedPaint); for (var i = 0; i < relatedCount; i++) { final angle = sweep * .55 + (math.pi * 2 * i / relatedCount); final point = Offset(center.dx + math.cos(angle) * relatedRadius, center.dy + math.sin(angle) * relatedRadius); canvas.drawCircle(point, 1.35 + intensity * .35, Paint()..color = const Color(0x4A7F70B0)); } }
  }
  @override bool shouldRepaint(covariant _ArchiveSignalPainter oldDelegate) => oldDelegate.phase != phase || oldDelegate.links != links || oldDelegate.related != related || oldDelegate.intensity != intensity;
}
