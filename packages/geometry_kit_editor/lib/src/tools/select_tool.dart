import 'package:flutter/services.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '../editor_controller.dart';
import 'editor_tool.dart';

/// Click to select, Shift+click to add or remove, drag a solid to move the
/// selection.
///
/// Dragging slides the selection on the horizontal plane through the grab
/// point (or the plane facing the camera when the floor is seen edge-on).
/// A drag is one undo step. Clicking empty space is left to the scene,
/// which orbits on drag and clears the selection on tap.
class SelectTool extends EditorTool {
  /// Creates the select tool.
  SelectTool({this.dragSlop = 4, this.outlineColor = const Color(0xFF2A56D6)});

  /// Pixels the pointer must travel before a press becomes a drag.
  final double dragSlop;

  /// Colour of the dashed box drawn around the selection.
  final Color outlineColor;

  Offset? _downAt;
  Point3? _grab;
  Plane? _plane;
  bool _dragging = false;
  String? _toggleOnUp;
  String? _selectOnlyOnUp;

  @override
  bool onPointerDown(EditorController c, ScenePointer e) {
    final hit = e.pick();
    final id = hit?.node.id;
    if (hit == null || id == null) return false;

    _toggleOnUp = null;
    _selectOnlyOnUp = null;
    if (HardwareKeyboard.instance.isShiftPressed) {
      // Remove on release, so Shift+drag can still move the group.
      if (c.isSelected(id)) {
        _toggleOnUp = id;
      } else {
        c.select({id}, additive: true);
      }
    } else if (!c.isSelected(id)) {
      c.select({id});
    } else if (c.selection.length > 1) {
      // A plain click on one of several selected nodes keeps just it, but
      // only on release, so dragging moves the whole group.
      _selectOnlyOnUp = id;
    }

    _downAt = e.position;
    _grab = hit.hit.point;
    _plane = e.viewport.dragPlane(hit.hit.point);
    _dragging = false;
    c.begin();
    return true;
  }

  @override
  void onPointerMove(EditorController c, ScenePointer e) {
    final downAt = _downAt, grab = _grab, plane = _plane;
    if (downAt == null || grab == null || plane == null) return;
    if (!c.inTransaction) {
      // Escape or an outside edit ended the drag: stop following it.
      _reset();
      return;
    }
    if (!_dragging && (e.position - downAt).distance < dragSlop) return;
    _dragging = true;
    final p = e.viewport.onPlane(e.position, plane);
    if (p == null) return;
    final selection = c.selection;
    c.preview((base) => base.translate(selection, p - grab));
  }

  @override
  void onPointerUp(EditorController c, ScenePointer e) {
    if (_downAt == null || !c.inTransaction) return _reset();
    c.commit();
    if (!_dragging) {
      if (_toggleOnUp case final id?) c.toggle(id);
      if (_selectOnlyOnUp case final id?) c.select({id});
    }
    _reset();
  }

  @override
  void onPointerCancel(EditorController c) {
    c.cancel();
    _reset();
  }

  void _reset() {
    _downAt = null;
    _grab = null;
    _plane = null;
    _dragging = false;
    _toggleOnUp = null;
    _selectOnlyOnUp = null;
  }

  @override
  List<SceneNode> overlay(EditorController c) {
    final nodes = c.selectedNodes.where((n) => !n.hidden).toList();
    if (nodes.isEmpty) return const [];
    final box = nodes
        .map((n) => n.worldSolid.bounds)
        .reduce((a, b) => a.union(b));
    return selectionBox(box, outlineColor);
  }
}

/// Dashed edges of [box], drawn over the solids.
List<GeoPath3> selectionBox(Aabb box, Color color) {
  final c = box.corners; // index bits: x*4 + y*2 + z
  const edges = [
    [0, 1], [2, 3], [4, 5], [6, 7], // along z
    [0, 2], [1, 3], [4, 6], [5, 7], // along y
    [0, 4], [1, 5], [2, 6], [3, 7], // along x
  ];
  final style = ShapeStyle(
    strokeColor: color,
    strokeWidth: 1.2,
    dashPattern: const DashPattern([4, 3]),
  );
  return [
    for (final e in edges) GeoPath3([c[e[0]], c[e[1]]], style: style),
  ];
}
