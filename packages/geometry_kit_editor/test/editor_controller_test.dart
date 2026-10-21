import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:geometry_kit_3d/geometry_kit_3d.dart';
import 'package:geometry_kit_editor/geometry_kit_editor.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

EditorNode box(String id, {double x = 0, bool locked = false}) => EditorNode(
  id: id,
  solid: Box.cube(center: Point3.zero, size: 1),
  transform: Transform3(position: Point3(x, 0.5, 0)),
  locked: locked,
);

void main() {
  group('Document', () {
    test('keeps order and replaces in place', () {
      final d = Document([box('a'), box('b'), box('c')]);
      final moved = d.put(box('b', x: 3));
      expect(moved.ids, ['a', 'b', 'c']);
      expect(moved['b']!.transform.position.x, 3);
      expect(d['b']!.transform.position.x, 0, reason: 'original unchanged');
    });

    test('rejects duplicate ids', () {
      expect(() => Document([box('a'), box('a')]), throwsArgumentError);
    });

    test('translate and removeAll skip locked nodes', () {
      final d = Document([box('a'), box('b', locked: true)]);
      final t = d.translate({'a', 'b'}, Point3.unitX);
      expect(t['a']!.transform.position.x, 1);
      expect(t['b']!.transform.position.x, 0);
      expect(d.removeAll({'a', 'b'}).ids, ['b']);
    });

    test('equal by value', () {
      expect(Document([box('a')]), Document([box('a')]));
      expect(Document([box('a')]), isNot(Document([box('a', x: 1)])));
    });

    test('copyWith keeps the gradient unless told to clear it', () {
      const g = SolidGradient.linear(
        colors: [Color(0xFFFF0000), Color(0xFF0000FF)],
      );
      final n = box('a').copyWith(gradient: g);
      expect(n.gradient, g);
      expect(n.copyWith(locked: true).gradient, g);
      expect(n.copyWith(gradient: null).gradient, isNull);
      expect(n, isNot(box('a')));
    });

    test('worldSolid applies the transform', () {
      final n = box('a', x: 2);
      expect(
        n.worldSolid.bounds.min.isCloseTo(const Point3(1.5, 0, -0.5)),
        isTrue,
      );
    });
  });

  group('EditorController', () {
    late EditorController c;
    setUp(() => c = EditorController(document: Document([box('a'), box('b')])));

    test('select, toggle and clear', () {
      c.select({'a'});
      expect(c.selection, {'a'});
      c.toggle('b');
      expect(c.selection, {'a', 'b'});
      c.toggle('a');
      expect(c.selection, {'b'});
      c.select({'missing'});
      expect(c.selection, isEmpty);
      c.selectAll();
      expect(c.selection, {'a', 'b'});
    });

    test('apply, undo and redo', () {
      c.select({'a'});
      c.translateSelection(Point3.unitX);
      expect(c.document['a']!.transform.position.x, 1);
      expect(c.canUndo, isTrue);
      c.undo();
      expect(c.document['a']!.transform.position.x, 0);
      c.redo();
      expect(c.document['a']!.transform.position.x, 1);
      expect(c.canRedo, isFalse);
    });

    test('gradient edits undo like any other', () {
      const g = SolidGradient.radial(
        colors: [Color(0xFFFFFFFF), Color(0xFF000000)],
      );
      c.apply(c.document.put(c.document['a']!.copyWith(gradient: g)));
      expect(c.document['a']!.gradient, g);
      c.undo();
      expect(c.document['a']!.gradient, isNull);
    });

    test('a new edit clears redo', () {
      c.select({'a'});
      c.translateSelection(Point3.unitX);
      c.undo();
      c.translateSelection(Point3.unitZ);
      expect(c.canRedo, isFalse);
    });

    test('a transaction is one undo step and previews build on its base', () {
      c.select({'a'});
      c.begin();
      for (var i = 1; i <= 5; i++) {
        c.preview((base) => base.translate(c.selection, Point3(i * 0.1, 0, 0)));
      }
      expect(c.canUndo, isFalse, reason: 'nothing recorded mid-drag');
      c.commit();
      expect(c.document['a']!.transform.position.x, closeTo(0.5, 1e-12));
      c.undo();
      expect(c.document['a']!.transform.position.x, 0);
      expect(c.canUndo, isFalse);
    });

    test('cancel restores the document', () {
      final before = c.document;
      c.select({'a'});
      c.begin();
      c.preview((base) => base.translate({'a'}, Point3.unitX));
      c.cancel();
      expect(c.document, before);
      expect(c.canUndo, isFalse);
    });

    test('an unchanged transaction records nothing', () {
      c.begin();
      c.commit();
      expect(c.canUndo, isFalse);
    });

    test('an outside edit mid-transaction commits the drag first', () {
      c.select({'a'});
      c.begin();
      c.preview((base) => base.translate({'a'}, Point3.unitX));
      c.deleteSelection();
      expect(c.inTransaction, isFalse);
      expect(c.document.contains('a'), isFalse);
      c.undo(); // undoes the delete
      expect(c.document['a']!.transform.position.x, 1);
      c.undo(); // undoes the drag
      expect(c.document['a']!.transform.position.x, 0);
    });

    test('preview without begin throws', () {
      expect(() => c.preview((d) => d), throwsStateError);
    });

    test('delete then undo brings the node back; selection follows', () {
      c.select({'a'});
      c.deleteSelection();
      expect(c.document.contains('a'), isFalse);
      expect(c.selection, isEmpty);
      c.undo();
      expect(c.document.contains('a'), isTrue);
    });

    test('add selects the new node; undoing it drops the selection', () {
      c.add(box('c', x: 2));
      expect(c.selection, {'c'});
      c.undo();
      expect(c.selection, isEmpty);
    });

    test('history is capped', () {
      final small = EditorController(
        document: Document([box('a')]),
        historyLimit: 3,
      )..select({'a'});
      for (var i = 0; i < 10; i++) {
        small.translateSelection(Point3.unitX);
      }
      var steps = 0;
      while (small.canUndo) {
        small.undo();
        steps++;
      }
      expect(steps, 3);
    });

    test('notifies listeners on change only', () {
      var calls = 0;
      c.addListener(() => calls++);
      c.select({'a'});
      c.select({'a'});
      expect(calls, 1);
    });
  });
}
