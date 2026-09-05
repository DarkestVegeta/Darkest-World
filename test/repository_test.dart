import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/content_browser_layout.dart';

void main() {
  group('ContentBrowserLayout', () {
    test('keeps the third item focused at the initial offset', () {
      expect(
        ContentBrowserLayout.focusedIndex(
          offset: 0,
          step: 200,
          itemCount: 10,
        ),
        2,
      );
    });

    test('maps each horizontal step to the next focused item', () {
      expect(
        ContentBrowserLayout.focusedIndex(
          offset: 400,
          step: 200,
          itemCount: 10,
        ),
        4,
      );
    });

    test('clamps focus to the available items', () {
      expect(
        ContentBrowserLayout.focusedIndex(
          offset: 5000,
          step: 200,
          itemCount: 4,
        ),
        3,
      );
    });

    test('centers a selected item using the two-slot offset', () {
      expect(
        ContentBrowserLayout.targetOffset(
          index: 5,
          step: 200,
          maxScrollExtent: 2000,
        ),
        600,
      );
    });

    test('never returns a target beyond the scroll extent', () {
      expect(
        ContentBrowserLayout.targetOffset(
          index: 20,
          step: 200,
          maxScrollExtent: 500,
        ),
        500,
      );
    });
  });
}
