import 'package:flutter/foundation.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';

import 'document.dart';
import 'tools/editor_tool.dart';
import 'tools/select_tool.dart';

/// The mutable state of an editor: the current [Document], the selection,
/// the active [tool] and the undo history.
///
/// Documents are immutable, so history is a stack of snapshots. A drag is
/// one [begin] … [preview]* … [commit] transaction and becomes a single
/// undo step; [cancel] puts the document back as it was.
///
/// ```dart
/// final editor = EditorController(document: Document([crate, ball]));
/// editor.select({'crate'});
/// editor.apply(editor.document.translate(editor.selection, Point3.unitX));
/// editor.undo();
/// ```
class EditorController extends ChangeNotifier {
  /// Creates a controller.
  EditorController({
    Document? document,
    EditorTool? tool,
    this.historyLimit = 100,
  }) : _document = document ?? Document.empty,
       _tool = tool ?? SelectTool();

  /// Most undo steps kept.
  final int historyLimit;

  Document _document;
  Set<String> _selection = const {};
  EditorTool _tool;
  final _undo = <Document>[];
  final _redo = <Document>[];
  Document? _base; // document when the open transaction began

  /// The current document.
  Document get document => _document;

  /// Ids of the selected nodes, in selection order.
  Set<String> get selection => _selection;

  /// The selected nodes that still exist.
  Iterable<EditorNode> get selectedNodes => [
    for (final id in _selection) ?_document[id],
  ];

  /// The tool that receives pointer events.
  EditorTool get tool => _tool;
  set tool(EditorTool value) {
    if (identical(value, _tool)) return;
    if (inTransaction) cancel();
    _tool = value;
    notifyListeners();
  }

  /// Whether [undo] would do anything.
  bool get canUndo => _undo.isNotEmpty && !inTransaction;

  /// Whether [redo] would do anything.
  bool get canRedo => _redo.isNotEmpty && !inTransaction;

  /// Whether a [begin] is waiting for [commit] or [cancel].
  bool get inTransaction => _base != null;

  // ---- selection ----

  /// Whether the node with [id] is selected.
  bool isSelected(String id) => _selection.contains(id);

  /// Selects [ids], replacing the selection unless [additive].
  void select(Iterable<String> ids, {bool additive = false}) {
    final next = {
      if (additive) ..._selection,
      for (final id in ids)
        if (_document.contains(id)) id,
    };
    _setSelection(next);
  }

  /// Adds [id] to the selection, or removes it if already selected.
  void toggle(String id) {
    if (!_document.contains(id)) return;
    _setSelection(
      isSelected(id) ? ({..._selection}..remove(id)) : {..._selection, id},
    );
  }

  /// Selects every visible node.
  void selectAll() => select([
    for (final n in _document.nodes)
      if (!n.hidden) n.id,
  ]);

  /// Clears the selection.
  void clearSelection() => _setSelection(const {});

  void _setSelection(Set<String> next) {
    if (setEquals(next, _selection)) return;
    _selection = Set.unmodifiable(next);
    notifyListeners();
  }

  // ---- edits ----

  /// Replaces the document as one undo step.
  ///
  /// An open transaction is committed first, so an outside edit in the
  /// middle of a drag (a toolbar button, say) ends the drag rather than
  /// being overwritten by its next [preview].
  void apply(Document next) {
    if (inTransaction) commit();
    if (next == _document) return;
    _push(_document);
    _redo.clear();
    _setDocument(next);
  }

  /// Starts a transaction: following [preview]s build on the document as
  /// it is now and only become an undo step on [commit].
  void begin() {
    if (inTransaction) commit();
    _base = _document;
  }

  /// Shows `edit(base)` without adding history, where `base` is the
  /// document when [begin] was called. Computing each preview from the base
  /// (not from the last preview) keeps a long drag free of drift.
  ///
  /// Throws a [StateError] outside a transaction. Tools should check
  /// [inTransaction] first: Escape or an outside edit can end it mid-drag.
  void preview(Document Function(Document base) edit) {
    final base = _base;
    if (base == null) {
      throw StateError('preview() needs begin() first');
    }
    _setDocument(edit(base));
  }

  /// Ends the transaction, recording one undo step if anything changed.
  void commit() {
    final base = _base;
    if (base == null) return;
    _base = null;
    if (base != _document) {
      _push(base);
      _redo.clear();
    }
    notifyListeners();
  }

  /// Ends the transaction and restores the document from before [begin].
  void cancel() {
    final base = _base;
    if (base == null) return;
    _base = null;
    _setDocument(base);
  }

  /// Goes back one step.
  void undo() {
    if (!canUndo) return;
    _redo.add(_document);
    _setDocument(_undo.removeLast());
  }

  /// Goes forward one step.
  void redo() {
    if (!canRedo) return;
    _push(_document);
    _setDocument(_redo.removeLast());
  }

  /// Adds [node] (or replaces the node with its id) as one undo step.
  void add(EditorNode node, {bool select = true}) {
    apply(_document.put(node));
    if (select) this.select({node.id});
  }

  /// Moves the unlocked selected nodes by [delta] as one undo step.
  void translateSelection(Point3 delta) =>
      apply(_document.translate(_selection, delta));

  /// Removes the unlocked selected nodes as one undo step.
  void deleteSelection() => apply(_document.removeAll(_selection));

  void _push(Document d) {
    _undo.add(d);
    if (_undo.length > historyLimit) _undo.removeAt(0);
  }

  void _setDocument(Document next) {
    _document = next;
    // Drop ids that no longer exist, e.g. after undoing an add.
    final kept = {
      for (final id in _selection)
        if (next.contains(id)) id,
    };
    if (kept.length != _selection.length) _selection = Set.unmodifiable(kept);
    notifyListeners();
  }
}
