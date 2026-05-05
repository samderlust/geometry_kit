import 'package:flutter/foundation.dart';

/// A dash pattern applied to stroked shapes.
///
/// [intervals] alternates on/off lengths in logical pixels. For example,
/// `[8, 4]` means an 8-pixel dash followed by a 4-pixel gap, repeating.
/// [phase] shifts the pattern's starting point along the path.
///
/// ```dart
/// const DashPattern([8, 4]);            // 8 on, 4 off
/// const DashPattern([2, 2, 8, 2]);      // dot-dot-dash-dot
/// ```
@immutable
class DashPattern {
  /// Alternating on/off lengths in logical pixels.
  ///
  /// Must contain at least two values.
  final List<double> intervals;

  /// Starting offset into the pattern, in logical pixels.
  final double phase;

  /// Creates a dash pattern. [intervals] should contain at least two values.
  const DashPattern(this.intervals, {this.phase = 0});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DashPattern) return false;
    if (other.phase != phase) return false;
    if (other.intervals.length != intervals.length) return false;
    for (var i = 0; i < intervals.length; i++) {
      if (other.intervals[i] != intervals[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(phase, Object.hashAll(intervals));
}
