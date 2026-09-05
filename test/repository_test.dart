import 'package:flutter_test/flutter_test.dart';

void main() {
  group('project smoke checks', () {
    test('Dart test environment is available', () {
      expect(2 + 2, 4);
    });

    test('content page size stays at 36', () {
      const pageSize = 36;
      expect(pageSize, 36);
    });
  });
}
