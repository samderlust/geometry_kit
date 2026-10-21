import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';

import 'scene_interaction.dart';
import 'scene_node.dart';
import 'scene_painter.dart';
import 'scene_viewport.dart';

/// Called while the user drags a solid: [delta] is how far the pointer
/// moved on the horizontal plane through the grab point. When the camera
/// sees that plane nearly edge-on, the plane facing the camera is used
/// instead, so [delta] can then have a vertical part.
typedef SolidDragCallback = void Function(GeoSolid node, Point3 delta);

/// A 3D scene drawn on a Flutter canvas.
///
/// Solids are triangulated, back-face culled, sorted back to front and
/// flat-shaded by [light]. This needs no GPU API and runs on every Flutter
/// platform; it suits charts, rooms and simple models up to a few thousand
/// triangles. Faces that cut through each other can draw in the wrong
/// order, because there is no depth buffer.
///
/// Drag to orbit, pinch or scroll to zoom. Taps and hovers report the solid
/// under the pointer. With [onDragSolid] set, dragging a solid moves it
/// instead of orbiting. For anything more (selection, handles, gizmos),
/// pass an [interaction]: it sees each pointer first and decides whether
/// the camera orbits.
///
/// ```dart
/// GeoScene(
///   camera: const OrbitCamera(yaw: 35, pitch: 25, distance: 7),
///   onTap: (hit) => print(hit?.node.id),
///   children: [
///     ...GeoPath3.grid(extent: 3, step: 0.5),
///     GeoSolid(
///       Box.fromBase(center: Point3.zero, width: 1, depth: 1, height: 1.5),
///       style: const ShapeStyle(fillColor: Colors.indigo, strokeColor: Colors.black),
///       id: 'crate',
///     ),
///   ],
/// )
/// ```
class GeoScene extends StatefulWidget {
  /// What to draw.
  final List<SceneNode> children;

  /// Starting viewpoint. A new value replaces the user's current orbit.
  final OrbitCamera camera;

  /// Called whenever the user orbits or zooms.
  final ValueChanged<OrbitCamera>? onCameraChanged;

  /// Lighting.
  final DirectionalLight light;

  /// Optional background fill.
  final Color? backgroundColor;

  /// Fixed size. When null the scene fills its parent, or uses a 4:3
  /// aspect ratio when the parent's height is unbounded.
  final Size? size;

  /// Whether one-finger drags orbit the camera.
  final bool enableOrbit;

  /// Whether pinch and mouse-wheel zoom are on.
  final bool enableZoom;

  /// Orbit speed in degrees per logical pixel dragged.
  final double orbitSensitivity;

  /// Called on tap with the solid under the pointer, or null.
  final ValueChanged<SceneHit?>? onTap;

  /// Called as a mouse moves over the scene, with the solid under it, and
  /// with null when the pointer leaves.
  final ValueChanged<SceneHit?>? onHover;

  /// When set, dragging a pickable solid calls this instead of orbiting.
  /// Cannot be combined with [interaction].
  final SolidDragCallback? onDragSolid;

  /// Receives pointer events before the camera, and can claim a gesture
  /// so it does not orbit. Taps on a claimed gesture do not call [onTap].
  final SceneInteraction? interaction;

  /// Creates a 3D scene.
  const GeoScene({
    super.key,
    required this.children,
    this.camera = const OrbitCamera(),
    this.onCameraChanged,
    this.light = const DirectionalLight(),
    this.backgroundColor,
    this.size,
    this.enableOrbit = true,
    this.enableZoom = true,
    this.orbitSensitivity = 0.4,
    this.onTap,
    this.onHover,
    this.onDragSolid,
    this.interaction,
  }) : assert(
         onDragSolid == null || interaction == null,
         'Use either onDragSolid or interaction, not both.',
       );

  @override
  State<GeoScene> createState() => _GeoSceneState();
}

class _GeoSceneState extends State<GeoScene> {
  final _cache = SceneMeshCache();
  late OrbitCamera _camera = widget.camera;
  Size _size = Size.zero;
  SceneViewport? _viewportCache;

  late final _solidDrag = _SolidDragInteraction(
    (node, delta) => widget.onDragSolid?.call(node, delta),
  );

  // Gesture state.
  double _startDistance = 1;
  // The interaction that owns the current gesture. Events go to it, not to
  // whatever [_interaction] is now, so swapping or removing the interaction
  // mid-gesture cannot hand a half gesture to another one.
  SceneInteraction? _claimedBy;

  @override
  void didUpdateWidget(GeoScene old) {
    super.didUpdateWidget(old);
    if (old.camera != widget.camera) _camera = widget.camera;
    final owner = _claimedBy;
    if (owner != null && !identical(owner, _interaction)) {
      _claimedBy = null;
      owner.onPointerCancel();
    }
  }

  SceneInteraction? get _interaction =>
      widget.interaction ?? (widget.onDragSolid != null ? _solidDrag : null);

  SceneViewport get _viewport {
    final v = _viewportCache;
    if (v != null && v.camera == _camera && v.size == _size) return v;
    return _viewportCache = SceneViewport(_camera, _size);
  }

  void _setCamera(OrbitCamera c) {
    setState(() => _camera = c);
    widget.onCameraChanged?.call(c);
  }

  ScenePointer _event(PointerEvent e) => ScenePointer(
    position: e.localPosition,
    viewport: _viewport,
    nodes: widget.children,
    kind: e.kind,
    buttons: e.buttons,
  );

  SceneHit? _pick(Offset local) => _viewport.pick(widget.children, local);

  bool _claim(PointerDownEvent e) {
    final interaction = _interaction;
    if (interaction == null || !interaction.onPointerDown(_event(e))) {
      return false;
    }
    _claimedBy = interaction;
    return true;
  }

