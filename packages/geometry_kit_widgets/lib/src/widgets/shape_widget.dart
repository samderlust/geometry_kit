import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart' as geo;

import '../coord/coordinate_mapper.dart';
import '../style/shape_style.dart';
import '../util/paint_helpers.dart';
import '../util/shape_path.dart';
import 'shape_clipper.dart';

/// Composes a shape outline, an optional clipped [child] widget, and an
/// optional [ShapeStyle] paint into one widget.
///
/// Layering (back → front):
/// 1. The [child] widget, clipped to the shape via [ShapeClipper].
/// 2. The shape outline / fill paint from [style].
///
/// Stroke draws above the clipped child so the outline is not eaten by the
/// clip's own anti-aliased edge.
///
/// ```dart
/// ShapeWidget(
///   shape: const Circle(center: Point(50, 50), radius: 50),
///   size: const Size(100, 100),
///   style: const ShapeStyle.stroked(Colors.white, width: 2),
///   child: Image.asset('assets/earth.png', fit: BoxFit.cover),
/// )
/// ```
///
/// Sizing: pass [size] when the parent provides unbounded constraints, or
/// rely on the parent's bounded constraints. The widget does not auto-fit
/// the shape — geometry coordinates must already match the rendered widget
/// space (or be transformed via [mapper]).
class ShapeWidget extends StatelessWidget {
  /// Shape used both for outline rendering and for clipping [child].
  final geo.Shape shape;

  /// Optional explicit size. When null, the widget expands to its parent's
  /// constraints; the parent must therefore be bounded.
  final Size? size;

  /// Maps shape coordinates to canvas coordinates. Defaults to
  /// [CoordinateMapper.identity].
  final CoordinateMapper mapper;

  /// Optional fill / stroke paint. When null, only [child] is rendered
  /// (clipped). When set, the outline draws above [child].
  final ShapeStyle? style;

  /// Optional widget rendered behind the outline, clipped to [shape].
  final Widget? child;

  /// Clip behavior forwarded to the underlying [ClipPath]. Default
  /// [Clip.antiAlias] for smooth edges.
  final Clip clipBehavior;

  /// Creates a shape host widget.
  const ShapeWidget({
    super.key,
    required this.shape,
    this.size,
    this.mapper = CoordinateMapper.identity,
    this.style,
    this.child,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final clipper = ShapeClipper(shape: shape, mapper: mapper);
    final layered = Stack(
      fit: StackFit.expand,
      children: [
        if (child != null)
          ClipPath(
            clipper: clipper,
            clipBehavior: clipBehavior,
            child: child,
          ),
        if (style != null && style!.isVisible)
          CustomPaint(
            painter: _ShapeOverlayPainter(shape, mapper, style!),
          ),
      ],
    );
    if (size != null) {
      return SizedBox.fromSize(size: size, child: layered);
    }
    return layered;
  }
}

class _ShapeOverlayPainter extends CustomPainter {
  final geo.Shape shape;
  final CoordinateMapper mapper;
  final ShapeStyle style;

  const _ShapeOverlayPainter(this.shape, this.mapper, this.style);

  @override
  void paint(Canvas canvas, Size size) {
    paintShapePath(canvas, shapeToPath(shape, mapper), style);
  }

  @override
  bool shouldRepaint(covariant _ShapeOverlayPainter old) =>
      old.shape != shape || old.mapper != mapper || old.style != style;
}
