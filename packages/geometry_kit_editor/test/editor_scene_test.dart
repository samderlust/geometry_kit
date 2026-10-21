import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';
import 'package:geometry_kit_editor/geometry_kit_editor.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

// Looking down at the floor from above and in front.
const _camera = OrbitCamera(yaw: 0, pitch: 40, distance: 8);
const _size = Size(400, 400);

EditorNode box(String id, double x) => EditorNode(
  id: id,
  solid: Box.cube(center: Point3.zero, size: 1),
  transform: Transform3(position: Point3(x, 0.5, 0)),
);

void main() {
  late EditorController c;
  setUp(
    () => c = EditorController(
      document: Document([box('a', -1.5), box('b', 1.5)]),
    ),
  );

  Future<Offset> pump(
    WidgetTester tester, {
    ValueChanged<OrbitCamera>? onCameraChanged,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: EditorScene(
              controller: c,
              camera: _camera,
              size: _size,
              onCameraChanged: onCameraChanged,
            ),
          ),
        ),
      ),
    );
    return tester.getTopLeft(find.byType(GeoScene));
  }

  Offset at(Offset origin, String id) =>
      origin +
      SceneViewport(
        _camera,
        _size,
      ).project(c.document[id]!.transform.position)!;

  testWidgets('node gradients reach the scene, selected or not', (
    tester,
  ) async {
    const g = SolidGradient.linear(colors: [Colors.red, Colors.blue]);
    c.apply(c.document.put(c.document['a']!.copyWith(gradient: g)));
    c.select({'a'});
    await pump(tester);
    final scene = tester.widget<GeoScene>(find.byType(GeoScene));
    final solids = scene.children.whereType<GeoSolid>().toList();
    expect(solids.firstWhere((s) => s.id == 'a').gradient, g);
    expect(solids.firstWhere((s) => s.id == 'b').gradient, isNull);
  });

  testWidgets('tap selects, tap on empty space clears', (tester) async {
    final origin = await pump(tester);
    await tester.tapAt(at(origin, 'a'));
    await tester.pump();
    expect(c.selection, {'a'});
    await tester.tapAt(origin + const Offset(5, 5));
    await tester.pump();
    expect(c.selection, isEmpty);
  });

  testWidgets('shift+tap adds and removes', (tester) async {
    final origin = await pump(tester);
    await tester.tapAt(at(origin, 'a'));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.tapAt(at(origin, 'b'));
    expect(c.selection, {'a', 'b'});
    await tester.tapAt(at(origin, 'a'));
    expect(c.selection, {'b'});
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  });

  testWidgets('dragging a solid moves it on the floor as one undo step', (
    tester,
  ) async {
    OrbitCamera? orbited;
    final origin = await pump(tester, onCameraChanged: (cam) => orbited = cam);
    await tester.timedDragFrom(
      at(origin, 'a'),
      const Offset(60, 0),
      const Duration(milliseconds: 200),
    );
    await tester.pump();
    final p = c.document['a']!.transform.position;
    expect(p.x, greaterThan(-1.5));
    expect(p.y, closeTo(0.5, 1e-9));
    expect(orbited, isNull);
    expect(c.selection, {'a'});
    expect(c.document['b']!.transform.position.x, 1.5);

    c.undo();
    expect(c.document['a']!.transform.position.x, -1.5);
    expect(c.canUndo, isFalse);
  });

  testWidgets('dragging empty space orbits and edits nothing', (tester) async {
    OrbitCamera? orbited;
    final origin = await pump(tester, onCameraChanged: (cam) => orbited = cam);
    await tester.dragFrom(origin + const Offset(10, 10), const Offset(80, 0));
    expect(orbited, isNotNull);
    expect(c.canUndo, isFalse);
  });

  testWidgets('keyboard: nudge, undo, delete, escape', (tester) async {
    final origin = await pump(tester);
    await tester.tapAt(at(origin, 'a'));
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    expect(c.document['a']!.transform.position.x, closeTo(-1.4, 1e-9));

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    expect(c.document['a']!.transform.position.x, -1.5);

    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    expect(c.document.contains('a'), isFalse);

    c.select({'b'});
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    expect(c.selection, isEmpty);
  });

  testWidgets('selection box is drawn for the selected node', (tester) async {
    c.select({'a'});
    await pump(tester);
    final scene = tester.widget<GeoScene>(find.byType(GeoScene));
    expect(scene.children.whereType<GeoPath3>().length, 12);
  });

  group('mid-drag', () {
    testWidgets('Escape cancels, and later moves do not throw', (tester) async {
      final origin = await pump(tester);
      final g = await tester.startGesture(at(origin, 'a'));
      await g.moveBy(const Offset(40, 0));
      expect(c.document['a']!.transform.position.x, isNot(-1.5));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      expect(c.document['a']!.transform.position.x, -1.5);
      await g.moveBy(const Offset(40, 0));
      await g.up();
      expect(tester.takeException(), isNull);
      expect(c.document['a']!.transform.position.x, -1.5);
      expect(c.canUndo, isFalse);
    });

    testWidgets('edit shortcuts are ignored until the drag ends', (
      tester,
    ) async {
      final origin = await pump(tester);
      final g = await tester.startGesture(at(origin, 'a'));
      await g.moveBy(const Offset(40, 0));
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await g.moveBy(const Offset(40, 0));
      await g.up();
      expect(c.document.contains('a'), isTrue);
      final moved = c.document['a']!.transform.position.x;
      c.undo();
      expect(c.document['a']!.transform.position.x, -1.5);
      expect(c.canUndo, isFalse, reason: 'drag is the only step, $moved');

      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      expect(c.document.contains('a'), isFalse, reason: 'works after drag');
    });

    testWidgets('an outside edit ends the drag and is kept', (tester) async {
      final origin = await pump(tester);
      final g = await tester.startGesture(at(origin, 'a'));
      await g.moveBy(const Offset(40, 0));
      c.deleteSelection(); // e.g. a toolbar button
      await g.moveBy(const Offset(40, 0));
      await g.up();
      expect(tester.takeException(), isNull);
      expect(c.document.contains('a'), isFalse);
    });

    testWidgets('switching tools cancels the old tool; the new one gets '
        'nothing until its own gesture', (tester) async {
      final origin = await pump(tester);
      final g = await tester.startGesture(at(origin, 'a'));
      await g.moveBy(const Offset(40, 0));
      final probe = _Probe();
      c.tool = probe;
      await g.moveBy(const Offset(40, 0));
      await g.up();
      expect(probe.calls, isEmpty);
      expect(c.document['a']!.transform.position.x, -1.5);

      await tester.tapAt(at(origin, 'b'));
      expect(probe.calls, ['down']);
    });
  });
}

class _Probe extends EditorTool {
  final calls = <String>[];

  @override
  bool onPointerDown(EditorController c, ScenePointer e) {
    calls.add('down');
    return false;
  }

  @override
  void onPointerMove(EditorController c, ScenePointer e) => calls.add('move');

  @override
  void onPointerUp(EditorController c, ScenePointer e) => calls.add('up');
}
