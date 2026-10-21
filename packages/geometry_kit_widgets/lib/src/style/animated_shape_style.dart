import 'package:flutter/widgets.dart';

import 'shape_style.dart';
import 'shape_style_theme.dart';

/// Animates changes to a [ShapeStyle] and supplies the interpolated value to
/// descendants through a [ShapeStyleTheme].
///
/// Sibling of Flutter's `AnimatedDefaultTextStyle`. When [style] changes,
/// the new value is reached over [duration] using [curve]. Geometry widgets
/// in the subtree that read the theme (i.e. those without an explicit
/// `style` of their own, or with a partial style that leaves fields null)
/// pick up the interpolated values automatically.
///
/// ```dart
/// AnimatedShapeStyle(
///   style: highlighted ? hotStyle : coolStyle,
///   duration: const Duration(milliseconds: 250),
///   child: GeoCircle(radius: 30),
/// )
/// ```
///
/// Smoothly interpolates: `fillColor`, `strokeColor`, `strokeWidth`,
/// `opacity`. Snaps at the midpoint: gradients, dash patterns, enum fields,
/// and `PaintBuilder`s — see [ShapeStyle.lerp] for the full table.
class AnimatedShapeStyle extends ImplicitlyAnimatedWidget {
  /// The target style. Animated towards on change.
  final ShapeStyle style;

  /// Subtree that receives the interpolated style via [ShapeStyleTheme].
  final Widget child;

  /// Creates a widget that animates [style] changes over [duration].
  const AnimatedShapeStyle({
    super.key,
    required this.style,
    required this.child,
    super.curve,
    required super.duration,
    super.onEnd,
  });

  @override
  AnimatedWidgetBaseState<AnimatedShapeStyle> createState() =>
      _AnimatedShapeStyleState();
}

class _AnimatedShapeStyleState
    extends AnimatedWidgetBaseState<AnimatedShapeStyle> {
  ShapeStyleTween? _style;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _style = visitor(
      _style,
      widget.style,
      (dynamic value) => ShapeStyleTween(begin: value as ShapeStyle?),
    ) as ShapeStyleTween?;
  }

  @override
  Widget build(BuildContext context) {
    final value = _style?.evaluate(animation) ?? widget.style;
    return ShapeStyleTheme(
      data: value,
      child: widget.child,
    );
  }
}
