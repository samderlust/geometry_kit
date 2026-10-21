/// Interactive editing for [`geometry_kit_widgets`](https://pub.dev/packages/geometry_kit_widgets)
/// 3D scenes.
///
/// An `EditorController` holds an immutable `Document` of `EditorNode`s
/// (a solid in local space plus a `Transform3`), the selection, the active
/// `EditorTool` and undo history. `EditorScene` draws the document in a
/// `GeoScene` and sends pointer events to the tool.
///
/// The API is young (0.x) and will change as handles, gizmos and snapping
/// land.
library;

export 'src/document.dart';
export 'src/editor_controller.dart';
export 'src/editor_scene.dart';
export 'src/tools/editor_tool.dart';
export 'src/tools/select_tool.dart';
