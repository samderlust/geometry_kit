import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../coord/coordinate_mapper.dart';

/// Internal helper that wires shape-precise tap, hover and drag callbacks
/// onto a child widget.
///
/// Hit-test uses [hitTest] on the local pointer position, at the render
/// level: a pointer outside the shape does not hit this widget at all, even
/// inside the host widget rect, so it reaches whatever is behind — another
/// shape in a `Stack`, or an enclosing scroll view. Hover transitions fire
/// `onHoverChanged` when the pointer crosses the shape boundary.
///
/// Drag follows a preview-then-commit model: while a drag that started on
/// the shape is in flight, [builder] receives the accumulated canvas-space
/// offset so the host can draw the shape displaced (no geometry is rebuilt
/// per frame). [onDragEnd] reports the total in geometry space and the
/// preview offset resets to zero, so the owner commits the move by
/// translating its geometry there.
///
/// Not part of the public API. `Geo*` widgets use it internally; consumers
/// pass the callbacks to those widgets directly.
class ShapePointerRegion extends StatefulWidget {
  /// Tests a local (canvas-space) position against the shape at rest.
  /// Called per pointer event so callers may depend on transient state.
  final bool Function(Offset position) hitTest;

  /// Converts drag deltas to geometry space.
  final CoordinateMapper mapper;

  /// Fires when the pointer is released inside the shape.
  final VoidCallback? onTap;

  /// Fires with `true` when the pointer enters the shape, and with `false`
  /// when it leaves (or the pointer exits the host widget entirely).
  final ValueChanged<bool>? onHoverChanged;

  /// Fires when a drag that started on the shape begins.
  final VoidCallback? onDragStart;

  /// Fires per drag frame with the delta in geometry space.
  final ValueChanged<Offset>? onDragUpdate;

  /// Fires when the drag ends with the total displacement in geometry
  /// space.
  final ValueChanged<Offset>? onDragEnd;

  /// Builds the subtree; receives the in-flight drag offset (canvas space).
  final Widget Function(BuildContext context, Offset dragOffset) builder;

  /// Creates a shape-precise pointer region.
  const ShapePointerRegion({
    super.key,
    required this.hitTest,
    this.mapper = CoordinateMapper.identity,
    this.onTap,
    this.onHoverChanged,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    required this.builder,
  });

  /// Whether any drag callback is set.
  bool get draggable =>
      onDragStart != null || onDragUpdate != null || onDragEnd != null;

  @override
  State<ShapePointerRegion> createState() => _ShapePointerRegionState();
}

class _ShapePointerRegionState extends State<ShapePointerRegion> {
  bool _inside = false;
  bool _downOnShape = false;
  bool _dragging = false;
  Offset _dragOffset = Offset.zero;

  bool _hit(Offset position) => widget.hitTest(position - _dragOffset);

  void _setInside(bool value) {
    if (value == _inside) return;
    _inside = value;
    widget.onHoverChanged?.call(value);
  }

  void _endDrag({required bool commit}) {
    if (!_dragging) return;
    final total = widget.mapper.vectorFromCanvas(_dragOffset);
    setState(() {
      _dragging = false;
      _dragOffset = Offset.zero;
    });
    if (commit) widget.onDragEnd?.call(total);
  }

  @override
  void didUpdateWidget(covariant ShapePointerRegion old) {
    super.didUpdateWidget(old);
    // If callbacks were cleared mid-flight, drop the cached state so we
    // don't fire a stale exit event later.
    if (widget.onHoverChanged == null) _inside = false;
    if (!widget.draggable && _dragging) {
      _dragging = false;
      _dragOffset = Offset.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasTap = widget.onTap != null;
    final hasHover = widget.onHoverChanged != null;
    final hasDrag = widget.draggable;

    Widget tree = widget.builder(context, _dragOffset);
    if (!hasTap && !hasHover && !hasDrag) return tree;

    if (hasHover) {
      // Listener handles stylus / touch hover; MouseRegion handles mouse.
      tree = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerHover: (event) {
          if (event.kind == PointerDeviceKind.mouse) return; // handled above
          _setInside(_hit(event.localPosition));
        },
        child: tree,
      );
      tree = MouseRegion(
        opaque: false,
        onHover: (event) {
          if (_dragging) return;
          _setInside(_hit(event.localPosition));
        },
        onExit: (_) => _setInside(false),
        child: tree,
      );
    }
    if (hasTap || hasDrag) {
      tree = ShapeGestureDetector(
        onTapUp: hasTap
            ? (details) {
                if (_hit(details.localPosition)) widget.onTap!.call();
              }
            : null,
        onPanDown: hasDrag
            ? (details) => _downOnShape = _hit(details.localPosition)
            : null,
        onPanStart: hasDrag
            ? (_) {
                if (!_downOnShape) return;
                _dragging = true;
                widget.onDragStart?.call();
              }
            : null,
        onPanUpdate: hasDrag
            ? (details) {
                if (!_dragging) return;
                setState(() => _dragOffset += details.delta);
                widget.onDragUpdate?.call(
                  widget.mapper.vectorFromCanvas(details.delta),
                );
              }
            : null,
        onPanEnd: hasDrag ? (_) => _endDrag(commit: true) : null,
        onPanCancel: hasDrag ? () => _endDrag(commit: false) : null,
        child: tree,
      );
    }
    return ShapeHitFilter(hitTest: _hit, child: tree);
  }
}

