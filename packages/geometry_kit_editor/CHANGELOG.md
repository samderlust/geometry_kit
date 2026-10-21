## 0.1.0

Initial release.

- `EditorNode`: a solid in local space plus a `Transform3` placement,
  style, an optional `SolidGradient` (`gradient`), `locked` and `hidden`.
  `copyWith(gradient: null)` removes the gradient; leaving it out keeps it.
- `Document`: immutable, ordered nodes keyed by id; `put`, `update`,
  `updateAll`, `translate`, `removeAll`.
- `EditorController`: selection, active tool, snapshot undo/redo with a
  history limit, and `begin` / `preview` / `commit` / `cancel` transactions
  so a drag is one undo step. `apply` (and the helpers built on it) commits
  an open transaction first, so an outside edit ends a drag instead of being
  lost.
- `EditorTool` API and `SelectTool`: click, Shift+click, drag to move on the
  floor (camera-facing plane when the floor is edge-on), selection box.
- `EditorScene`: draws the document in a `GeoScene` (local solids plus
  transforms, so dragging never re-triangulates), routes each gesture to
  the tool that claimed it, orbits on empty space, and handles undo/redo,
  select all, delete, arrow nudge and Escape shortcuts. Mid-drag only Escape
  (cancel) is honoured. Node gradients are drawn as they are; `nodeStyle`
  styles fill colour and edges.
