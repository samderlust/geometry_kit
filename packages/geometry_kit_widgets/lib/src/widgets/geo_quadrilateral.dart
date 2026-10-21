import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../painters/quadrilateral_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';
import '../util/shape_path.dart';
import 'geo_shape_container.dart';

/// A widget that paints a [Quadrilateral] from four ordered vertices.
///
/// Two constructors: [GeoQuadrilateral] from four `Offset`s, or
/// [GeoQuadrilateral.fromGeometry] from an existing [Quadrilateral]. Style
/// flows from [style], the closest [ShapeStyleTheme], or a default 1px
/// black stroke. [onTap] / [onHoverChanged] hit-test against the
/// quadrilateral path — taps in the widget rect but outside the four
/// edges are ignored.
class GeoQuadrilateral extends StatelessWidget {
  /// The geometry quadrilateral to paint.
  final Quadrilateral quad;

  /// Style override. When `null`, resolves through [ShapeStyleTheme].
  final ShapeStyle? style;

  /// Coordinate mapper. Defaults to [CoordinateMapper.identity].
  final CoordinateMapper mapper;

  /// Logical size of the widget.
  final Size size;

  /// How content extending past [size] is clipped.
  final Clip clipBehavior;

  /// Optional accessibility label.
  final String? semanticLabel;

  /// Fires when the pointer is released inside the shape outline.
  final VoidCallback? onTap;

  /// Fires with `true` on hover entry, `false` on exit.
  final ValueChanged<bool>? onHoverChanged;

  /// Creates a quadrilateral widget from four vertex offsets.
  GeoQuadrilateral({
    super.key,
    required Offset a,
    required Offset b,
    required Offset c,
    required Offset d,
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.size = const Size(200, 200),
    this.clipBehavior = Clip.hardEdge,
    this.semanticLabel,
    this.onTap,
    this.onHoverChanged,
  }) : quad = Quadrilateral(
         Point(a.dx, a.dy),
         Point(b.dx, b.dy),
         Point(c.dx, c.dy),
         Point(d.dx, d.dy),
       );

  /// Creates a quadrilateral widget from an existing [Quadrilateral].
  const GeoQuadrilateral.fromGeometry({
    super.key,
    required this.quad,
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.size = const Size(200, 200),
    this.clipBehavior = Clip.hardEdge,
    this.semanticLabel,
    this.onTap,
    this.onHoverChanged,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = ShapeStyleTheme.resolve(context, style);
    return GeoShapeContainer(
      size: size,
      clipBehavior: clipBehavior,
      semanticLabel: semanticLabel,
      interactionPathBuilder: () => shapeToPath(quad, mapper),
      onTap: onTap,
      onHoverChanged: onHoverChanged,
      painter: QuadrilateralPainter(
        quad: quad,
        style: resolved,
        mapper: mapper,
      ),
    );
  }
}