/// Lets a pointer hit [child] only where [hitTest] accepts the local
/// position, so events off the shape fall through to widgets behind.
///
/// Not part of the public API.
class ShapeHitFilter extends SingleChildRenderObjectWidget {
  /// Tests a local position.
  final bool Function(Offset position) hitTest;

  /// Creates a filter around [child].
  const ShapeHitFilter({super.key, required this.hitTest, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderShapeHitFilter(hitTest);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderShapeHitFilter renderObject,
  ) {
    renderObject.test = hitTest;
  }
}

/// Render object behind [ShapeHitFilter].
class RenderShapeHitFilter extends RenderProxyBox {
  /// Current hit test.
  bool Function(Offset position) test;

  /// Creates the render object.
  RenderShapeHitFilter(this.test);

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!size.contains(position) || !test(position)) return false;
    return super.hitTest(result, position: position);
  }
}

/// Tap + pan detector for shapes. Not part of the public API.
///
/// The pan uses [ShapeDragGestureRecognizer], which accepts after half the
/// touch slop — sooner than a scroll view's drag recognizer — so a drag
/// that starts on a shape moves the shape instead of scrolling an
/// enclosing list. [ShapeHitFilter] keeps pointers off the shape from
/// reaching this detector, so scrolling still works around the shape.
class ShapeGestureDetector extends StatelessWidget {
  /// See [TapGestureRecognizer.onTapUp].
  final GestureTapUpCallback? onTapUp;

  /// See [DragGestureRecognizer.onDown].
  final GestureDragDownCallback? onPanDown;

  /// See [DragGestureRecognizer.onStart].
  final GestureDragStartCallback? onPanStart;

  /// See [DragGestureRecognizer.onUpdate].
  final GestureDragUpdateCallback? onPanUpdate;

  /// See [DragGestureRecognizer.onEnd].
  final GestureDragEndCallback? onPanEnd;

  /// See [DragGestureRecognizer.onCancel].
  final GestureDragCancelCallback? onPanCancel;

  /// Subtree receiving the gestures.
  final Widget child;

  /// Creates a shape gesture detector.
  const ShapeGestureDetector({
    super.key,
    this.onTapUp,
    this.onPanDown,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final hasPan =
        onPanDown != null ||
        onPanStart != null ||
        onPanUpdate != null ||
        onPanEnd != null;
    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: {
        if (onTapUp != null)
          TapGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                () => TapGestureRecognizer(debugOwner: this),
                (r) => r.onTapUp = onTapUp,
              ),
        if (hasPan)
          ShapeDragGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<ShapeDragGestureRecognizer>(
                // Track from the touch-down point so the shape stays under
                // the finger instead of trailing it by the slop.
                () =>
                    ShapeDragGestureRecognizer(debugOwner: this)
                      ..dragStartBehavior = DragStartBehavior.down,
                (r) => r
                  ..onDown = onPanDown
                  ..onStart = onPanStart
                  ..onUpdate = onPanUpdate
                  ..onEnd = onPanEnd
                  ..onCancel = onPanCancel,
              ),
      },
      child: child,
    );
  }
}

/// A [PanGestureRecognizer] that accepts after half the touch slop, ahead
/// of scroll views' drag recognizers. Not part of the public API.
class ShapeDragGestureRecognizer extends PanGestureRecognizer {
  /// Creates the recognizer.
  ShapeDragGestureRecognizer({super.debugOwner});

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) =>
      globalDistanceMoved.abs() >
      computeHitSlop(pointerDeviceKind, gestureSettings) / 2;
}
