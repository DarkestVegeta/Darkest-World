import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/galaxy_render_state.dart';

void main() {
  test('initial state is deterministic', () {
    final state = GalaxyRenderState.initial(compact: true);

    expect(state.phase, 0);
    expect(state.orbit, 0);
    expect(state.zoom, 1);
    expect(state.systemMap, isFalse);
    expect(state.labels, isTrue);
    expect(state.detail, isTrue);
    expect(state.cinematic, isTrue);
    expect(state.compact, isTrue);
  });

  test('copyWith changes only requested render fields', () {
    const state = GalaxyRenderState(
      phase: .25,
      orbit: .4,
      zoom: 1.2,
      systemMap: false,
      labels: true,
      detail: true,
      cinematic: true,
      compact: false,
    );

    final changed = state.copyWith(
      zoom: 1.4,
      systemMap: true,
      cinematic: false,
    );

    expect(changed.phase, .25);
    expect(changed.orbit, .4);
    expect(changed.zoom, 1.4);
    expect(changed.systemMap, isTrue);
    expect(changed.labels, isTrue);
    expect(changed.detail, isTrue);
    expect(changed.cinematic, isFalse);
    expect(changed.compact, isFalse);
  });
}
