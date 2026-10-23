import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../coord/coordinate_mapper.dart';
import '../debug/geo_debug_overlay.dart';
import '../painters/geometry_painter.dart';
import '../util/shape_hit_test.dart';
import '../widgets/shape_pointer_region.dart';
import 'geo_grid.dart';
import 'styled_shape.dart';

/// Renders an arbitrary list of [StyledShape]s onto a single canvas.
///
/// Per-shape `onTap`, `onHoverChanged` and drag callbacks dispatch
/// top-down: the topmost interactive shape under the pointer wins, and
/// shapes painted earlier (visually below) do not see the event. Closed
/// shapes hit by containment; open curves (lines, arcs, Beziers, splines,
/// polylines, rays) hit within half their stroke width plus a few pixels.
///
/// Pointers that miss every interactive shape are not hit at all and reach
/// whatever is behind the canvas.
///
/// Dragging a shape draws it displaced by the pointer until the drag ends;
/// `StyledShape.onDragEnd` then reports the total so the owner can replace
/// the shape with a translated copy.
///
/// [grid] paints grid lines and axes under the shapes; [debugOverlay]
/// draws authoring aids over every shape (a shape's own
/// `StyledShape.debugOverlay` wins).
///
/// ```dart
/// GeometryCanvas(
///   size: const Size(400, 300),
///   shapes: [
///     StyledShape(
///       Circle(center: Point(100, 100), radius: 50),
///       style: ShapeStyle.filled(Colors.blue),
///       onTap: () => print('blue'),
///     ),
///   ],
/// )
/// ```
class GeometryCanvas extends StatefulWidget {
  /// Logical size of the canvas.
  final Size size;

  /// Shapes to paint, in paint order (first = bottom).
  final List<StyledShape> shapes;

  /// Coordinate mapper applied to every shape.
  final CoordinateMapper mapper;

  /// Background color painted before any shape.
  ///
  /// `null` (default) leaves the canvas transparent so widgets stacked
  /// underneath remain visible.
  final Color? backgroundColor;

  /// How content drawn outside [size] is clipped.
  ///
  /// Defaults to [Clip.hardEdge] so shapes never bleed onto neighboring
  /// widgets. Set to [Clip.none] to allow overflow.
  final Clip clipBehavior;

  /// Optional grid lines and axes, painted over [backgroundColor] and under
  /// the shapes.
  final GeoGrid? grid;

  /// Authoring aids drawn over every shape that has no
  /// `StyledShape.debugOverlay` of its own.
  final GeoDebugOverlay? debugOverlay;

  /// Creates a multi-shape canvas.
  const GeometryCanvas({
    super.key,
    required this.size,
    required this.shapes,
    this.mapper = CoordinateMapper.identity,
    this.backgroundColor,
    this.clipBehavior = Clip.hardEdge,
    this.grid,
    this.debugOverlay,
  });

  @override
  State<GeometryCanvas> createState() => _GeometryCanvasState();
}

class _GeometryCanvasState extends State<GeometryCanvas> {
  StyledShape? _hovered;

  /// Shape under the last pan-down, when it is draggable.
  (int, StyledShape)? _pressed;

  /// Shape being dragged, by paint index, and its callbacks.
  (int, StyledShape)? _dragging;
  Offset _dragOffset = Offset.zero;

  bool get _hasInteraction => widget.shapes.any((s) => s.isInteractive);

  bool get _hasDrag => widget.shapes.any((s) => s.isDraggable);

  (int, StyledShape)? _topShapeAt(Offset position) {
    for (var i = widget.shapes.length - 1; i >= 0; i--) {
      final s = widget.shapes[i];
      if (!s.isInteractive) continue;
      try {
        if (hitTestShape(
          s.shape,
          widget.mapper,
          position,
          tolerance: curveHitTolerance(s.style),
          size: widget.size,
        )) {
          return (i, s);
        }
      } on UnsupportedError {
        continue;
      }
    }
    return null;
  }

  void _setHovered(StyledShape? next) {
    if (identical(next, _hovered)) return;
    _hovered?.onHoverChanged?.call(false);
    _hovered = next;
    next?.onHoverChanged?.call(true);
  }

  void _onPointerHover(Offset position) {
    if (_dragging != null) return;
    _setHovered(_topShapeAt(position)?.$2);
  }

  void _onTapUp(TapUpDetails details) {
    _topShapeAt(details.localPosition)?.$2.onTap?.call();
  }

  void _onPanDown(DragDownDetails details) {
    final hit = _topShapeAt(details.localPosition);
    _pressed = hit != null && hit.$2.isDraggable ? hit : null;
  }

