import 'package:flutter/widgets.dart';

import 'shape_pointer_region.dart';

/// Internal container that wraps a [CustomPaint] in [ClipRect],
/// [RepaintBoundary], and [Semantics] uniformly across `Geo*` widgets.
///
/// When [onTap] or [onHoverChanged] is provided alongside a non-null
/// [interactionPathBuilder], the container also wraps a
/// [ShapePointerRegion] for shape-precise tap/hover dispatch.
///
/// Not part of the public API.
class GeoShapeContainer extends StatelessWidget {
  final CustomPainter painter;
  final Size size;
  final Clip clipBehavior;
  final String? semanticLabel;
  final Path Function()? interactionPathBuilder;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onHoverChanged;

  const GeoShapeContainer({
    super.key,
    required this.painter,
    required this.size,
    required this.clipBehavior,
    required this.semanticLabel,
    this.interactionPathBuilder,
    this.onTap,
    this.onHoverChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget paint = CustomPaint(size: size, painter: painter);
    if (clipBehavior != Clip.none) {
      paint = ClipRect(clipBehavior: clipBehavior, child: paint);
    }
    Widget wrapped = Semantics(
      label: semanticLabel,
      child: RepaintBoundary(child: paint),
    );
    final hasInteraction = (onTap != null || onHoverChanged != null) &&
        interactionPathBuilder != null;
    if (hasInteraction) {
      wrapped = ShapePointerRegion(
        pathBuilder: interactionPathBuilder!,
        onTap: onTap,
        onHoverChanged: onHoverChanged,
        child: wrapped,
      );
    }
    return wrapped;
  }
}
