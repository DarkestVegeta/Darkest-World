import 'package:flutter/foundation.dart';

@immutable
class GalaxyRenderState {
  final double phase;
  final double orbit;
  final double zoom;
  final bool systemMap;
  final bool labels;
  final bool detail;
  final bool cinematic;
  final bool compact;

  const GalaxyRenderState({
    required this.phase,
    required this.orbit,
    required this.zoom,
    required this.systemMap,
    required this.labels,
    required this.detail,
    required this.cinematic,
    required this.compact,
  });

  GalaxyRenderState copyWith({
    double? phase,
    double? orbit,
    double? zoom,
    bool? systemMap,
    bool? labels,
    bool? detail,
    bool? cinematic,
    bool? compact,
  }) {
    return GalaxyRenderState(
      phase: phase ?? this.phase,
      orbit: orbit ?? this.orbit,
      zoom: zoom ?? this.zoom,
      systemMap: systemMap ?? this.systemMap,
      labels: labels ?? this.labels,
      detail: detail ?? this.detail,
      cinematic: cinematic ?? this.cinematic,
      compact: compact ?? this.compact,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GalaxyRenderState &&
          other.phase == phase &&
          other.orbit == orbit &&
          other.zoom == zoom &&
          other.systemMap == systemMap &&
          other.labels == labels &&
          other.detail == detail &&
          other.cinematic == cinematic &&
          other.compact == compact;

  @override
  int get hashCode => Object.hash(
        phase,
        orbit,
        zoom,
        systemMap,
        labels,
        detail,
        cinematic,
        compact,
      );

  static GalaxyRenderState initial({required bool compact}) => GalaxyRenderState(
        phase: 0,
        orbit: 0,
        zoom: 1,
        systemMap: false,
        labels: true,
        detail: true,
        cinematic: true,
        compact: compact,
      );
}
