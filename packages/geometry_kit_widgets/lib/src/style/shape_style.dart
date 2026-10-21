import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'dash_pattern.dart';

/// Mutates or replaces the [base] [Paint] resolved from [ShapeStyle] before
/// it is used to draw a shape.
///
/// Receives the axis-aligned bounding rect of the shape being painted so the
/// builder can configure size-aware effects (e.g. `MaskFilter.blur` whose
/// sigma scales with the shape, or `ImageShader` whose matrix maps onto the
/// bounds).
///
/// Return either the mutated [base] or a fresh [Paint] — whichever is more
/// convenient. Used as an escape hatch for advanced Skia features
/// (`maskFilter`, `imageFilter`, `blendMode`, custom shaders) without
/// expanding [ShapeStyle]'s primary surface for every use case.
typedef PaintBuilder = Paint Function(Paint base, Rect bounds);

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
///
/// Gradients win over solid colors when both are set on the same channel:
/// `fillGradient` overrides `fillColor`, `strokeGradient` overrides
/// `strokeColor`. `opacity` only applies to solid colors — encode alpha
/// directly into gradient color stops.
///
/// All fields are nullable. The default constructor still bakes in concrete
/// values (`strokeWidth: 1.0`, `opacity: 1.0`, `strokeCap: StrokeCap.butt`,
/// `strokeJoin: StrokeJoin.miter`) for ergonomic single-shape usage. To build
/// a *partial* override that inherits siblings from a parent
/// [ShapeStyleTheme], pass `null` explicitly per field. The theme's
/// [ShapeStyleTheme.resolve] runs `explicit.merge(ambient)` so nulls in the
/// override fall back to the theme's values. Painters fall back to the
/// constructor defaults at paint time when both override and theme leave a
/// scalar field null.
@immutable
class ShapeStyle {
  /// Fill color. `null` means no fill (transparent interior).
  ///
  /// Ignored when [fillGradient] is set.
  final Color? fillColor;

  /// Fill gradient. Wins over [fillColor] when both are non-null.
  ///
  /// Resolved against the painted shape's axis-aligned bounding rect at
  /// paint time. `opacity` does not apply — encode alpha into gradient stops.
  final Gradient? fillGradient;

  /// Stroke (outline) color. `null` means no stroke.
  ///
  /// Ignored when [strokeGradient] is set.
  final Color? strokeColor;

  /// Stroke gradient. Wins over [strokeColor] when both are non-null.
  ///
  /// Not supported on `GeoLine` (zero-area bounds make resolution
  /// degenerate); the line painter ignores this field.
  final Gradient? strokeGradient;

  /// Stroke width in logical pixels. `null` means "inherit" — painters fall
  /// back to `1.0` if no theme provides a value.
  final double? strokeWidth;

  /// Opacity applied to solid fill / stroke colors (0.0–1.0). `null` means
  /// "inherit"; painters fall back to `1.0`.
  ///
  /// Has no effect on gradients — encode alpha into gradient color stops.
  final double? opacity;

  /// Optional dash pattern for the stroke.
  final DashPattern? dashPattern;

  /// Stroke cap style. `null` means "inherit"; painters fall back to
  /// [StrokeCap.butt].
  final StrokeCap? strokeCap;

  /// Stroke join style. `null` means "inherit"; painters fall back to
  /// [StrokeJoin.miter].
  final StrokeJoin? strokeJoin;

  /// Optional escape hatch invoked after the fill [Paint] is resolved.
  ///
  /// Lets callers attach `maskFilter`, `imageFilter`, `blendMode`, or any
  /// other Skia configuration that [ShapeStyle] does not surface directly.
  /// Equality of this field is by function identity, so prefer top-level or
  /// `static` builders when value-equality matters for widget rebuilds.
  final PaintBuilder? fillPaintBuilder;

  /// Optional escape hatch invoked after the stroke [Paint] is resolved.
  ///
  /// Same semantics as [fillPaintBuilder]. Not invoked by `GeoLine`'s
  /// painter when [strokeGradient] is asserted off — but does run for solid
  /// strokes, so blur/glow on lines is supported through this hook.
  final PaintBuilder? strokePaintBuilder;