  void _onPanStart(DragStartDetails details) {
    final pressed = _pressed;
    if (pressed == null) return;
    setState(() {
      _dragging = pressed;
      _dragOffset = Offset.zero;
    });
    pressed.$2.onDragStart?.call();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final dragging = _dragging;
    if (dragging == null) return;
    setState(() => _dragOffset += details.delta);
    dragging.$2.onDragUpdate?.call(
      widget.mapper.vectorFromCanvas(details.delta),
    );
  }

  void _onPanEnd(DragEndDetails details) {
    final dragging = _dragging;
    if (dragging == null) return;
    final total = widget.mapper.vectorFromCanvas(_dragOffset);
    setState(() {
      _dragging = null;
      _pressed = null;
      _dragOffset = Offset.zero;
    });
    dragging.$2.onDragEnd?.call(total);
  }

  @override
  void didUpdateWidget(covariant GeometryCanvas old) {
    super.didUpdateWidget(old);
    if (!_hasInteraction && _hovered != null) {
      _hovered?.onHoverChanged?.call(false);
      _hovered = null;
    }
    final dragging = _dragging;
    if (dragging != null && dragging.$1 >= widget.shapes.length) {
      _dragging = null;
      _dragOffset = Offset.zero;
    }
  }

  @override
  void dispose() {
    _hovered?.onHoverChanged?.call(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget paint = CustomPaint(
      size: widget.size,
      painter: _GeometryCanvasPainter(
        shapes: widget.shapes,
        mapper: widget.mapper,
        backgroundColor: widget.backgroundColor,
        grid: widget.grid,
        debugOverlay: widget.debugOverlay,
        dragIndex: _dragging?.$1,
        dragOffset: _dragOffset,
      ),
    );
    if (widget.clipBehavior != Clip.none) {
      paint = ClipRect(clipBehavior: widget.clipBehavior, child: paint);
    }
    paint = RepaintBoundary(child: paint);
    if (!_hasInteraction) return paint;

    final hasDrag = _hasDrag;
    // Only interactive shapes take the pointer; elsewhere it falls through
    // to widgets behind the canvas (or an enclosing scroll view).
    return ShapeHitFilter(
      hitTest: (p) => _topShapeAt(p) != null,
      child: MouseRegion(
        opaque: false,
        onHover: (e) => _onPointerHover(e.localPosition),
        onExit: (_) => _setHovered(null),
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerHover: (e) {
            if (e.kind == PointerDeviceKind.mouse) return;
            _onPointerHover(e.localPosition);
          },
          child: ShapeGestureDetector(
            onTapUp: _onTapUp,
            onPanDown: hasDrag ? _onPanDown : null,
            onPanStart: hasDrag ? _onPanStart : null,
            onPanUpdate: hasDrag ? _onPanUpdate : null,
            onPanEnd: hasDrag ? _onPanEnd : null,
            child: paint,
          ),
        ),
      ),
    );
  }
}

class _GeometryCanvasPainter extends CustomPainter {
  final List<StyledShape> shapes;
  final CoordinateMapper mapper;
  final Color? backgroundColor;
  final GeoGrid? grid;
  final GeoDebugOverlay? debugOverlay;
  final int? dragIndex;
  final Offset dragOffset;

  const _GeometryCanvasPainter({
    required this.shapes,
    required this.mapper,
    this.backgroundColor,
    this.grid,
    this.debugOverlay,
    this.dragIndex,
    this.dragOffset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundColor != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = backgroundColor!,
      );
    }
    grid?.paint(canvas, size, mapper);
    for (var i = 0; i < shapes.length; i++) {
      final s = shapes[i];
      final dragged = i == dragIndex;
      if (dragged) {
        canvas
          ..save()
          ..translate(dragOffset.dx, dragOffset.dy);
      }
      try {
        paintGeometry(canvas, s.shape, s.style, mapper, size: size);
        final overlay = s.debugOverlay ?? debugOverlay;
        if (overlay != null) {
          paintDebugOverlay(canvas, s.shape, mapper, overlay, size: size);
        }
      } on UnsupportedError {
        // Unknown geometry types are skipped, loudly in debug builds.
        assert(() {
          debugPrint(
            'GeometryCanvas: no painter registered for ${s.shape.runtimeType}',
          );
          return true;
        }());
      }
      if (dragged) canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _GeometryCanvasPainter old) =>
      old.backgroundColor != backgroundColor ||
      old.mapper != mapper ||
      old.grid != grid ||
      old.debugOverlay != debugOverlay ||
      old.dragIndex != dragIndex ||
      old.dragOffset != dragOffset ||
      !_listEquals(old.shapes, shapes);
}

bool _listEquals(List<StyledShape> a, List<StyledShape> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
