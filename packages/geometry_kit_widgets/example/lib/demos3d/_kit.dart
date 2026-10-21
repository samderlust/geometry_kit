import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

const _mono = 'monospace';
const _monoFallback = ['Menlo', 'Courier New', 'Courier'];

/// Drafting-table palette shared by the 3D demos, in light and dark.
class DemoPalette {
  final Color bg, surface, fg, muted, line, grid, accent, amber, teal, codeBg;
  final Color danger;

  const DemoPalette._({
    required this.bg,
    required this.surface,
    required this.fg,
    required this.muted,
    required this.line,
    required this.grid,
    required this.accent,
    required this.amber,
    required this.teal,
    required this.codeBg,
    required this.danger,
  });

  static const light = DemoPalette._(
    bg: Color(0xFFF3F5F8),
    surface: Color(0xFFFFFFFF),
    fg: Color(0xFF131821),
    muted: Color(0xFF586274),
    line: Color(0xFFD6DCE6),
    grid: Color(0xFFDCE2EA),
    accent: Color(0xFF2A56D6),
    amber: Color(0xFFD47D22),
    teal: Color(0xFF178F80),
    codeBg: Color(0xFFEDF0F5),
    danger: Color(0xFFD64040),
  );

  static const dark = DemoPalette._(
    bg: Color(0xFF0D1015),
    surface: Color(0xFF141920),
    fg: Color(0xFFE4E8EF),
    muted: Color(0xFF8A94A6),
    line: Color(0xFF252C37),
    grid: Color(0xFF252C37),
    accent: Color(0xFF7B98FF),
    amber: Color(0xFFF0A14F),
    teal: Color(0xFF3CC3B0),
    codeBg: Color(0xFF10151B),
    danger: Color(0xFFE05555),
  );

  static DemoPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  /// Floor grid in the palette's grid colour, drawn under the solids.
  List<GeoPath3> grid3({double extent = 3, double step = 0.5, double y = 0}) =>
      GeoPath3.grid(
        extent: extent,
        step: step,
        y: y,
        style: ShapeStyle.stroked(grid),
      );

  TextStyle mono(double size, {Color? color, FontWeight? weight}) => TextStyle(
    fontFamily: _mono,
    fontFamilyFallback: _monoFallback,
    fontSize: size,
    color: color ?? fg,
    fontWeight: weight,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  TextStyle label3(Color color, {double size = 11, FontWeight? weight}) =>
      mono(size, color: color, weight: weight ?? FontWeight.w600);
}

/// A 3D demo screen: the live demo panel, then the code that builds it.
class Demo3dPage extends StatelessWidget {
  final Widget demo;
  final String code;

  const Demo3dPage({super.key, required this.demo, required this.code});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // Keep the panel a comfortable size on tablets and desktop.
        final side = (c.maxWidth - 720).clamp(0.0, double.infinity) / 2;
        return ListView(
          padding: EdgeInsets.fromLTRB(16 + side, 12, 16 + side, 32),
          children: [demo, const SizedBox(height: 16), CodeBlock(code)],
        );
      },
    );
  }
}

/// Bordered demo card: status bar, scene, controls and readouts.
class DemoPanel extends StatelessWidget {
  final String label;
  final String hint;
  final Widget scene;
  final List<Widget> controls;
  final List<Readout> readouts;
  final Widget? footer;

  const DemoPanel({
    super.key,
    required this.label,
    required this.hint,
    required this.scene,
    this.controls = const [],
    this.readouts = const [],
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final p = DemoPalette.of(context);
    Widget divider() => Divider(height: 1, thickness: 1, color: p.line);
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: p.teal,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(label, style: p.mono(11, color: p.muted)),
                ),
                Text(hint, style: p.mono(11, color: p.muted)),
              ],
            ),
          ),
          divider(),
          AspectRatio(aspectRatio: 4 / 3, child: scene),
          if (controls.isNotEmpty) ...[
            divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: Column(children: controls),
            ),
          ],
          if (readouts.isNotEmpty) ...[divider(), ReadoutGrid(readouts)],
          if (footer != null) ...[divider(), footer!],
        ],
      ),
    );
  }
}

