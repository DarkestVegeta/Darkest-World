import 'dart:math' as math;

class ContentBrowserLayout {
  const ContentBrowserLayout._();

  static int focusedIndex({
    required double offset,
    required double step,
    required int itemCount,
  }) {
    if (itemCount <= 0 || step <= 0) return 0;
    final index = (offset / step + 2).round();
    return index.clamp(0, itemCount - 1);
  }

  static double targetOffset({
    required int index,
    required double step,
    required double maxScrollExtent,
  }) {
    if (step <= 0 || maxScrollExtent <= 0) return 0;
    return math.min(math.max(0, (index - 2) * step).toDouble(), maxScrollExtent);
  }
}
