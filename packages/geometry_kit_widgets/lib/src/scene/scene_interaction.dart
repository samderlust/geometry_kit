import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';

import 'scene_node.dart';
import 'scene_viewport.dart';

/// One pointer event inside a [GeoScene], in viewport coordinates.
@immutable
class ScenePointer {
  /// Pointer position in the viewport.
  final Offset position;

  /// Camera and size the scene was laid out with.
  final SceneViewport viewport;

  /// The scene's nodes at the time of the event.
  final List<SceneNode> nodes;

  /// Mouse, touch, stylus or trackpad.
  final PointerDeviceKind kind;

  /// Mouse buttons held, as [PointerEvent.buttons] bit flags.
  final int buttons;

  /// Creates a pointer event.
  const ScenePointer({
    required this.position,
    required this.viewport,
    required this.nodes,
    this.kind = PointerDeviceKind.touch,
    this.buttons = kPrimaryButton,
  });

  /// Ray from the camera through [position].
  Ray3 get ray => viewport.rayAt(position);

  /// The nearest pickable solid under the pointer, or `null`.
  SceneHit? pick() => viewport.pick(nodes, position);

  /// The handle under the pointer, or `null`.
  GeoHandle? pickHandle({double slop = 6}) =>
      viewport.pickHandle(nodes, position, slop: slop);
}

/// Receives raw pointer events from a [GeoScene] before the camera does.
///
/// [onPointerDown] decides who owns the gesture: return true to take it,
/// and the scene sends the rest of that pointer's moves and its release
/// here. A claimed gesture wins outright: the camera does not orbit, taps
/// do not reach [GeoScene.onTap], and an enclosing scroll view does not
/// scroll. Return false to let the scene orbit as usual. A second finger
/// landing during a claimed gesture cancels it.
///
/// ```dart
/// class PrintTaps extends SceneInteraction {
///   @override
///   bool onPointerDown(ScenePointer e) {
///     final hit = e.pick();
///     if (hit == null) return false; // empty space: orbit
///     print('grabbed ${hit.node.id}');
///     return true;
///   }
/// }
///
/// GeoScene(interaction: PrintTaps(), children: [...])
/// ```
abstract class SceneInteraction {
  /// Const constructor for subclasses.
  const SceneInteraction();

  /// A pointer went down. Return true to own the gesture.
  bool onPointerDown(ScenePointer e) => false;

  /// The owned pointer moved.
  void onPointerMove(ScenePointer e) {}

  /// The owned pointer was released.
  void onPointerUp(ScenePointer e) {}

  /// The owned gesture was cancelled: by the system, or by a second finger.
  void onPointerCancel() {}

  /// A mouse moved over the scene with no button held.
  void onHover(ScenePointer e) {}

  /// The mouse left the scene.
  void onExit() {}
}
