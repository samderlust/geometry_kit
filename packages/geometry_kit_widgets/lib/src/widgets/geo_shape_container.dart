import 'package:flutter/widgets.dart';

/// Internal container that wraps a [CustomPaint] in [ClipRect],
/// [RepaintBoundary], and [Semantics] uniformly across `Geo*` widgets.
///
/// Not part of the public API.
class GeoShapeContainer extends StatelessWidget {
  final CustomPainter painter;
  final Size size;
  final Clip clipBehavior;
  final String? semanticLabel;

  const GeoShapeContainer({
    super.key,
    required this.painter,
    required this.size,
    required this.clipBehavior,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    Widget paint = CustomPaint(size: size, painter: painter);
    if (clipBehavior != Clip.none) {
      paint = ClipRect(clipBehavior: clipBehavior, child: paint);
    }
    return Semantics(
      label: semanticLabel,
      child: RepaintBoundary(child: paint),
    );
  }
}
