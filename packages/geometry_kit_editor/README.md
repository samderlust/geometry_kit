[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/samderlust)

# geometry_kit_editor

Interactive editing for [`geometry_kit_widgets`](https://pub.dev/packages/geometry_kit_widgets)
3D scenes: select solids, drag them around, undo and redo.

> 0.x: the API will change as resize handles, gizmos and snapping land.

## Model

- **`EditorNode`**: a `Solid` in local space plus a `Transform3`
  (position, rotation, uniform scale). Keeping the pose apart from the
  geometry means the editor always knows how an object is placed, and
  repeated edits do not pile rounding errors into the solid.
- **`Document`**: an immutable, ordered map of nodes. Every edit returns a
  new document.
- **`EditorController`**: a `ChangeNotifier` holding the document, the
  selection, the active `EditorTool` and undo history. History is a stack
  of documents; a drag is one `begin` / `preview` / `commit` transaction.
- **`EditorTool`**: what a pointer does. `SelectTool` is the default.

## Usage

```dart
final editor = EditorController(
  document: Document([
    EditorNode(
      id: 'crate',
      solid: Box.cube(center: Point3.zero, size: 1),
      transform: const Transform3(position: Point3(0, 0.5, 0)),
    ),
  ]),
);

EditorScene(
  controller: editor,
  camera: const OrbitCamera(yaw: 30, pitch: 30, distance: 8),
  background: GeoPath3.grid(extent: 4, step: 0.5),
);

// Elsewhere:
editor.undo();
editor.translateSelection(const Point3(0, 1, 0));

// Restyle the selection (locked nodes are skipped) as one undo step,
// here with a gradient fixed to each solid (see geometry_kit_widgets):
editor.apply(editor.document.updateAll(
  editor.selection,
  (n) => n.copyWith(
    gradient: const SolidGradient.linear(
      start: Anchor3.top,
      end: Anchor3.bottom,
      colors: [Colors.teal, Colors.purple],
    ),
  ),
));
// n.copyWith(gradient: null) goes back to the solid fill colour.
```

| Input | Does |
|---|---|
| Tap a solid | select it |
| Shift+tap | add to or remove from the selection |
| Drag a solid | move the selection on the floor |
| Drag empty space | orbit |
| Tap empty space | clear the selection |
| Ctrl/⌘+Z, Shift+Ctrl/⌘+Z, Ctrl+Y | undo, redo |
| Delete / Backspace | delete the selection |
| Arrow keys | nudge on the floor |
| Escape | cancel a drag, or clear the selection |

Locked nodes can be selected but not moved or deleted. Hidden nodes are not
drawn or picked.

## Writing a tool

```dart
class LiftTool extends EditorTool {
  @override
  bool onPointerDown(EditorController c, ScenePointer e) {
    final id = e.pick()?.node.id;
    if (id == null) return false; // let the camera orbit
    c.select({id});
    c.translateSelection(const Point3(0, 0.5, 0));
    return true;
  }
}

editor.tool = LiftTool();
```

---

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/samderlust)
