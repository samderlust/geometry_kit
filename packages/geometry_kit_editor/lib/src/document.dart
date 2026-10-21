import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:geometry_kit_3d/geometry_kit_3d.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

/// One editable object: a solid in local space plus where it is placed.
///
/// Keeping the [transform] apart from the [solid] means the editor always
/// knows the object's pose (for gizmos and readouts) and repeated edits do
/// not pile rounding errors into the geometry.
///
/// ```dart
/// final crate = EditorNode(
///   id: 'crate',
///   solid: Box.cube(center: Point3.zero, size: 1),
///   transform: const Transform3(position: Point3(0, 0.5, 0)),
/// );
/// ```
@immutable
class EditorNode {
  /// Stable identifier, unique within a [Document].
  final String id;

  /// Geometry in local space.
  final Solid solid;

  /// Placement in the world.
  final Transform3 transform;

  /// Fill and edge style.
  final ShapeStyle style;

  /// Locked nodes can be selected but not moved or deleted.
  final bool locked;

  /// Hidden nodes are not drawn and cannot be picked.
  final bool hidden;

  /// Creates a node.
  const EditorNode({
    required this.id,
    required this.solid,
    this.transform = Transform3.identity,
    this.style = const ShapeStyle.filled(Color(0xFF90A4AE)),
    this.locked = false,
    this.hidden = false,
  });

  /// The solid placed in world space.
  Solid get worldSolid => transform.applyTo(solid);

  /// Copy with the given fields replaced.
  EditorNode copyWith({
    Solid? solid,
    Transform3? transform,
    ShapeStyle? style,
    bool? locked,
    bool? hidden,
  }) => EditorNode(
    id: id,
    solid: solid ?? this.solid,
    transform: transform ?? this.transform,
    style: style ?? this.style,
    locked: locked ?? this.locked,
    hidden: hidden ?? this.hidden,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EditorNode &&
          other.id == id &&
          other.solid == solid &&
          other.transform == transform &&
          other.style == style &&
          other.locked == locked &&
          other.hidden == hidden);

  @override
  int get hashCode => Object.hash(id, solid, transform, style, locked, hidden);

  @override
  String toString() => 'EditorNode($id, ${solid.runtimeType})';
}

/// An immutable, ordered set of [EditorNode]s keyed by id.
///
/// Every edit returns a new document, so undo history is a list of
/// documents. Nodes keep their order, which is the draw order.
@immutable
class Document {
  final Map<String, EditorNode> _nodes;

  /// Creates a document. Ids must be unique.
  factory Document([Iterable<EditorNode> nodes = const []]) {
    final map = <String, EditorNode>{};
    for (final n in nodes) {
      if (map.containsKey(n.id)) {
        throw ArgumentError.value(n.id, 'nodes', 'Duplicate node id');
      }
      map[n.id] = n;
    }
    return Document._(Map.unmodifiable(map));
  }

  const Document._(this._nodes);

  /// A document with no nodes.
  static const empty = Document._({});

  /// Nodes in draw order.
  Iterable<EditorNode> get nodes => _nodes.values;

  /// Node ids in draw order.
  Iterable<String> get ids => _nodes.keys;

  /// Number of nodes.
  int get length => _nodes.length;

  /// The node with [id], or `null`.
  EditorNode? operator [](String id) => _nodes[id];

  /// Whether a node with [id] exists.
  bool contains(String id) => _nodes.containsKey(id);

  /// Adds [node] at the end, or replaces the node with the same id in place.
  Document put(EditorNode node) {
    if (identical(_nodes[node.id], node)) return this;
    return Document._(Map.unmodifiable({..._nodes, node.id: node}));
  }

  /// Replaces the node with [id] by `edit(node)`. Missing ids are ignored.
  Document update(String id, EditorNode Function(EditorNode node) edit) {
    final node = _nodes[id];
    return node == null ? this : put(edit(node));
  }

  /// Applies [edit] to every node in [ids] that is not locked.
  Document updateAll(
    Iterable<String> ids,
    EditorNode Function(EditorNode node) edit,
  ) {
    final next = {..._nodes};
    var changed = false;
    for (final id in ids) {
      final node = next[id];
      if (node == null || node.locked) continue;
      next[id] = edit(node);
      changed = true;
    }
    return changed ? Document._(Map.unmodifiable(next)) : this;
  }

  /// Moves every unlocked node in [ids] by [delta].
  Document translate(Iterable<String> ids, Point3 delta) => updateAll(
    ids,
    (n) => n.copyWith(transform: n.transform.translated(delta)),
  );

  /// Without the unlocked nodes in [ids].
  Document removeAll(Iterable<String> ids) {
    final drop = {
      for (final id in ids)
        if (_nodes[id] case final n? when !n.locked) id,
    };
    if (drop.isEmpty) return this;
    return Document._(
      Map.unmodifiable({
        for (final e in _nodes.entries)
          if (!drop.contains(e.key)) e.key: e.value,
      }),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Document || other.length != length) return false;
    final a = _nodes.entries.iterator, b = other._nodes.entries.iterator;
    while (a.moveNext() && b.moveNext()) {
      if (a.current.key != b.current.key ||
          a.current.value != b.current.value) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_nodes.values);
}