  void _onScaleStart(ScaleStartDetails d) {
    _startDistance = _camera.distance;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    if (_claimedBy != null) return;
    var next = _camera;
    if (widget.enableZoom && d.pointerCount > 1 && d.scale > 0) {
      next = next.withDistance(_startDistance / d.scale);
    }
    if (widget.enableOrbit) {
      next = next.orbit(
        yaw: -d.focalPointDelta.dx * widget.orbitSensitivity,
        pitch: d.focalPointDelta.dy * widget.orbitSensitivity,
      );
    }
    if (next != _camera) _setCamera(next);
  }

  void _onPointerSignal(PointerSignalEvent e) {
    if (!widget.enableZoom || e is! PointerScrollEvent) return;
    GestureBinding.instance.pointerSignalResolver.register(e, (event) {
      final scroll = (event as PointerScrollEvent).scrollDelta.dy;
      _setCamera(_camera.zoom(scroll > 0 ? 1.1 : 1 / 1.1));
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget scene = LayoutBuilder(
      builder: (context, constraints) {
        final size =
            widget.size ??
            (constraints.hasBoundedHeight
                ? constraints.biggest
                : Size(constraints.maxWidth, constraints.maxWidth * 0.75));
        _size = size;
        return CustomPaint(
          size: size,
          painter: ScenePainter(
            nodes: widget.children,
            camera: _camera,
            light: widget.light,
            backgroundColor: widget.backgroundColor,
            cache: _cache,
          ),
        );
      },
    );

    scene = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onTapUp: widget.onTap == null
          ? null
          : (d) => widget.onTap!(_pick(d.localPosition)),
      child: scene,
    );

    final interaction = _interaction;
    if (interaction != null) {
      // Wins the gesture arena as soon as the interaction claims a pointer,
      // so neither the camera nor an enclosing scroll view also reacts.
      scene = RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        gestures: {
          _ClaimRecognizer:
              GestureRecognizerFactoryWithHandlers<_ClaimRecognizer>(
                () => _ClaimRecognizer(debugOwner: this),
                (r) => r
                  ..onDown = _claim
                  ..onMove = ((e) => _claimedBy?.onPointerMove(_event(e)))
                  ..onUp = ((e) {
                    final owner = _claimedBy;
                    _claimedBy = null;
                    owner?.onPointerUp(_event(e));
                  })
                  ..onCancel = () {
                    final owner = _claimedBy;
                    _claimedBy = null;
                    owner?.onPointerCancel();
                  },
              ),
        },
        child: scene,
      );
    }

    scene = Listener(
      behavior: HitTestBehavior.opaque,
      onPointerHover: interaction == null
          ? null
          : (e) => interaction.onHover(_event(e)),
      onPointerSignal: widget.enableZoom ? _onPointerSignal : null,
      child: scene,
    );

    if (widget.onHover != null || interaction != null) {
      scene = MouseRegion(
        onHover: widget.onHover == null
            ? null
            : (e) => widget.onHover!(_pick(e.localPosition)),
        onExit: (_) {
          widget.onHover?.call(null);
          interaction?.onExit();
        },
        child: scene,
      );
    }
    return RepaintBoundary(child: ClipRect(child: scene));
  }
}

/// Backs [GeoScene.onDragSolid]: grab a solid, slide it on a drag plane.
class _SolidDragInteraction extends SceneInteraction {
  _SolidDragInteraction(this.onDrag);

  final SolidDragCallback onDrag;

  GeoSolid? _node;
  Point3? _last;
  Plane? _plane;

  @override
  bool onPointerDown(ScenePointer e) {
    final hit = e.pick();
    if (hit == null) return false;
    _node = hit.node;
    _last = hit.hit.point;
    _plane = e.viewport.dragPlane(hit.hit.point);
    return true;
  }

  @override
  void onPointerMove(ScenePointer e) {
    final node = _node, last = _last, plane = _plane;
    if (node == null || last == null || plane == null) return;
    final p = e.viewport.onPlane(e.position, plane);
    if (p == null) return;
    onDrag(node, p - last);
    _last = p;
  }

  @override
  void onPointerUp(ScenePointer e) => onPointerCancel();

  @override
  void onPointerCancel() {
    _node = null;
    _last = null;
    _plane = null;
  }
}

/// Claims a pointer for a [SceneInteraction] and wins the gesture arena at
/// once, so scale, tap and enclosing scroll recognizers all lose it.
///
/// A second pointer landing while one is claimed ends the claim with a
/// cancel.
class _ClaimRecognizer extends OneSequenceGestureRecognizer {
  _ClaimRecognizer({super.debugOwner});

  bool Function(PointerDownEvent e)? onDown;
  ValueChanged<PointerEvent>? onMove;
  ValueChanged<PointerEvent>? onUp;
  VoidCallback? onCancel;

  int? _owner;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    final owner = _owner;
    if (owner != null) {
      _owner = null;
      onCancel?.call();
      stopTrackingPointer(owner);
      return;
    }
    if (onDown?.call(event) ?? false) {
      _owner = event.pointer;
      startTrackingPointer(event.pointer, event.transform);
      resolvePointer(event.pointer, GestureDisposition.accepted);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event.pointer != _owner) return;
    if (event is PointerMoveEvent) {
      onMove?.call(event);
    } else if (event is PointerUpEvent) {
      _owner = null;
      onUp?.call(event);
      stopTrackingPointer(event.pointer);
    } else if (event is PointerCancelEvent) {
      _owner = null;
      onCancel?.call();
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void rejectGesture(int pointer) {
    if (pointer == _owner) {
      _owner = null;
      onCancel?.call();
    }
    super.rejectGesture(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  String get debugDescription => 'scene interaction';
}
