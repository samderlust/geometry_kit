import 'package:flutter/rendering.dart';

import '../style/shape_style.dart';
import 'dashed_path.dart';

/// Renders [path] onto [canvas] using fill + stroke from [style].
///
/// Order: fill first, stroke second (stroke sits visually on top).
/// Honours [ShapeStyle.dashPattern] via [buildDashedPath].
///
/// Resolution rules:
/// - When `fillGradient` is set, it overrides `fillColor` and is resolved
///   against the path's axis-aligned bounding rect. Same for stroke.
/// - `opacity` does not modulate gradient shaders — alpha must be encoded
///   into gradient color stops directly.
/// - When `fillPaintBuilder` / `strokePaintBuilder` is set, it runs after
///   the base `Paint` is built and receives the same bounds. The returned
///   `Paint` is used for the actual draw call. Use it to attach
///   `maskFilter`, `imageFilter`, `blendMode`, custom shaders, etc.
/// - Nullable scalar fields (`strokeWidth`, `opacity`, `strokeCap`,
///   `strokeJoin`) fall back to the [ShapeStyle] constructor defaults
///   (`1.0`, `1.0`, `StrokeCap.butt`, `StrokeJoin.miter`) when null reaches
///   paint time.
void paintShapePath(Canvas canvas, Path path, ShapeStyle style) {
  final width = style.strokeWidth ?? 1.0;
  final opacity = style.opacity ?? 1.0;
  final cap = style.strokeCap ?? StrokeCap.butt;
  final join = style.strokeJoin ?? StrokeJoin.miter;

  final hasFill = style.fillGradient != null || style.fillColor != null;
  final hasStroke =
      (style.strokeGradient != null || style.strokeColor != null) && width > 0;
  if (!hasFill && !hasStroke) return;

  final needsBounds =
      style.fillGradient != null ||
      style.strokeGradient != null ||
      style.fillPaintBuilder != null ||
      style.strokePaintBuilder != null;
  final bounds = needsBounds ? path.getBounds() : Rect.zero;

  if (hasFill) {
    final fill = Paint()..style = PaintingStyle.fill;
    if (style.fillGradient != null) {
      fill.shader = style.fillGradient!.createShader(bounds);
    } else {
      fill.color = style.fillColor!.withValues(
        alpha: style.fillColor!.a * opacity,
      );
    }
    final resolved = style.fillPaintBuilder?.call(fill, bounds) ?? fill;
    canvas.drawPath(path, resolved);
  }

  if (hasStroke) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = cap
      ..strokeJoin = join;
    if (style.strokeGradient != null) {
      stroke.shader = style.strokeGradient!.createShader(bounds);
    } else {
      stroke.color = style.strokeColor!.withValues(
        alpha: style.strokeColor!.a * opacity,
      );
    }
    final resolved = style.strokePaintBuilder?.call(stroke, bounds) ?? stroke;
    final out = style.dashPattern != null
        ? buildDashedPath(path, style.dashPattern!)
        : path;
    canvas.drawPath(out, resolved);
  }
}

/// Strokes an open curve [path] (line, arc, Bezier, spline, polyline, ray).
///
/// Open curves have no interior, so nothing is filled: the stroke uses
/// `strokeGradient`, then `strokeColor`, then falls back to `fillColor`
/// (as `GeoLine` does) so a fill-only theme still shows the curve. A zero
/// or null `strokeWidth` draws a 1px hairline instead of nothing.
/// Honours [ShapeStyle.dashPattern] and [ShapeStyle.strokePaintBuilder].
void paintOpenPath(Canvas canvas, Path path, ShapeStyle style) {
  final color = style.strokeColor ?? style.fillColor;
  final gradient = style.strokeGradient;
  if (color == null && gradient == null) return;
  final rawWidth = style.strokeWidth ?? 1.0;
  final opacity = style.opacity ?? 1.0;

  final paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = rawWidth > 0 ? rawWidth : 1.0
    ..strokeCap = style.strokeCap ?? StrokeCap.butt
    ..strokeJoin = style.strokeJoin ?? StrokeJoin.miter;
  final needsBounds = gradient != null || style.strokePaintBuilder != null;
  final bounds = needsBounds ? path.getBounds() : Rect.zero;
  if (gradient != null) {
    paint.shader = gradient.createShader(bounds);
  } else {
    paint.color = color!.withValues(alpha: color.a * opacity);
  }
  final resolved = style.strokePaintBuilder?.call(paint, bounds) ?? paint;
  final out = style.dashPattern != null
      ? buildDashedPath(path, style.dashPattern!)
      : path;
  canvas.drawPath(out, resolved);
}
