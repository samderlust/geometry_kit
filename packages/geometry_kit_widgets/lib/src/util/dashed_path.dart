import 'dart:ui';

import '../style/dash_pattern.dart';

/// Returns a new [Path] containing only the segments of [source] that fall
/// within the "on" portions of the supplied [pattern].
///
/// Implemented with [PathMetrics]; works for any path including curves and
/// closed shapes. Each painter calls this helper instead of duplicating dash
/// logic.
Path buildDashedPath(Path source, DashPattern pattern) {
  final dest = Path();
  if (pattern.intervals.isEmpty) return source;

  final intervals = pattern.intervals;
  for (final metric in source.computeMetrics()) {
    var distance = pattern.phase % _patternLength(intervals);
    var index = 0;
    var draw = true;

    while (distance < metric.length) {
      final segLen = intervals[index % intervals.length];
      final next = distance + segLen;
      if (draw) {
        dest.addPath(
          metric.extractPath(
            distance.clamp(0, metric.length),
            next.clamp(0, metric.length),
          ),
          Offset.zero,
        );
      }
      distance = next;
      draw = !draw;
      index++;
    }
  }
  return dest;
}

double _patternLength(List<double> intervals) {
  var sum = 0.0;
  for (final v in intervals) {
    sum += v;
  }
  return sum;
}
