import 'package:flutter/material.dart';

import 'dash_pattern.dart';

/// Visual style applied to a shape widget.
///
/// Bundles fill, stroke, opacity, dash pattern, and stroke decoration into a
/// single value-equality object so widgets can pass styling as one parameter.
///
/// ```dart
/// const ShapeStyle();                              // black 1px stroke
/// const ShapeStyle.filled(Colors.blue);            // solid blue fill
/// const ShapeStyle.stroked(Colors.red, width: 3);  // 3px red stroke
/// ```
@immutable
class ShapeStyle {
  /// Fill color. `null` means no fill (transparent interior).
  final Color? fillColor;

  /// Stroke (outline) color. `null` means no stroke.
  final Color? strokeColor;

  /// Stroke width in logical pixels.
  final double strokeWidth;

  /// Opacity applied to fill and stroke (0.0–1.0).
  final double opacity;

  /// Optional dash pattern for the stroke.
  final DashPattern? dashPattern;

  /// Stroke cap style.
  final StrokeCap strokeCap;

  /// Stroke join style.
  final StrokeJoin strokeJoin;

  /// Creates a shape style.
  const ShapeStyle({
    this.fillColor,
    this.strokeColor = const Color(0xFF000000),
    this.strokeWidth = 1.0,
    this.opacity = 1.0,
    this.dashPattern,
    this.strokeCap = StrokeCap.butt,
    this.strokeJoin = StrokeJoin.miter,
  });

  /// A solid-fill style with no stroke.
  const ShapeStyle.filled(Color color)
      : fillColor = color,
        strokeColor = null,
        strokeWidth = 0,
        opacity = 1.0,
        dashPattern = null,
        strokeCap = StrokeCap.butt,
        strokeJoin = StrokeJoin.miter;

  /// A stroke-only style with no fill.
  const ShapeStyle.stroked(Color color, {double width = 1.0})
      : fillColor = null,
        strokeColor = color,
        strokeWidth = width,
        opacity = 1.0,
        dashPattern = null,
        strokeCap = StrokeCap.butt,
        strokeJoin = StrokeJoin.miter;

  /// Returns a copy of this style with the given fields replaced.
  ShapeStyle copyWith({
    Color? fillColor,
    Color? strokeColor,
    double? strokeWidth,
    double? opacity,
    DashPattern? dashPattern,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
  }) {
    return ShapeStyle(
      fillColor: fillColor ?? this.fillColor,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      opacity: opacity ?? this.opacity,
      dashPattern: dashPattern ?? this.dashPattern,
      strokeCap: strokeCap ?? this.strokeCap,
      strokeJoin: strokeJoin ?? this.strokeJoin,
    );
  }

  /// Whether this style would draw any pixels.
  bool get isVisible =>
      (fillColor != null) || (strokeColor != null && strokeWidth > 0);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShapeStyle &&
        other.fillColor == fillColor &&
        other.strokeColor == strokeColor &&
        other.strokeWidth == strokeWidth &&
        other.opacity == opacity &&
        other.dashPattern == dashPattern &&
        other.strokeCap == strokeCap &&
        other.strokeJoin == strokeJoin;
  }

  @override
  int get hashCode => Object.hash(
        fillColor,
        strokeColor,
        strokeWidth,
        opacity,
        dashPattern,
        strokeCap,
        strokeJoin,
      );
}
