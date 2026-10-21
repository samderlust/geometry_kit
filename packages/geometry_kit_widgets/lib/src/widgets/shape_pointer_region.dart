import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Internal helper that wires shape-precise tap and hover callbacks onto a
/// child widget.
///
/// Hit-test uses `pathBuilder().contains(localPosition)` — pointer events
/// outside the path are ignored even when they land inside the host widget
/// rect. Hover transitions fire `onHoverChanged` when the pointer crosses
/// the path boundary.
///
/// Not part of the public API. `Geo*` widgets and `GeometryCanvas` use it
/// internally; consumers compose tap/hover by passing `onTap` and
/// `onHoverChanged` to those widgets directly.
class ShapePointerRegion extends StatefulWidget {
  /// Builds the canvas-space hit-test path on demand. Called per pointer
  /// event so callers may return a path that depends on transient state
  /// (e.g. corner radius) without invalidating an inherited shape.
  final Path Function() pathBuilder;

  /// Fires when the pointer is released inside the path.
  final VoidCallback? onTap;

  /// Fires with `true` when the pointer enters the path, and with `false`
  /// when it leaves (or the pointer exits the host widget entirely).
  final ValueChanged<bool>? onHoverChanged;

  /// Wrapped subtree. Receives all pointer events; this widget filters them.
  final Widget child;

  /// Creates a shape-precise pointer region.
  const ShapePointerRegion({
    super.key,
    required this.pathBuilder,
    this.onTap,
    this.onHoverChanged,
    required this.child,
  });

  @override
  State<ShapePointerRegion> createState() => _ShapePointerRegionState();
}

class _ShapePointerRegionState extends State<ShapePointerRegion> {
  bool _inside = false;

  Path _path() => widget.pathBuilder();

  void _setInside(bool value) {
    if (value == _inside) return;
    _inside = value;
    widget.onHoverChanged?.call(value);
  }

  @override
  void didUpdateWidget(covariant ShapePointerRegion old) {
    super.didUpdateWidget(old);
    // If callbacks were cleared mid-flight, drop the cached state so we
    // don't fire a stale exit event later.
    if (widget.onHoverChanged == null) _inside = false;
  }

  @override
  Widget build(BuildContext context) {
    final hasTap = widget.onTap != null;
    final hasHover = widget.onHoverChanged != null;
    if (!hasTap && !hasHover) return widget.child;

    Widget tree = widget.child;
    if (hasHover) {
      // Listener handles stylus / touch hover; MouseRegion handles mouse.
      tree = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerHover: (event) {
          if (event.kind == PointerDeviceKind.mouse) return; // handled above
          _setInside(_path().contains(event.localPosition));
        },
        child: tree,
      );
      tree = MouseRegion(
        opaque: false,
        onHover: (event) {
          _setInside(_path().contains(event.localPosition));
        },
        onExit: (_) => _setInside(false),
        child: tree,
      );
    }
    if (hasTap) {
      tree = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) {
          if (_path().contains(details.localPosition)) {
            widget.onTap!.call();
          }
        },
        child: tree,
      );
    }
    return tree;
  }
}
