import 'package:flutter/gestures.dart';
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
import '../util/shape_path.dart';
import 'styled_shape.dart';

/// Renders an arbitrary list of [StyledShape]s onto a single canvas.
///
/// Per-shape `onTap` and `onHoverChanged` callbacks dispatch top-down:
/// the topmost shape covering the pointer wins, and shapes painted earlier
/// (visually below) do not see the event.
///
/// ```dart
/// GeometryCanvas(
///   size: const Size(400, 300),
///   shapes: [
///     StyledShape(
///       Circle(center: Point(100, 100), radius: 50),
///       style: ShapeStyle.filled(Colors.blue),
///       onTap: () => print('blue'),
///     ),
///   ],
/// )
/// ```
class GeometryCanvas extends StatefulWidget {
  /// Logical size of the canvas.
  final Size size;

  /// Shapes to paint, in paint order (first = bottom).
  final List<StyledShape> shapes;

  /// Coordinate mapper applied to every shape.
  final CoordinateMapper mapper;

  /// Background color painted before any shape.
  ///
  /// `null` (default) leaves the canvas transparent so widgets stacked
  /// underneath remain visible.
  final Color? backgroundColor;

  /// How content drawn outside [size] is clipped.
  ///
  /// Defaults to [Clip.hardEdge] so shapes never bleed onto neighboring
  /// widgets. Set to [Clip.none] to allow overflow.
  final Clip clipBehavior;

  /// Creates a multi-shape canvas.
  const GeometryCanvas({
    super.key,
    required this.size,
    required this.shapes,
    this.mapper = CoordinateMapper.identity,
    this.backgroundColor,
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  State<GeometryCanvas> createState() => _GeometryCanvasState();
}

class _GeometryCanvasState extends State<GeometryCanvas> {
  StyledShape? _hovered;

  bool get _hasInteraction =>
      widget.shapes.any((s) => s.onTap != null || s.onHoverChanged != null);

  StyledShape? _topShapeAt(Offset position) {
    for (var i = widget.shapes.length - 1; i >= 0; i--) {
      final s = widget.shapes[i];
      if (s.onTap == null && s.onHoverChanged == null) continue;
      try {
        final path = shapeToPath(s.shape, widget.mapper);
        if (path.contains(position)) return s;
      } on UnsupportedError {
        continue;
      }
    }
    return null;
  }

  void _setHovered(StyledShape? next) {
    if (identical(next, _hovered)) return;
    _hovered?.onHoverChanged?.call(false);
    _hovered = next;
    next?.onHoverChanged?.call(true);
  }

  void _onPointerHover(Offset position) {
    _setHovered(_topShapeAt(position));
  }

  void _onTapUp(TapUpDetails details) {
    final hit = _topShapeAt(details.localPosition);
    hit?.onTap?.call();
  }

  @override
  void didUpdateWidget(covariant GeometryCanvas old) {
    super.didUpdateWidget(old);
    if (!_hasInteraction && _hovered != null) {
      _hovered?.onHoverChanged?.call(false);
      _hovered = null;
    }
  }

  @override
  void dispose() {
    _hovered?.onHoverChanged?.call(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget paint = CustomPaint(
      size: widget.size,
      painter: _GeometryCanvasPainter(
        shapes: widget.shapes,
        mapper: widget.mapper,
        backgroundColor: widget.backgroundColor,
      ),
    );
    if (widget.clipBehavior != Clip.none) {
      paint = ClipRect(clipBehavior: widget.clipBehavior, child: paint);
    }
    paint = RepaintBoundary(child: paint);
    if (!_hasInteraction) return paint;

    return MouseRegion(
      opaque: false,
      onHover: (e) => _onPointerHover(e.localPosition),
      onExit: (_) => _setHovered(null),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerHover: (e) {
          if (e.kind == PointerDeviceKind.mouse) return;
          _onPointerHover(e.localPosition);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: _onTapUp,
          child: paint,
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
      CirclePainter(
        circle: shape,
        style: style,
        mapper: mapper,
      ).paint(canvas, size);
    } else if (shape is geo.Ellipse) {
      EllipsePainter(
        ellipse: shape,
        style: style,
        mapper: mapper,
      ).paint(canvas, size);
    } else if (shape is geo.Rectangle) {
      RectanglePainter(
        rectangle: shape,
        style: style,
        mapper: mapper,
      ).paint(canvas, size);
    } else if (shape is geo.Triangle) {
      TrianglePainter(
        triangle: shape,
        style: style,
        mapper: mapper,
      ).paint(canvas, size);
    } else if (shape is geo.Quadrilateral) {
      QuadrilateralPainter(
        quad: shape,
        style: style,
        mapper: mapper,
      ).paint(canvas, size);
    } else if (shape is geo.Polygon) {
      PolygonPainter(
        polygon: shape,
        style: style,
        mapper: mapper,
      ).paint(canvas, size);
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