/// One label/value cell in a [ReadoutGrid].
class Readout {
  final String label;
  final String value;
  final bool highlight;
  const Readout(this.label, this.value, {this.highlight = false});
}

class ReadoutGrid extends StatelessWidget {
  final List<Readout> items;
  const ReadoutGrid(this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = DemoPalette.of(context);
    return LayoutBuilder(
      builder: (context, c) {
        final cols = (c.maxWidth / 140).floor().clamp(1, items.length);
        // The last row's cells stretch so no empty cell is left over.
        final lastRow = items.length % cols;
        final firstOfLast = items.length - lastRow;
        double widthOf(int i) =>
            c.maxWidth / (lastRow != 0 && i >= firstOfLast ? lastRow : cols);
        return Wrap(
          children: [
            for (final (i, r) in items.indexed)
              Container(
                width: widthOf(i),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: p.line),
                    bottom: BorderSide(color: p.line),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.label.toUpperCase(),
                      style: p
                          .mono(10, color: p.muted)
                          .copyWith(letterSpacing: 0.6),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      r.value,
                      style: p.mono(
                        14,
                        color: r.highlight ? p.amber : p.fg,
                        weight: r.highlight ? FontWeight.w600 : null,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Slider with a label and a live value, like the artifact controls.
class DemoSlider extends StatelessWidget {
  final String label;
  final String display;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  const DemoSlider({
    super.key,
    required this.label,
    required this.display,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
  });

  @override
  Widget build(BuildContext context) {
    final p = DemoPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 13, color: p.muted),
              ),
            ),
            Text(display, style: p.mono(13)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: p.accent,
            thumbColor: p.accent,
            inactiveTrackColor: p.line,
            trackHeight: 3,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

/// Small checkbox row.
class DemoToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const DemoToggle({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = DemoPalette.of(context);
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Checkbox(
            value: value,
            activeColor: p.accent,
            onChanged: (v) => onChanged(v ?? false),
          ),
          Text(label, style: TextStyle(fontSize: 13, color: p.fg)),
        ],
      ),
    );
  }
}

/// Monospace chip naming an API type.
class CodeChip extends StatelessWidget {
  final String text;
  const CodeChip(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = DemoPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: p.codeBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: p.line),
      ),
      child: Text(text, style: p.mono(11.5)),
    );
  }
}

/// Coloured legend entry.
class LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const LegendDot(this.color, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = DemoPalette.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: p.muted)),
      ],
    );
  }
}

/// Code listing with light Dart highlighting and a copy button.
class CodeBlock extends StatelessWidget {
  final String code;
  const CodeBlock(this.code, {super.key});

  static final _token = RegExp(
    r"(//[^\n]*)|('[^'\n]*')|(\b\d+(?:\.\d+)?\b)|(\b[A-Za-z_]\w*\b)",
  );
  static const _keywords = {
    'final',
    'const',
    'var',
    'for',
    'in',
    'if',
    'else',
    'return',
    'switch',
    'import',
    'true',
    'false',
    'null',
    'class',
    'void',
    'async',
    'await',
    'new',
    'case',
    'default',
    'is',
    'as',
  };

