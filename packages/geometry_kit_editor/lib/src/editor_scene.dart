import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import 'document.dart';
import 'editor_controller.dart';
import 'tools/editor_tool.dart';

/// Style for a node, given whether it is selected.
typedef EditorNodeStyle =
    ShapeStyle Function(EditorNode node, {required bool selected});

/// A [GeoScene] that draws an [EditorController]'s document and routes the
/// pointer to its active tool.
///
/// Drag a solid to let the tool handle it; drag empty space to orbit; tap
/// empty space to clear the selection. With [enableShortcuts] on, the
/// scene also takes keys once tapped: Ctrl/⌘+Z undo, Shift+Ctrl/⌘+Z or
/// Ctrl+Y redo, Ctrl/⌘+A select all, Delete or Backspace to delete,
/// arrow keys to nudge by [nudgeStep] on the floor, Escape to cancel a drag
/// or clear the selection.
///
/// ```dart
/// final editor = EditorController(document: Document([crate]));
///
/// EditorScene(
///   controller: editor,
///   camera: const OrbitCamera(yaw: 30, pitch: 30, distance: 8),
///   background: GeoPath3.grid(extent: 4, step: 0.5),
/// )
/// ```
class EditorScene extends StatefulWidget {
  /// The editor state to show and change.
  final EditorController controller;

  /// Starting viewpoint.
  final OrbitCamera camera;

  /// Called whenever the user orbits or zooms.
  final ValueChanged<OrbitCamera>? onCameraChanged;

  /// Lighting.
  final DirectionalLight light;

  /// Optional background fill.
  final Color? backgroundColor;

  /// Fixed size; see [GeoScene.size].
  final Size? size;

  /// Nodes drawn before the document, such as a floor grid.
  final List<SceneNode> background;

  /// Nodes drawn after the document and the tool overlay.
  final List<SceneNode> foreground;

  /// Style per node. Defaults to the node's own style, with a blue outline
  /// when selected.
  final EditorNodeStyle? nodeStyle;

  /// Whether keyboard shortcuts are on.
  final bool enableShortcuts;

  /// Distance an arrow key moves the selection.
  final double nudgeStep;

  /// Creates an editor scene.
  const EditorScene({
    super.key,
    required this.controller,
    this.camera = const OrbitCamera(),
    this.onCameraChanged,
    this.light = const DirectionalLight(),
    this.backgroundColor,
    this.size,
    this.background = const [],
    this.foreground = const [],
    this.nodeStyle,
    this.enableShortcuts = true,
    this.nudgeStep = 0.1,
  });

  /// The default [nodeStyle]: the node's style, outlined when selected.
  static ShapeStyle defaultNodeStyle(
    EditorNode node, {
    required bool selected,
  }) {
    if (!selected) return node.style;
    final s = node.style;
    return ShapeStyle(
      fillColor: s.fillColor,
      strokeColor: const Color(0xFF2A56D6),
      strokeWidth: 2,
      opacity: s.opacity,
    );
  }

  @override
  State<EditorScene> createState() => _EditorSceneState();
}

class _EditorSceneState extends State<EditorScene> {
  final _focus = FocusNode(debugLabel: 'EditorScene');
  late final _bridge = _ToolBridge(() => widget.controller, _focus);

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (!widget.enableShortcuts || e is KeyUpEvent) {
      return KeyEventResult.ignored;
    }
    final c = widget.controller;
    final keys = HardwareKeyboard.instance;
    final mod = keys.isMetaPressed || keys.isControlPressed;
    final k = e.logicalKey;
    final step = widget.nudgeStep;

    // Mid-drag only Escape (cancel) applies; edits would fight the drag.
    if (c.inTransaction) {
      if (k != LogicalKeyboardKey.escape) return KeyEventResult.handled;
      c.cancel();
      return KeyEventResult.handled;
    }

    if (mod && k == LogicalKeyboardKey.keyZ) {
      keys.isShiftPressed ? c.redo() : c.undo();
    } else if (mod && k == LogicalKeyboardKey.keyY) {
      c.redo();
    } else if (mod && k == LogicalKeyboardKey.keyA) {
      c.selectAll();
    } else if (k == LogicalKeyboardKey.delete ||
        k == LogicalKeyboardKey.backspace) {
      c.deleteSelection();
    } else if (k == LogicalKeyboardKey.escape) {
      c.clearSelection();
    } else if (k == LogicalKeyboardKey.arrowLeft) {
      c.translateSelection(Point3(-step, 0, 0));
    } else if (k == LogicalKeyboardKey.arrowRight) {
      c.translateSelection(Point3(step, 0, 0));
    } else if (k == LogicalKeyboardKey.arrowUp) {
      c.translateSelection(Point3(0, 0, -step));
    } else if (k == LogicalKeyboardKey.arrowDown) {
      c.translateSelection(Point3(0, 0, step));
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.nodeStyle ?? EditorScene.defaultNodeStyle;
    return Focus(
      focusNode: _focus,
      onKeyEvent: _onKey,
      child: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final c = widget.controller;
          return GeoScene(
            camera: widget.camera,
            onCameraChanged: widget.onCameraChanged,
            light: widget.light,
            backgroundColor: widget.backgroundColor,
            size: widget.size,
            interaction: _bridge,
            onTap: (hit) {
              _focus.requestFocus();
              if (hit == null) c.clearSelection();
            },
            children: [
              ...widget.background,
              for (final n in c.document.nodes)
                if (!n.hidden)
                  GeoSolid(
                    n.solid,
                    transform: n.transform,
                    id: n.id,
                    style: style(n, selected: c.isSelected(n.id)),
                    gradient: n.gradient,
                  ),
              ...c.tool.overlay(c),
              ...widget.foreground,
            ],
          );
        },
      ),
    );
  }
}

/// Forwards the scene's pointer events to the controller's active tool.
///
/// The tool that claims a gesture keeps it: if the controller switches
/// tools mid-gesture, the claiming tool is cancelled and the rest of the
/// gesture is dropped instead of reaching a tool that never saw its start.
class _ToolBridge extends SceneInteraction {
  _ToolBridge(this._controller, this._focus);

  final EditorController Function() _controller;
  final FocusNode _focus;
  EditorTool? _active;

  /// The claiming tool, or null once the controller moved on from it.
  EditorTool? _owner(EditorController c) {
    final active = _active;
    if (active == null || identical(active, c.tool)) return active;
    _active = null;
    active.onPointerCancel(c);
    return null;
  }

  @override
  bool onPointerDown(ScenePointer e) {
    _focus.requestFocus();
    final c = _controller();
    final tool = c.tool;
    if (!tool.onPointerDown(c, e)) return false;
    _active = tool;
    return true;
  }

  @override
  void onPointerMove(ScenePointer e) {
    final c = _controller();
    _owner(c)?.onPointerMove(c, e);
  }

  @override
  void onPointerUp(ScenePointer e) {
    final c = _controller();
    _owner(c)?.onPointerUp(c, e);
    _active = null;
  }

  @override
  void onPointerCancel() {
    final c = _controller();
    _owner(c)?.onPointerCancel(c);
    _active = null;
  }
}
