import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/chat_search_repository.dart';

void main() {
  test('escapes ILIKE wildcard characters so search text stays literal', () {
    expect(
      ChatSearchRepository.escapeIlikeQuery(r'50%_\test'),
      r'50\%\_\\test',
    );
  });

  test('keeps ordinary search text unchanged', () {
    expect(
      ChatSearchRepository.escapeIlikeQuery('Sonic 2'),
      'Sonic 2',
    );
  });
}
