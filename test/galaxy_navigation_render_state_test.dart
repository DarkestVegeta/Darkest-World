import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/galaxy_render_state.dart';
import 'package:darkest_world/screens/galaxy_navigation_session.dart';

void main() {
  test('navigation session owns render state and resets it', () {
    final session = GalaxyNavigationSession.instance;
    session.updateRenderState(session.renderState.copyWith(zoom: 1.4, systemMap: true));

    expect(session.renderState.zoom, 1.4);
    expect(session.renderState.systemMap, isTrue);

    session.resetNavigation();

    expect(session.renderState.zoom, 1);
    expect(session.renderState.systemMap, isFalse);
  });
}