  /// Creates a shape style.
  ///
  /// Scalar fields default to concrete values (`strokeWidth: 1.0`,
  /// `opacity: 1.0`, `strokeCap: StrokeCap.butt`, `strokeJoin: StrokeJoin.miter`).
  /// Pass `null` explicitly to mark a field as "inherit from
  /// [ShapeStyleTheme]".
  const ShapeStyle({
    this.fillColor,
    this.fillGradient,
    this.strokeColor = const Color(0xFF000000),
    this.strokeGradient,
    this.strokeWidth = 1.0,
    this.opacity = 1.0,
    this.dashPattern,
    this.strokeCap = StrokeCap.butt,
    this.strokeJoin = StrokeJoin.miter,
    this.fillPaintBuilder,
    this.strokePaintBuilder,
  });

  /// A solid-fill style with no stroke.
  const ShapeStyle.filled(Color color)
      : fillColor = color,
        fillGradient = null,
        strokeColor = null,
        strokeGradient = null,
        strokeWidth = 0,
        opacity = 1.0,
        dashPattern = null,
        strokeCap = StrokeCap.butt,
        strokeJoin = StrokeJoin.miter,
        fillPaintBuilder = null,
        strokePaintBuilder = null;

  /// A gradient-fill style with no stroke.
  const ShapeStyle.gradientFilled(Gradient gradient)
      : fillColor = null,
        fillGradient = gradient,
        strokeColor = null,
        strokeGradient = null,
        strokeWidth = 0,
        opacity = 1.0,
        dashPattern = null,
        strokeCap = StrokeCap.butt,
        strokeJoin = StrokeJoin.miter,
        fillPaintBuilder = null,
        strokePaintBuilder = null;

  /// A stroke-only style with no fill.
  const ShapeStyle.stroked(Color color, {double width = 1.0})
      : fillColor = null,
        fillGradient = null,
        strokeColor = color,
        strokeGradient = null,
        strokeWidth = width,
        opacity = 1.0,
        dashPattern = null,
        strokeCap = StrokeCap.butt,
        strokeJoin = StrokeJoin.miter,
        fillPaintBuilder = null,
        strokePaintBuilder = null;

  /// Returns a copy of this style with the given fields replaced.
  ///
  /// Cannot transition a field *to* null (the `?? this.field` pattern blocks
  /// it). Use the raw constructor when you need to write `null` into a
  /// previously non-null field.
  ShapeStyle copyWith({
    Color? fillColor,
    Gradient? fillGradient,
    Color? strokeColor,
    Gradient? strokeGradient,
    double? strokeWidth,
    double? opacity,
    DashPattern? dashPattern,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
    PaintBuilder? fillPaintBuilder,
    PaintBuilder? strokePaintBuilder,
  }) {
    return ShapeStyle(
      fillColor: fillColor ?? this.fillColor,
      fillGradient: fillGradient ?? this.fillGradient,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeGradient: strokeGradient ?? this.strokeGradient,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      opacity: opacity ?? this.opacity,
      dashPattern: dashPattern ?? this.dashPattern,
      strokeCap: strokeCap ?? this.strokeCap,
      strokeJoin: strokeJoin ?? this.strokeJoin,
      fillPaintBuilder: fillPaintBuilder ?? this.fillPaintBuilder,
      strokePaintBuilder: strokePaintBuilder ?? this.strokePaintBuilder,
    );
  }

  /// Returns a new style where each null field falls back to the matching
  /// field on [base]. Used by [ShapeStyleTheme.resolve] to combine an
  /// ambient theme with an explicit per-widget override.
  ///
  /// Returns `this` unchanged when [base] is null.
  ShapeStyle merge(ShapeStyle? base) {
    if (base == null) return this;
    return ShapeStyle(
      fillColor: fillColor ?? base.fillColor,
      fillGradient: fillGradient ?? base.fillGradient,
      strokeColor: strokeColor ?? base.strokeColor,
      strokeGradient: strokeGradient ?? base.strokeGradient,
      strokeWidth: strokeWidth ?? base.strokeWidth,
      opacity: opacity ?? base.opacity,
      dashPattern: dashPattern ?? base.dashPattern,
      strokeCap: strokeCap ?? base.strokeCap,
      strokeJoin: strokeJoin ?? base.strokeJoin,
      fillPaintBuilder: fillPaintBuilder ?? base.fillPaintBuilder,
      strokePaintBuilder: strokePaintBuilder ?? base.strokePaintBuilder,
    );
  }