  List<TextSpan> _highlight(DemoPalette p) {
    final spans = <TextSpan>[];
    var last = 0;
    for (final m in _token.allMatches(code)) {
      if (m.start > last) {
        spans.add(TextSpan(text: code.substring(last, m.start)));
      }
      final t = m.group(0)!;
      TextStyle? style;
      if (m.group(1) != null) {
        style = TextStyle(color: p.muted, fontStyle: FontStyle.italic);
      } else if (m.group(2) != null) {
        style = TextStyle(color: p.teal);
      } else if (m.group(3) != null) {
        style = TextStyle(color: p.amber);
      } else if (_keywords.contains(t)) {
        style = TextStyle(color: p.accent);
      } else if (t[0].toUpperCase() == t[0] && t[0] != '_') {
        style = const TextStyle(fontWeight: FontWeight.w600);
      }
      spans.add(TextSpan(text: t, style: style));
      last = m.end;
    }
    if (last < code.length) spans.add(TextSpan(text: code.substring(last)));
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final p = DemoPalette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: p.codeBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.line),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
            child: Text.rich(
              TextSpan(children: _highlight(p)),
              style: p.mono(12.5).copyWith(height: 1.55),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Row(
              children: [
                Text(
                  'API',
                  style: p
                      .mono(10, color: p.muted)
                      .copyWith(letterSpacing: 0.8),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 16,
                  color: p.muted,
                  tooltip: 'Copy code',
                  icon: const Icon(Icons.copy),
                  onPressed: () => Clipboard.setData(ClipboardData(text: code)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Wireframe edges of an axis-aligned box, as dashed overlay paths.
List<GeoPath3> aabbEdges(Aabb b, Color color) {
  final c = b.corners; // index bits: x*4 + y*2 + z
  const edges = [
    [0, 1], [2, 3], [4, 5], [6, 7], // along z
    [0, 2], [1, 3], [4, 6], [5, 7], // along y
    [0, 4], [1, 5], [2, 6], [3, 7], // along x
  ];
  return [
    for (final e in edges)
      GeoPath3(
        [c[e[0]], c[e[1]]],
        style: ShapeStyle(
          strokeColor: color,
          dashPattern: const DashPattern([3, 3]),
        ),
      ),
  ];
}

/// Builds the [GeoScene] for a demo panel.
typedef SceneBuilder =
    Widget Function(
      OrbitCamera camera,
      ValueChanged<OrbitCamera> onCameraChanged,
    );

/// Hosts a [GeoScene] with zoom in, zoom out and reset buttons.
///
/// Keeps the camera as state and hands it to [builder], so the buttons and
/// the scene's own drag and pinch gestures move the same camera.
class ZoomScene extends StatefulWidget {
  /// Starting camera; reset returns here.
  final OrbitCamera camera;

  /// Builds the scene from the current camera.
  final SceneBuilder builder;

  const ZoomScene({super.key, required this.camera, required this.builder});

  @override
  State<ZoomScene> createState() => _ZoomSceneState();
}

class _ZoomSceneState extends State<ZoomScene> {
  late OrbitCamera _initial = _withLimits(widget.camera);
  late OrbitCamera _camera = _initial;

  // Zoom range relative to the starting distance.
  static OrbitCamera _withLimits(OrbitCamera c) =>
      c.copyWith(minDistance: c.distance * 0.15, maxDistance: c.distance * 4);

  @override
  void didUpdateWidget(ZoomScene old) {
    super.didUpdateWidget(old);
    if (old.camera != widget.camera) {
      _initial = _withLimits(widget.camera);
      _camera = _initial;
    }
  }

  void _set(OrbitCamera c) => setState(() => _camera = c);

  @override
  Widget build(BuildContext context) {
    final p = DemoPalette.of(context);
    Widget button(IconData icon, String tip, VoidCallback onTap) => IconButton(
      icon: Icon(icon, size: 18),
      tooltip: tip,
      color: p.fg,
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
    );
    return Stack(
      children: [
        Positioned.fill(child: widget.builder(_camera, _set)),
        Positioned(
          right: 8,
          bottom: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: p.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: p.line),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                button(Icons.add, 'Zoom in', () => _set(_camera.zoom(0.8))),
                button(
                  Icons.remove,
                  'Zoom out',
                  () => _set(_camera.zoom(1.25)),
                ),
                button(
                  Icons.center_focus_strong_outlined,
                  'Reset view',
                  () => _set(_initial),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
