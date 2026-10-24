import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart' show Geometry;

import '../coord/coordinate_mapper.dart';
import '../debug/geo_debug_overlay.dart';
import '../util/shape_hit_test.dart';
import 'shape_pointer_region.dart';

/// Internal container that wraps a [CustomPaint] in [ClipRect],
/// [RepaintBoundary], and [Semantics] uniformly across `Geo*` widgets.
///
/// - [debugOverlay] paints [GeoDebugOverlay] layers for [geometry] above
///   the shape.
/// - [onTap] / [onHoverChanged] / drag callbacks wrap a
///   [ShapePointerRegion]. Hits default to [hitTestShape] on [geometry]
///   (containment for closed shapes, distance within [hitTolerance] for
///   open curves); [hitTest] overrides that when the painted outline is
///   not [geometry]'s plain path (e.g. a rounded rectangle).
/// - While a drag is in flight the painted shape (and its overlay) is
///   translated by the drag offset inside the clip.
///
/// Not part of the public API.
class GeoShapeContainer extends StatelessWidget {
  final CustomPainter painter;
  final Size size;
  final Clip clipBehavior;
  final String? semanticLabel;
  final Geometry geometry;
  final CoordinateMapper mapper;
  final GeoDebugOverlay? debugOverlay;
  final bool Function(Offset position)? hitTest;
  final double hitTolerance;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onHoverChanged;
  final VoidCallback? onDragStart;
  final ValueChanged<Offset>? onDragUpdate;
  final ValueChanged<Offset>? onDragEnd;

  const GeoShapeContainer({
    super.key,
    required this.painter,
    required this.size,
    required this.clipBehavior,
    required this.semanticLabel,
    required this.geometry,
    required this.mapper,
    this.debugOverlay,
    this.hitTest,
    this.hitTolerance = kCurveHitSlop,
    this.onTap,
    this.onHoverChanged,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  bool get _draggable =>
      onDragStart != null || onDragUpdate != null || onDragEnd != null;

  Widget _paint(Offset dragOffset) {
    final overlay = debugOverlay;
    Widget paint = CustomPaint(
      size: size,
      painter: painter,
      foregroundPainter: overlay != null && overlay.isVisible
          ? GeoDebugOverlayPainter(
              shape: geometry,
              mapper: mapper,
              overlay: overlay,
            )
          : null,
    );
    if (_draggable) {
      paint = Transform.translate(offset: dragOffset, child: paint);
    }
    if (clipBehavior != Clip.none) {
      paint = ClipRect(clipBehavior: clipBehavior, child: paint);
    }
    return Semantics(
      label: semanticLabel,
      child: RepaintBoundary(child: paint),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasInteraction =
        onTap != null || onHoverChanged != null || _draggable;
    if (!hasInteraction) return _paint(Offset.zero);
    return ShapePointerRegion(
      hitTest:
          hitTest ??
          (p) => hitTestShape(
            geometry,
            mapper,
            p,
            tolerance: hitTolerance,
            size: size,
          ),
      mapper: mapper,
      onTap: onTap,
      onHoverChanged: onHoverChanged,
      onDragStart: onDragStart,
      onDragUpdate: onDragUpdate,
      onDragEnd: onDragEnd,
      builder: (_, dragOffset) => _paint(dragOffset),
    );
  }
}