  /// Linearly interpolates between two styles.
  ///
  /// - `Color` fields use [Color.lerp].
  /// - `double` scalars (`strokeWidth`, `opacity`) use `lerpDouble` with
  ///   constructor defaults filling nulls (`1.0`).
  /// - Gradients, dash patterns, enum fields, and `PaintBuilder`s do **not**
  ///   smoothly interpolate — they snap at `t >= 0.5`. Heterogeneous
  ///   gradient subtypes make smooth interpolation impractical.
  ///
  /// Returns `null` when both inputs are null. Returns the non-null side
  /// unchanged when only one input is null.
  static ShapeStyle? lerp(ShapeStyle? a, ShapeStyle? b, double t) {
    if (identical(a, b)) return a;
    if (a == null) return b;
    if (b == null) return a;
    final pickB = t >= 0.5;
    return ShapeStyle(
      fillColor: Color.lerp(a.fillColor, b.fillColor, t),
      fillGradient: pickB ? b.fillGradient : a.fillGradient,
      strokeColor: Color.lerp(a.strokeColor, b.strokeColor, t),
      strokeGradient: pickB ? b.strokeGradient : a.strokeGradient,
      strokeWidth:
          lerpDouble(a.strokeWidth ?? 1.0, b.strokeWidth ?? 1.0, t),
      opacity: lerpDouble(a.opacity ?? 1.0, b.opacity ?? 1.0, t),
      dashPattern: pickB ? b.dashPattern : a.dashPattern,
      strokeCap: pickB ? b.strokeCap : a.strokeCap,
      strokeJoin: pickB ? b.strokeJoin : a.strokeJoin,
      fillPaintBuilder: pickB ? b.fillPaintBuilder : a.fillPaintBuilder,
      strokePaintBuilder:
          pickB ? b.strokePaintBuilder : a.strokePaintBuilder,
    );
  }

  /// Whether this style would draw any pixels.
  ///
  /// A `PaintBuilder` alone is not enough — it needs at least a `Color` or
  /// `Gradient` to attach to, otherwise no source pixels exist for it to
  /// modify.
  bool get isVisible {
    final hasFill = fillGradient != null || fillColor != null;
    final width = strokeWidth ?? 1.0;
    final hasStroke =
        (strokeGradient != null || strokeColor != null) && width > 0;
    return hasFill || hasStroke;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShapeStyle &&
        other.fillColor == fillColor &&
        other.fillGradient == fillGradient &&
        other.strokeColor == strokeColor &&
        other.strokeGradient == strokeGradient &&
        other.strokeWidth == strokeWidth &&
        other.opacity == opacity &&
        other.dashPattern == dashPattern &&
        other.strokeCap == strokeCap &&
        other.strokeJoin == strokeJoin &&
        other.fillPaintBuilder == fillPaintBuilder &&
        other.strokePaintBuilder == strokePaintBuilder;
  }

  @override
  int get hashCode => Object.hash(
        fillColor,
        fillGradient,
        strokeColor,
        strokeGradient,
        strokeWidth,
        opacity,
        dashPattern,
        strokeCap,
        strokeJoin,
        fillPaintBuilder,
        strokePaintBuilder,
      );
}

/// A [Tween] for animating between two [ShapeStyle]s.
///
/// Drives [ShapeStyle.lerp] on each frame. Use with
/// [AnimationController.drive] or inside an [AnimatedShapeStyle].
class ShapeStyleTween extends Tween<ShapeStyle?> {
  /// Creates a tween that interpolates between [begin] and [end].
  ShapeStyleTween({super.begin, super.end});

  @override
  ShapeStyle? lerp(double t) => ShapeStyle.lerp(begin, end, t);
}
