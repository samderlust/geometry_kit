import 'package:flutter/material.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';
import 'package:geometry_kit_editor/geometry_kit_editor.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_kit.dart';

/// Phase 4 starter — select, move, undo: geometry_kit_editor on top of
/// GeoScene.
class EditorDemo extends StatefulWidget {
  const EditorDemo({super.key});

  @override
  State<EditorDemo> createState() => _EditorDemoState();
}

class _EditorDemoState extends State<EditorDemo> {
  late final EditorController _editor = EditorController(
    document: Document([
      _node('crate', Box.cube(center: Point3.zero, size: 1), x: -1.2, y: 0.5),
      _node(
        'drum',
        Cylinder(baseCenter: Point3.zero, radius: 0.4, height: 1.2),
        x: 1,
        z: -0.6,
      ),
      _node(
        'ball',
        const Sphere(center: Point3.zero, radius: 0.45),
        x: 0.4,
        y: 0.45,
        z: 1,
      ),
    ]),
  );
  var _count = 0;

  static EditorNode _node(
    String id,
    Solid solid, {
    double x = 0,
    double y = 0,
    double z = 0,
  }) => EditorNode(
    id: id,
    solid: solid,
    transform: Transform3(position: Point3(x, y, z)),
  );

  static const _code = '''final editor = EditorController(
  document: Document([
    EditorNode(
      id: 'crate',
      solid: Box.cube(center: Point3.zero, size: 1), // local space
      transform: const Transform3(position: Point3(-1.2, 0.5, 0)),
    ),
    ...
  ]),
);

EditorScene(
  controller: editor,
  camera: const OrbitCamera(yaw: 30, pitch: 32, distance: 8),
  background: GeoPath3.grid(extent: 3, step: 0.5),
);

// Tap selects, Shift+tap adds, drag moves (one undo step),
// drag empty space orbits. Keys: ⌘Z / ⇧⌘Z, Delete, arrows, Esc.
editor.undo();
editor.add(EditorNode(id: 'pillar', solid: ...));''';

  @override
  void dispose() {
    _editor.dispose();
    super.dispose();
  }

  void _add(Solid solid, double y) {
    _count++;
    final id = '${solid.runtimeType.toString().toLowerCase()}-$_count';
    _editor.add(_node(id, solid, x: (_count % 5 - 2) * 0.6, y: y, z: 1.8));
  }

  void _toggleLock() {
    final nodes = _editor.selectedNodes.toList();
    if (nodes.isEmpty) return;
    final lock = !nodes.every((n) => n.locked);
    var doc = _editor.document;
    for (final n in nodes) {
      doc = doc.put(n.copyWith(locked: lock));
    }
    _editor.apply(doc);
  }

  @override
  Widget build(BuildContext context) {
    final p = DemoPalette.of(context);
    ShapeStyle styleFor(EditorNode n, {required bool selected}) => ShapeStyle(
      fillColor: n.locked ? p.muted : (selected ? p.amber : p.teal),
      strokeColor: selected
          ? p.accent
          : Color.lerp(p.muted, Colors.black, 0.35),
      strokeWidth: selected ? 2 : 1,
    );

    return ListenableBuilder(
      listenable: _editor,
      builder: (context, _) {
        final sel = _editor.selectedNodes.toList();
        final pos = sel.length == 1 ? sel.single.transform.position : null;
        Widget button(IconData icon, String label, VoidCallback? onTap) =>
            TextButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 16),
              label: Text(label, style: p.mono(12)),
              style: TextButton.styleFrom(foregroundColor: p.fg),
            );

        return Demo3dPage(
          code: _code,
          demo: DemoPanel(
            label: 'EditorScene',
            hint: 'tap · shift+tap · drag',
            scene: ZoomScene(
              camera: const OrbitCamera(yaw: 30, pitch: 32, distance: 8),
              builder: (camera, onCameraChanged) => EditorScene(
                controller: _editor,
                camera: camera,
                onCameraChanged: onCameraChanged,
                nodeStyle: styleFor,
                background: p.grid3(extent: 3, step: 0.5),
              ),
            ),
            footer: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Wrap(
                spacing: 2,
                children: [
                  button(
                    Icons.check_box_outline_blank,
                    'Box',
                    () => _add(
                      Box.fromBase(
                        center: Point3.zero,
                        width: 0.7,
                        depth: 0.7,
                        height: 0.7,
                      ),
                      0,
                    ),
                  ),
                  button(
                    Icons.circle_outlined,
                    'Sphere',
                    () => _add(
                      const Sphere(center: Point3.zero, radius: 0.35),
                      0.35,
                    ),
                  ),
                  button(
                    Icons.undo,
                    'Undo',
                    _editor.canUndo ? _editor.undo : null,
                  ),
                  button(
                    Icons.redo,
                    'Redo',
                    _editor.canRedo ? _editor.redo : null,
                  ),
                  button(
                    Icons.lock_outline,
                    sel.isNotEmpty && sel.every((n) => n.locked)
                        ? 'Unlock'
                        : 'Lock',
                    sel.isEmpty ? null : _toggleLock,
                  ),
                  button(
                    Icons.delete_outline,
                    'Delete',
                    sel.isEmpty ? null : _editor.deleteSelection,
                  ),
                ],
              ),
            ),
            readouts: [
              Readout(
                'Selected',
                sel.isEmpty ? '–' : sel.map((n) => n.id).join(', '),
                highlight: true,
              ),
              Readout(
                'Position',
                pos == null
                    ? '–'
                    : '(${pos.x.toStringAsFixed(2)}, '
                          '${pos.y.toStringAsFixed(2)}, '
                          '${pos.z.toStringAsFixed(2)})',
              ),
              Readout('Objects', '${_editor.document.length}'),
            ],
          ),
        );
      },
    );
  }
}
