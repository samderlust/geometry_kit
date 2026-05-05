import 'package:flutter/widgets.dart';

import 'shape_style.dart';

/// An [InheritedWidget] that supplies a default [ShapeStyle] to descendants.
///
/// Geometry widgets read the closest ancestor via [ShapeStyleTheme.of] when
/// no explicit `style` is provided. Useful for sharing a single style across
/// many shapes without repeating it on every widget.
///
/// ```dart
/// ShapeStyleTheme(
///   data: const ShapeStyle.stroked(Colors.indigo, width: 2),
///   child: Column(children: [
///     GeoCircle(radius: 30),     // inherits indigo stroke
///     GeoTriangle(...),          // inherits indigo stroke
///   ]),
/// )
/// ```
class ShapeStyleTheme extends InheritedWidget {
  /// The style applied to descendants that don't supply their own.
  final ShapeStyle data;

  /// Creates a theme that supplies [data] to its [child] subtree.
  const ShapeStyleTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// Returns the [ShapeStyle] from the closest [ShapeStyleTheme] ancestor,
  /// or `null` if none is present.
  static ShapeStyle? of(BuildContext context) {
    final theme =
        context.dependOnInheritedWidgetOfExactType<ShapeStyleTheme>();
    return theme?.data;
  }

  /// Returns the [ShapeStyle] from the closest ancestor, or [fallback] if
  /// none is present.
  static ShapeStyle resolve(BuildContext context, ShapeStyle fallback) {
    return of(context) ?? fallback;
  }

  @override
  bool updateShouldNotify(ShapeStyleTheme oldWidget) => oldWidget.data != data;
}
