import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../debug/geo_debug_overlay.dart';
import '../painters/line_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';
import '../util/shape_hit_test.dart';
import 'geo_shape_container.dart';

/// A widget that paints a [Line] segment between two points.
///
/// Lines have no interior, so the painter only strokes. If the supplied
/// [style] has no `strokeColor` it falls back to `fillColor`, then to
/// black. `strokeGradient` is not supported (zero-area bounds make
/// shader resolution degenerate); `strokePaintBuilder` still works for
/// blur / mask effects.
///
/// Two constructors: [GeoLine] from two `Offset`s, or
/// [GeoLine.fromGeometry] from an existing [Line]. Lines have no interior,
/// so [onTap] / [onHoverChanged] / drag hit when the pointer is within half
/// the stroke width plus a few pixels of the segment.
class GeoLine extends StatelessWidget {
  /// The geometry line to paint.
  final Line line;

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

  /// Fires when the pointer is released on the line.
  final VoidCallback? onTap;

  /// Fires with `true` when the pointer moves onto the line, `false` when it
  /// leaves.
  final ValueChanged<bool>? onHoverChanged;

  /// Fires when a drag that starts on the line begins.
  ///
  /// Setting any drag callback makes the line draggable. While the drag is
  /// in flight the widget draws the line displaced by the pointer.
  final VoidCallback? onDragStart;

  /// Fires per drag frame with the pointer delta in geometry space.
  /// Informational — do not also move the geometry here.
  final ValueChanged<Offset>? onDragUpdate;

  /// Fires when the drag ends with the total displacement in geometry
  /// space. Commit the move here by translating the geometry.
  final ValueChanged<Offset>? onDragEnd;

  /// Optional authoring aids drawn above the line.
  final GeoDebugOverlay? debugOverlay;

  /// Creates a line widget from two endpoint offsets.
  GeoLine({
    super.key,
    required Offset a,
    required Offset b,
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.size = const Size(200, 200),
    this.clipBehavior = Clip.hardEdge,
    this.semanticLabel,
    this.onTap,
    this.onHoverChanged,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.debugOverlay,
  }) : line = Line(Point(a.dx, a.dy), Point(b.dx, b.dy));

  /// Creates a line widget from an existing [Line] geometry.
  const GeoLine.fromGeometry({
    super.key,
    required this.line,
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.size = const Size(200, 200),
    this.clipBehavior = Clip.hardEdge,
    this.semanticLabel,
    this.onTap,
    this.onHoverChanged,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.debugOverlay,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = ShapeStyleTheme.resolve(context, style);
    return GeoShapeContainer(
      size: size,
      clipBehavior: clipBehavior,
      semanticLabel: semanticLabel,
      geometry: line,
      mapper: mapper,
      debugOverlay: debugOverlay,
      hitTolerance: curveHitTolerance(resolved),
      onTap: onTap,
      onHoverChanged: onHoverChanged,
      onDragStart: onDragStart,
      onDragUpdate: onDragUpdate,
      onDragEnd: onDragEnd,
      painter: LinePainter(line: line, style: resolved, mapper: mapper),
    );
  }
}
