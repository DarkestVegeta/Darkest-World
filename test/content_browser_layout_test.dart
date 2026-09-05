import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/content_browser_layout.dart';

void main() {
  group('ContentBrowserLayout', () {
    test('keeps focus inside a one-item collection', () {
      expect(
        ContentBrowserLayout.focusedIndex(
          offset: 0,
          step: 200,
          itemCount: 1,
        ),
        0,
      );
      expect(
        ContentBrowserLayout.focusedIndex(
          offset: 1000,
          step: 200,
          itemCount: 1,
        ),
        0,
      );
    });

    test('keeps focus inside a small collection', () {
      expect(
        ContentBrowserLayout.focusedIndex(
          offset: 0,
          step: 200,
          itemCount: 3,
        ),
        2,
      );
      expect(
        ContentBrowserLayout.focusedIndex(
          offset: 2000,
          step: 200,
          itemCount: 3,
        ),
        2,
      );
    });

    test('centers a target without exceeding scroll bounds', () {
      expect(
        ContentBrowserLayout.targetOffset(
          index: 0,
          step: 200,
          maxScrollExtent: 1000,
        ),
        0,
      );
      expect(
        ContentBrowserLayout.targetOffset(
          index: 4,
          step: 200,
          maxScrollExtent: 1000,
        ),
        400,
      );
      expect(
        ContentBrowserLayout.targetOffset(
          index: 9,
          step: 200,
          maxScrollExtent: 1000,
        ),
        1000,
      );
    });
  });
}
