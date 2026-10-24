import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../coord/coordinate_mapper.dart';

/// Grid lines and axes painted under the shapes of a `GeometryCanvas`.
///
/// Lines sit at whole multiples of [spacing] in geometry space, so they
/// follow the canvas's `CoordinateMapper`: with
/// `CoordinateMapper.centered` a line runs through the origin and the axes
/// cross in the middle.
///
/// ```dart
/// GeometryCanvas(
///   size: const Size(400, 300),
///   mapper: CoordinateMapper.centered(const Size(400, 300)),
///   grid: const GeoGrid(spacing: 20, majorEvery: 5),
///   shapes: [...],
/// )
/// ```
@immutable
class GeoGrid {
  /// Distance between grid lines, in geometry units. Must be positive.
  final double spacing;

  /// Color of the minor grid lines.
  final Color color;

  /// Width of the grid lines.
  final double strokeWidth;

  /// When set, every n-th line (counted from the origin) is drawn in
  /// [majorColor].
  final int? majorEvery;

  /// Color of the major grid lines.
  final Color majorColor;

  /// Draw the X and Y axes through the geometry origin.
  final bool showAxes;

  /// Color of the axes.
  final Color axisColor;

  /// Width of the axes.
  final double axisWidth;

  /// Creates a grid.
  const GeoGrid({
    this.spacing = 20,
    this.color = const Color(0x1F000000),
    this.strokeWidth = 1,
    this.majorEvery,
    this.majorColor = const Color(0x3D000000),
    this.showAxes = true,
    this.axisColor = const Color(0x8A000000),
    this.axisWidth = 1,
  }) : assert(spacing > 0),
       assert(majorEvery == null || majorEvery > 0);

  /// Paints the grid over a canvas of [size] whose geometry is placed by
  /// [mapper].
  void paint(Canvas canvas, Size size, CoordinateMapper mapper) {
    final minor = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    final major = Paint()
      ..color = majorColor
      ..strokeWidth = strokeWidth;
    final origin = mapper.origin;

    Paint lineFor(int k) {
      final every = majorEvery;
      return every != null && k % every == 0 ? major : minor;
    }

    final firstX = (-origin.dx / spacing).ceil();
    final lastX = ((size.width - origin.dx) / spacing).floor();
    for (var k = firstX; k <= lastX; k++) {
      final x = origin.dx + k * spacing;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), lineFor(k));
    }
    final firstY = (-origin.dy / spacing).ceil();
    final lastY = ((size.height - origin.dy) / spacing).floor();
    for (var k = firstY; k <= lastY; k++) {
      final y = origin.dy + k * spacing;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), lineFor(k));
    }

    if (showAxes) {
      final axis = Paint()
        ..color = axisColor
        ..strokeWidth = axisWidth;
      canvas
        ..drawLine(Offset(0, origin.dy), Offset(size.width, origin.dy), axis)
        ..drawLine(Offset(origin.dx, 0), Offset(origin.dx, size.height), axis);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeoGrid &&
          other.spacing == spacing &&
          other.color == color &&
          other.strokeWidth == strokeWidth &&
          other.majorEvery == majorEvery &&
          other.majorColor == majorColor &&
          other.showAxes == showAxes &&
          other.axisColor == axisColor &&
          other.axisWidth == axisWidth);

  @override
  int get hashCode => Object.hash(
    spacing,
    color,
    strokeWidth,
    majorEvery,
    majorColor,
    showAxes,
    axisColor,
    axisWidth,
  );
}
