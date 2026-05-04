import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart' as geo;

import '../coord/coordinate_mapper.dart';
import '../painters/circle_painter.dart';
import '../painters/ellipse_painter.dart';
import '../painters/polygon_painter.dart';
import '../painters/quadrilateral_painter.dart';
import '../painters/rectangle_painter.dart';
import '../painters/triangle_painter.dart';
import '../style/shape_style.dart';
import 'styled_shape.dart';

/// Renders an arbitrary list of [StyledShape]s onto a single canvas.
///
/// Phase 1: render only. Hit testing, drag, and grid/axes overlays are
/// scheduled for later phases.
///
/// ```dart
/// GeometryCanvas(
///   size: const Size(400, 300),
///   shapes: [
///     StyledShape(
///       Circle(center: Point(100, 100), radius: 50),
///       style: ShapeStyle.filled(Colors.blue),
///     ),
///   ],
/// )
/// ```
class GeometryCanvas extends StatelessWidget {
  /// Logical size of the canvas.
  final Size size;

  /// Shapes to paint, in paint order (first = bottom).
  final List<StyledShape> shapes;

  /// Coordinate mapper applied to every shape.
  final CoordinateMapper mapper;

  /// Background color painted before any shape.
  final Color? backgroundColor;

  /// Creates a multi-shape canvas.
  const GeometryCanvas({
    super.key,
    required this.size,
    required this.shapes,
    this.mapper = CoordinateMapper.identity,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: size,
        painter: _GeometryCanvasPainter(
          shapes: shapes,
          mapper: mapper,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}

class _GeometryCanvasPainter extends CustomPainter {
  final List<StyledShape> shapes;
  final CoordinateMapper mapper;
  final Color? backgroundColor;

  const _GeometryCanvasPainter({
    required this.shapes,
    required this.mapper,
    this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundColor != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = backgroundColor!,
      );
    }
    for (final s in shapes) {
      _dispatch(canvas, size, s.shape, s.style);
    }
  }

  void _dispatch(Canvas canvas, Size size, geo.Shape shape, ShapeStyle style) {
    if (shape is geo.Circle) {
      CirclePainter(circle: shape, style: style, mapper: mapper)
          .paint(canvas, size);
    } else if (shape is geo.Ellipse) {
      EllipsePainter(ellipse: shape, style: style, mapper: mapper)
          .paint(canvas, size);
    } else if (shape is geo.Rectangle) {
      RectanglePainter(rectangle: shape, style: style, mapper: mapper)
          .paint(canvas, size);
    } else if (shape is geo.Triangle) {
      TrianglePainter(triangle: shape, style: style, mapper: mapper)
          .paint(canvas, size);
    } else if (shape is geo.Quadrilateral) {
      QuadrilateralPainter(quad: shape, style: style, mapper: mapper)
          .paint(canvas, size);
    } else if (shape is geo.Polygon) {
      PolygonPainter(polygon: shape, style: style, mapper: mapper)
          .paint(canvas, size);
    } else {
      // Lines aren't a Shape subtype in geometry_kit; users supply Line via
      // a separate path. Future shape types fall through silently.
      assert(() {
        debugPrint(
          'GeometryCanvas: no painter registered for ${shape.runtimeType}',
        );
        return true;
      }());
    }
  }

  @override
  bool shouldRepaint(covariant _GeometryCanvasPainter old) =>
      old.backgroundColor != backgroundColor ||
      old.mapper != mapper ||
      !_listEquals(old.shapes, shapes);
}

bool _listEquals(List<StyledShape> a, List<StyledShape> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
