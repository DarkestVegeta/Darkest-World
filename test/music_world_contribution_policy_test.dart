import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/music_world_contribution_policy.dart';

void main() {
  group('MusicWorldContributionPolicy', () {
    test('allows the first contribution for a persona', () {
      final policy = MusicWorldContributionPolicy(activeUserCount: 99);

      expect(
        policy.canSubmit(
          now: DateTime.utc(2026, 9, 30),
          lastSubmittedAt: null,
        ),
        isTrue,
      );
      expect(policy.nextAllowedAt(null), isNull);
    });

    test('uses a rolling 14-day cadence below 100 active users', () {
      final policy = MusicWorldContributionPolicy(activeUserCount: 99);
      final lastSubmission = DateTime.utc(2026, 9, 1);
      final nextAllowed = DateTime.utc(2026, 9, 15);

      expect(policy.nextAllowedAt(lastSubmission), nextAllowed);
      expect(
        policy.canSubmit(
          now: DateTime.utc(2026, 9, 14, 23, 59, 59),
          lastSubmittedAt: lastSubmission,
        ),
        isFalse,
      );
      expect(
        policy.canSubmit(
          now: nextAllowed,
          lastSubmittedAt: lastSubmission,
        ),
        isTrue,
      );
    });

    test('uses one calendar month starting at exactly 100 users', () {
      final policy = MusicWorldContributionPolicy(activeUserCount: 100);
      final lastSubmission = DateTime.utc(2026, 9, 30, 12);
      final nextAllowed = DateTime.utc(2026, 10, 30, 12);

      expect(policy.nextAllowedAt(lastSubmission), nextAllowed);
      expect(
        policy.canSubmit(
          now: DateTime.utc(2026, 10, 29, 23, 59, 59),
          lastSubmittedAt: lastSubmission,
        ),
        isFalse,
      );
      expect(
        policy.canSubmit(
          now: nextAllowed,
          lastSubmittedAt: lastSubmission,
        ),
        isTrue,
      );
    });

    test('clamps month-end submissions to the target month end', () {
      final policy = MusicWorldContributionPolicy(activeUserCount: 100);

      expect(
        policy.nextAllowedAt(DateTime.utc(2026, 1, 31, 9)),
        DateTime.utc(2026, 2, 28, 9),
      );
      expect(
        policy.nextAllowedAt(DateTime.utc(2024, 1, 31, 9)),
        DateTime.utc(2024, 2, 29, 9),
      );
    });

    test('rejects an invalid negative active user count', () {
      expect(
        () => MusicWorldContributionPolicy(activeUserCount: -1),
        throwsArgumentError,
      );
    });
  });
}
