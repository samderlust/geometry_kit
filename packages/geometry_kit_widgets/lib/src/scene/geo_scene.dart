import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart' show Point;
import 'package:geometry_kit_3d/geometry_kit_3d.dart';

import 'scene_node.dart';
import 'scene_painter.dart';

/// Called while the user drags a solid: [delta] is how far the pointer
/// moved on the horizontal plane through the grab point.
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
/// instead of orbiting.
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
  final SolidDragCallback? onDragSolid;

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
  });

  @override
  State<GeoScene> createState() => _GeoSceneState();
}

class _GeoSceneState extends State<GeoScene> {
  final _cache = SceneMeshCache();
  late OrbitCamera _camera = widget.camera;
  Size _size = Size.zero;

  // Gesture state.
  double _startDistance = 1;
  GeoSolid? _dragNode;
  Point3? _dragPoint;
  double _dragPlaneY = 0;

  @override
  void didUpdateWidget(GeoScene old) {
    super.didUpdateWidget(old);
    if (old.camera != widget.camera) _camera = widget.camera;
  }

  void _setCamera(OrbitCamera c) {
    setState(() => _camera = c);
    widget.onCameraChanged?.call(c);
  }

  Ray3 _ray(Offset local) =>
      _camera.rayThrough(Point(local.dx, local.dy), _size.width, _size.height);

  SceneHit? _pick(Offset local) {
    final ray = _ray(local);
    SceneHit? best;
    for (final node in widget.children) {
      if (node is! GeoSolid || !node.pickable) continue;
      final hit = node.solid.intersectRay(ray);
      if (hit != null && (best == null || hit.distance < best.hit.distance)) {
        best = SceneHit(node, hit);
      }
    }
    return best;
  }

  Point3? _onDragPlane(Offset local) {
    final ray = _ray(local);
    final dy = ray.direction.y;
    if (dy.abs() < 1e-9) return null;
    final t = (_dragPlaneY - ray.origin.y) / dy;
    return t < 0 ? null : ray.pointAt(t);
  }

  void _onScaleStart(ScaleStartDetails d) {
    _startDistance = _camera.distance;
    _dragNode = null;
    if (widget.onDragSolid != null && d.pointerCount == 1) {
      final hit = _pick(d.localFocalPoint);
      if (hit != null) {
        _dragNode = hit.node;
        _dragPoint = hit.hit.point;
        _dragPlaneY = hit.hit.point.y;
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    if (_dragNode != null) {
      final p = _onDragPlane(d.localFocalPoint);
      if (p != null && _dragPoint != null) {
        widget.onDragSolid!(_dragNode!, p - _dragPoint!);
        _dragPoint = p;
      }
      return;
    }
    var next = _camera;
    if (widget.enableZoom && d.pointerCount > 1 && d.scale > 0) {
      next = next.copyWith(distance: _startDistance / d.scale);
    }
    if (widget.enableOrbit) {
      next = next.orbit(
        yaw: -d.focalPointDelta.dx * widget.orbitSensitivity,
        pitch: d.focalPointDelta.dy * widget.orbitSensitivity,
      );
    }
    if (next != _camera) _setCamera(next);
  }

  void _onScaleEnd(ScaleEndDetails d) {
    _dragNode = null;
    _dragPoint = null;
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
      onScaleEnd: _onScaleEnd,
      onTapUp: widget.onTap == null
          ? null
          : (d) => widget.onTap!(_pick(d.localPosition)),
      child: scene,
    );

    if (widget.onHover != null) {
      scene = MouseRegion(
        onHover: (e) => widget.onHover!(_pick(e.localPosition)),
        onExit: (_) => widget.onHover!(null),
        child: scene,
      );
    }
    if (widget.enableZoom) {
      scene = Listener(onPointerSignal: _onPointerSignal, child: scene);
    }
    return RepaintBoundary(child: ClipRect(child: scene));
  }
}
