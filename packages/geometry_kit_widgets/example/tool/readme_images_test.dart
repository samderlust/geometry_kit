// Renders the images used in the package READMEs and pubspec screenshots.
//
// Not part of the normal test run (it lives in tool/). Regenerate with:
//
//   cd packages/geometry_kit_widgets/example
//   flutter test tool/readme_images_test.dart
//
// Images are written to `packages/<package>/screenshots/`. They carry no
// text: widget tests render every font as boxes.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geometry_kit/geometry_kit.dart' as gk;
import 'package:geometry_kit_3d/geometry_kit_3d.dart';
import 'package:geometry_kit_editor/geometry_kit_editor.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

/// Logical size of every image; saved at [_pixelRatio]× this.
const _size = Size(800, 400);
const _pixelRatio = 2.0;

const _bg = Color(0xFFF8F9FB);
const _ink = Color(0xFF1F2933);
const _teal = Color(0xFF1F9E8E);
const _blue = Color(0xFF3D6BE0);
const _orange = Color(0xFFE08A2E);
const _red = Color(0xFFD94B4B);
const _purple = Color(0xFF8E5BD6);
const _green = Color(0xFF5BAA4A);
const _grey = Color(0xFF90A4AE);

/// `packages/` from the example directory, where `flutter test` runs.
final _packages = Directory.current.parent.parent;

File _out(String package, String name) =>
    File('${_packages.path}/$package/screenshots/$name.png')
      ..parent.createSync(recursive: true);

Future<void> _savePicture(File file, void Function(Canvas canvas) paint) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(_pixelRatio);
  canvas.drawRect(Offset.zero & _size, Paint()..color = _bg);
  paint(canvas);
  final image = await recorder.endRecording().toImage(
    (_size.width * _pixelRatio).round(),
    (_size.height * _pixelRatio).round(),
  );
  await _writePng(file, image);
}

Future<void> _writePng(File file, ui.Image image) async {
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  file.writeAsBytesSync(bytes!.buffer.asUint8List());
}

/// Pumps [child] at [_size] and saves what it draws.
Future<void> _saveWidget(WidgetTester tester, File file, Widget child) async {
  tester.view.physicalSize = _size * _pixelRatio;
  tester.view.devicePixelRatio = _pixelRatio;
  addTearDown(tester.view.reset);
  final key = GlobalKey();
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RepaintBoundary(
        key: key,
        child: ColoredBox(color: _bg, child: child),
      ),
    ),
  );
  await tester.pump();
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    await _writePng(file, await boundary.toImage(pixelRatio: _pixelRatio));
  });
}

void _paintScene(
  Canvas canvas,
  List<SceneNode> nodes,
  OrbitCamera camera, {
  Rect? area,
}) {
  final r = area ?? Offset.zero & _size;
  canvas.save();
  canvas.translate(r.left, r.top);
  canvas.clipRect(Offset.zero & r.size);
  ScenePainter(
    nodes: nodes,
    camera: camera,
    cache: SceneMeshCache(),
  ).paint(canvas, r.size);
  canvas.restore();
}

List<GeoPath3> _grid(double extent, double step) => GeoPath3.grid(
  extent: extent,
  step: step,
  style: const ShapeStyle.stroked(Color(0x22000000)),
);

ShapeStyle _solidStyle(Color c) => ShapeStyle(
  fillColor: c,
  strokeColor: Color.lerp(c, Colors.black, 0.5),
  strokeWidth: 1,
);

