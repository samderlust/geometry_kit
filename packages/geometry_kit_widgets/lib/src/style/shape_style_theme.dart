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
///
/// Field-level merging: when a child supplies an explicit override,
/// [ShapeStyleTheme.resolve] runs `explicit.merge(ambient)`. Fields the child
/// leaves `null` fall back to the ambient theme's values. Because the
/// default [ShapeStyle] constructor bakes in concrete values for
/// `strokeWidth`, `opacity`, `strokeCap`, and `strokeJoin`, those fields
/// must be explicitly nulled in the override to inherit through.
class ShapeStyleTheme extends InheritedWidget {
  /// The style applied to descendants that don't supply their own.
  final ShapeStyle data;

  /// Creates a theme that supplies [data] to its [child] subtree.
  const ShapeStyleTheme({super.key, required this.data, required super.child});

  /// Returns the [ShapeStyle] from the closest [ShapeStyleTheme] ancestor,
  /// or `null` if none is present.
  static ShapeStyle? of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<ShapeStyleTheme>();
    return theme?.data;
  }

  /// Resolves the effective style for a widget.
  ///
  /// - When [explicit] is non-null, returns `explicit.merge(ambient)` — null
  ///   fields in the override fall back to the closest [ShapeStyleTheme].
  /// - When [explicit] is null, returns the closest theme's data, or
  ///   [fallback] (default `const ShapeStyle()`) if no theme is present.
  static ShapeStyle resolve(
    BuildContext context,
    ShapeStyle? explicit, {
    ShapeStyle fallback = const ShapeStyle(),
  }) {
    final ambient = of(context);
    if (explicit == null) return ambient ?? fallback;
    return explicit.merge(ambient);
  }

  @override
  bool updateShouldNotify(ShapeStyleTheme oldWidget) => oldWidget.data != data;
}
