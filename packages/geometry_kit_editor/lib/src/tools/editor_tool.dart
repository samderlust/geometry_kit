import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '../editor_controller.dart';

/// A mode of the editor: what a pointer does, and what extra nodes
/// (handles, gizmos, guides) are drawn while it is active.
///
/// The [EditorScene] sends each pointer to the controller's active tool.
/// [onPointerDown] returns true to own the gesture; returning false lets
/// the camera orbit. Tools usually wrap an edit in
/// [EditorController.begin] / [EditorController.preview] /
/// [EditorController.commit] so a whole drag is one undo step.
///
/// ```dart
/// class NudgeUpTool extends EditorTool {
///   @override
///   bool onPointerDown(EditorController c, ScenePointer e) {
///     final id = e.pick()?.node.id;
///     if (id == null) return false;
///     c.select({id});
///     c.translateSelection(const Point3(0, 0.5, 0));
///     return true;
///   }
/// }
/// ```
abstract class EditorTool {
  /// Const constructor for subclasses.
  const EditorTool();

  /// A pointer went down. Return true to own the gesture.
  bool onPointerDown(EditorController c, ScenePointer e) => false;

  /// The owned pointer moved.
  void onPointerMove(EditorController c, ScenePointer e) {}

  /// The owned pointer was released.
  void onPointerUp(EditorController c, ScenePointer e) {}

  /// The owned gesture was cancelled. The default cancels any open
  /// transaction.
  void onPointerCancel(EditorController c) => c.cancel();

  /// Extra nodes drawn over the document while this tool is active.
  List<SceneNode> overlay(EditorController c) => const [];
}