void main() {
  test('geometry_kit: 2D shapes', () async {
    await _savePicture(_out('geometry_kit', 'shapes'), (canvas) {
      Offset o(gk.Point p) => Offset(p.x, p.y);
      Paint fill(Color c) => Paint()..color = c.withValues(alpha: 0.85);
      Paint stroke(Color c, [double w = 3]) => Paint()
        ..color = c
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      Path poly(Iterable<gk.Point> pts, {bool close = true}) {
        final path = Path()..addPolygon([for (final p in pts) o(p)], close);
        return path;
      }

      void dot(gk.Point p, Color c, [double r = 4.5]) {
        canvas.drawCircle(o(p), r, Paint()..color = c);
        canvas.drawCircle(o(p), r, stroke(Colors.white, 1.5));
      }

      // Row 1: circle with a line through it, ellipse, triangle, hexagon.
      const circle = gk.Circle(center: gk.Point(100, 100), radius: 62);
      canvas.drawCircle(o(circle.center), circle.radius, fill(_teal));
      const line = gk.Line(gk.Point(30, 150), gk.Point(175, 45));
      canvas.drawLine(o(line.a), o(line.b), stroke(_ink, 2.5));
      for (final p in circle.getLineIntersections(line)) {
        dot(p, _orange, 6);
      }

      canvas.drawOval(
        Rect.fromCenter(center: const Offset(300, 100), width: 150, height: 92),
        fill(_blue),
      );

      final tri = gk.Triangle(
        gk.Point(500, 40),
        gk.Point(568, 160),
        gk.Point(432, 160),
      );
      canvas.drawPath(poly([tri.a, tri.b, tri.c]), fill(_orange));

      final hex = gk.Polygon.regular(
        center: const gk.Point(700, 100),
        radius: 66,
        sides: 6,
      );
      canvas.drawPath(poly(hex.vertices), fill(_purple));

      // Row 2: arc, ring, capsule, quadratic and cubic Béziers, spline.
      final arc = gk.Arc.fromDegrees(
        center: const gk.Point(100, 300),
        radius: 62,
        startDeg: 200,
        endDeg: 480,
      );
      canvas.drawPath(
        poly([for (var i = 0; i <= 64; i++) arc.pointAt(i / 64)], close: false),
        stroke(_red, 9),
      );

      canvas.drawPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addOval(Rect.fromCircle(center: const Offset(270, 300), radius: 64))
          ..addOval(
            Rect.fromCircle(center: const Offset(270, 300), radius: 36),
          ),
        fill(_green),
      );

      const cap = gk.Capsule(
        medialAxis: gk.Line(gk.Point(380, 340), gk.Point(450, 255)),
        radius: 30,
      );
      canvas.drawLine(
        o(cap.medialAxis.a),
        o(cap.medialAxis.b),
        stroke(_blue.withValues(alpha: 0.85), cap.radius * 2),
      );

      const cubic = gk.CubicBezier(
        start: gk.Point(510, 350),
        control1: gk.Point(520, 220),
        control2: gk.Point(610, 380),
        end: gk.Point(620, 250),
      );
      canvas.drawPath(
        poly([
          cubic.start,
          cubic.control1,
          cubic.control2,
          cubic.end,
        ], close: false),
        stroke(_grey, 1.5),
      );
      canvas.drawPath(
        poly([
          for (var i = 0; i <= 64; i++) cubic.pointAt(i / 64),
        ], close: false),
        stroke(_ink, 4),
      );
      for (final p in [cubic.control1, cubic.control2]) {
        dot(p, _grey);
      }
      for (final p in [cubic.start, cubic.end]) {
        dot(p, _ink);
      }

      final spline = gk.Spline(const [
        gk.Point(660, 330),
        gk.Point(690, 250),
        gk.Point(725, 320),
        gk.Point(755, 245),
        gk.Point(780, 300),
      ]);
      canvas.drawPath(
        poly(spline.sample(80), close: false),
        stroke(_purple, 4),
      );
      for (final p in spline.controlPoints) {
        dot(p, _orange);
      }
    });
  });

  test('geometry_kit_3d: solids and a cone slice', () async {
    await _savePicture(_out('geometry_kit_3d', 'solids'), (canvas) {
      final vase = SolidOfRevolution(const [
        gk.Point(0.3, 0),
        gk.Point(0.5, 0.35),
        gk.Point(0.22, 0.95),
        gk.Point(0.32, 1.25),
      ]);
      final lShape = Prism.extrude(
        gk.Polygon(const [
          gk.Point(0, 0),
          gk.Point(0.9, 0),
          gk.Point(0.9, 0.35),
          gk.Point(0.35, 0.35),
          gk.Point(0.35, 0.9),
          gk.Point(0, 0.9),
        ]),
        height: 0.5,
      );
      _paintScene(
        canvas,
        [
          ..._grid(3, 0.5),
          GeoSolid(
            Box.fromBase(
              center: const Point3(-2, 0, 0.3),
              width: 0.9,
              depth: 0.9,
              height: 0.9,
            ),
            style: _solidStyle(_teal),
          ),
          GeoSolid(
            const Sphere(center: Point3(-0.8, 0.5, 0.6), radius: 0.5),
            style: const ShapeStyle.filled(_blue),
          ),
          GeoSolid(
            Cylinder(
              baseCenter: const Point3(0.4, 0, 0.4),
              radius: 0.4,
              height: 1.1,
            ),
            style: _solidStyle(_orange),
          ),
          GeoSolid(
            Cone(
              baseCenter: const Point3(1.6, 0, 0.3),
              radius: 0.45,
              height: 1.2,
            ),
            style: _solidStyle(_red),
          ),
          GeoSolid(
            vase,
            transform: const Transform3(position: Point3(-1.4, 0, -1.2)),
            style: const ShapeStyle.filled(_purple),
            segments: 48,
          ),
          GeoSolid(
            lShape,
            transform: const Transform3(position: Point3(0.2, 0, -1)),
            style: _solidStyle(_green),
          ),
        ],
        const OrbitCamera(
          yaw: 28,
          pitch: 26,
          distance: 5.6,
          target: Point3(-0.3, 0.4, -0.2),
        ),
        area: const Rect.fromLTWH(0, 0, 520, 400),
      );

      // A cone cut by a tilted plane: the ellipse cross-section.
      final cone = Cone(baseCenter: Point3.zero, radius: 0.8, height: 2);
      final plane = Plane.fromPointNormal(
        const Point3(0, 0.8, 0),
        const Point3(0.35, 1, 0),
      );
      final section = cone.slice(plane);
      _paintScene(
        canvas,
        [
          ..._grid(1.5, 0.5),
          GeoSolid(
            cone,
            style: const ShapeStyle(
              fillColor: _grey,
              strokeColor: Color(0xFF455A64),
              opacity: 0.45,
            ),
          ),
          GeoPath3(
            section.toPoints3(),
            closed: true,
            style: const ShapeStyle(
              fillColor: Color(0x55E08A2E),
              strokeColor: _orange,
              strokeWidth: 3,
            ),
          ),
        ],
        const OrbitCamera(
          yaw: 25,
          pitch: 18,
          distance: 5.2,
          target: Point3(0, 0.9, 0),
        ),
        area: const Rect.fromLTWH(520, 0, 280, 400),
      );
    });
  });

  testWidgets('geometry_kit_widgets: 2D widgets', (tester) async {
    await _saveWidget(
      tester,
      _out('geometry_kit_widgets', 'widgets_2d'),
      GeometryCanvas(
        size: _size,
        shapes: [
          StyledShape(
            const gk.Circle(center: gk.Point(120, 140), radius: 80),
            style: const ShapeStyle(
              fillGradient: RadialGradient(colors: [_orange, _red]),
            ),
          ),
          StyledShape(
            gk.Rectangle.fromCenter(
              center: const gk.Point(330, 140),
              width: 180,
              height: 120,
            ),
            style: ShapeStyle(
              fillGradient: const LinearGradient(colors: [_teal, _blue]),
              strokeColor: _ink,
              strokeWidth: 3,
              dashPattern: const DashPattern([10, 6]),
            ),
          ),
          StyledShape(
            gk.Triangle(
              const gk.Point(540, 60),
              const gk.Point(630, 220),
              const gk.Point(450, 220),
            ),
            style: const ShapeStyle(
              fillColor: _purple,
              strokeColor: _ink,
              strokeWidth: 3,
            ),
          ),
          StyledShape(
            gk.Polygon.regular(
              center: const gk.Point(720, 140),
              radius: 64,
              sides: 5,
            ),
            style: const ShapeStyle(
              fillGradient: SweepGradient(
                colors: [_teal, _orange, _purple, _teal],
              ),
            ),
          ),
          StyledShape(
            const gk.Ellipse(
              center: gk.Point(230, 320),
              radiusX: 150,
              radiusY: 50,
            ),
            style: const ShapeStyle(
              fillColor: Color(0x553D6BE0),
              strokeColor: _blue,
              strokeWidth: 3,
            ),
          ),
          StyledShape(
            const gk.Quadrilateral(
              gk.Point(440, 280),
              gk.Point(600, 270),
              gk.Point(640, 370),
              gk.Point(470, 360),
            ),
            style: const ShapeStyle(
              fillColor: Color(0x335BAA4A),
              strokeColor: _green,
              strokeWidth: 3,
            ),
          ),
          const StyledShape(
            gk.Circle(center: gk.Point(725, 320), radius: 48),
            style: ShapeStyle(
              strokeColor: _ink,
              strokeWidth: 4,
              dashPattern: DashPattern([0.1, 10]),
              strokeCap: StrokeCap.round,
            ),
          ),
        ],
      ),
    );
  });

  test('geometry_kit_widgets: GeoScene', () async {
    await _savePicture(_out('geometry_kit_widgets', 'scene'), (canvas) {
      // A small bar chart standing on a floor grid.
      const heights = [0.6, 1.1, 0.8, 1.6, 1.3, 2.0];
      const colors = [_teal, _blue, _purple, _orange, _red, _green];
      _paintScene(
        canvas,
        [
          ..._grid(3, 0.5),
          for (var i = 0; i < heights.length; i++)
            GeoSolid(
              Box.fromBase(
                center: Point3(-1.75 + i * 0.7, 0, 0),
                width: 0.5,
                depth: 0.5,
                height: heights[i],
              ),
              style: _solidStyle(colors[i]),
            ),
          GeoPath3(
            [
              for (var i = 0; i < heights.length; i++)
                Point3(-1.75 + i * 0.7, heights[i] + 0.25, 0),
            ],
            style: const ShapeStyle(
              strokeColor: _ink,
              strokeWidth: 2,
              dashPattern: DashPattern([6, 5]),
            ),
          ),
          for (var i = 0; i < heights.length; i++)
            GeoHandle(
              Point3(-1.75 + i * 0.7, heights[i] + 0.25, 0),
              id: 'bar-$i',
              radius: 5,
            ),
        ],
        const OrbitCamera(
          yaw: 18,
          pitch: 22,
          distance: 4.6,
          target: Point3(0.1, 0.9, 0),
        ),
      );
    });
  });

  test('geometry_kit_widgets: solid gradients', () async {
    await _savePicture(_out('geometry_kit_widgets', 'gradients'), (canvas) {
      _paintScene(
        canvas,
        [
          ..._grid(3, 0.5),
          GeoSolid(
            Box.fromBase(
              center: const Point3(-1.9, 0, 0),
              width: 1,
              depth: 1,
              height: 1,
            ),
            style: const ShapeStyle(strokeColor: _ink),
            gradient: const SolidGradient.linear(colors: [_teal, _purple]),
          ),
          GeoSolid(
            Box.fromBase(
              center: const Point3(-0.5, 0, 0),
              width: 1,
              depth: 1,
              height: 1,
            ),
            style: const ShapeStyle(strokeColor: _ink),
            gradient: const SolidGradient.linear(
              start: Anchor3.topLeftFront,
              end: Anchor3.bottomRightBack,
              colors: [_teal, _orange, _purple],
            ),
          ),
          GeoSolid(
            Cylinder(
              baseCenter: const Point3(0.85, 0, 0),
              radius: 0.45,
              height: 1.3,
            ),
            style: const ShapeStyle(strokeColor: _ink),
            gradient: const SolidGradient.radial(colors: [_orange, _red]),
            segments: 48,
          ),
          GeoSolid(
            const Sphere(center: Point3(2.1, 0.55, 0), radius: 0.55),
            gradient: const SolidGradient.radial(colors: [_orange, _purple]),
            segments: 48,
          ),
        ],
        const OrbitCamera(
          yaw: 22,
          pitch: 22,
          distance: 4.6,
          target: Point3(0.1, 0.5, 0),
        ),
      );
    });
  });

  testWidgets('geometry_kit_editor: editor', (tester) async {
    final editor = EditorController(
      document: Document([
        EditorNode(
          id: 'crate',
          solid: Box.cube(center: Point3.zero, size: 1),
          transform: const Transform3(position: Point3(-1.3, 0.5, 0.2)),
          style: _solidStyle(_orange),
        ),
        EditorNode(
          id: 'drum',
          solid: Cylinder(baseCenter: Point3.zero, radius: 0.4, height: 1.2),
          transform: const Transform3(position: Point3(0.9, 0, -0.7)),
          style: _solidStyle(_blue),
        ),
        EditorNode(
          id: 'ball',
          solid: const Sphere(center: Point3.zero, radius: 0.45),
          transform: const Transform3(position: Point3(0.4, 0.45, 0.9)),
          gradient: const SolidGradient.radial(colors: [_green, _purple]),
        ),
        EditorNode(
          id: 'pillar',
          solid: Box.fromBase(
            center: Point3.zero,
            width: 0.4,
            depth: 0.4,
            height: 1.6,
          ),
          transform: Transform3(
            position: const Point3(-0.2, 0, -1.2),
            rotation: Quaternion.fromAxisAngle(Point3.unitY, 25),
          ),
          gradient: const SolidGradient.linear(colors: [_teal, _blue]),
          locked: true,
        ),
      ]),
    );
    addTearDown(editor.dispose);
    editor.select({'crate', 'ball'});
    await _saveWidget(
      tester,
      _out('geometry_kit_editor', 'editor'),
      EditorScene(
        controller: editor,
        camera: const OrbitCamera(
          yaw: 30,
          pitch: 28,
          distance: 5.2,
          target: Point3(-0.1, 0.5, 0),
        ),
        size: _size,
        background: _grid(3, 0.5),
      ),
    );
  });
}
