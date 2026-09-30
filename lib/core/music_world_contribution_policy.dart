/// Submission cadence foundation for one track per DarkestFamily persona.
class MusicWorldContributionPolicy {
  static const int monthlyCadenceThreshold = 100;
  static const Duration smallCommunityCadence = Duration(days: 14);

  final int activeUserCount;

  factory MusicWorldContributionPolicy({required int activeUserCount}) {
    if (activeUserCount < 0) {
      throw ArgumentError.value(activeUserCount, 'activeUserCount');
    }
    return MusicWorldContributionPolicy._(activeUserCount);
  }

  const MusicWorldContributionPolicy._(this.activeUserCount);

  /// Returns when the same persona may next submit a track.
  ///
  /// At 100 active users the cadence switches to one calendar month. Below
  /// that threshold it is a rolling 14-day interval. Pass the latest accepted
  /// submission timestamp for that persona; storage and authorization remain
  /// the responsibility of the repository/database layer.
  DateTime? nextAllowedAt(DateTime? lastSubmittedAt) {
    if (lastSubmittedAt == null) return null;

    if (activeUserCount < monthlyCadenceThreshold) {
      return lastSubmittedAt.add(smallCommunityCadence);
    }

    return _addCalendarMonth(lastSubmittedAt);
  }

  bool canSubmit({
    required DateTime now,
    required DateTime? lastSubmittedAt,
  }) {
    final next = nextAllowedAt(lastSubmittedAt);
    return next == null || !now.isBefore(next);
  }

  DateTime _addCalendarMonth(DateTime date) {
    final zeroBasedMonth = date.year * 12 + date.month;
    final year = zeroBasedMonth ~/ 12;
    final month = zeroBasedMonth % 12 + 1;
    final lastDayOfTargetMonth = DateTime(year, month + 1, 0).day;
    final day = date.day <= lastDayOfTargetMonth
        ? date.day
        : lastDayOfTargetMonth;

    if (date.isUtc) {
      return DateTime.utc(
        year,
        month,
        day,
        date.hour,
        date.minute,
        date.second,
        date.millisecond,
        date.microsecond,
      );
    }

    return DateTime(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }
}
