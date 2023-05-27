import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

const maxPoints = 16;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 500,
          width: 500,
          child: Mesh(
            points: [
              (Offset(0.25, 0.25), Colors.red),
              (Offset(0.25, 0.75), Colors.green),
              (Offset(0.75, 0.25), Colors.blue),
              (Offset(0.75, 0.75), Colors.yellow),
            ],
          ),
        ),
      ),
    );
  }
}

class Mesh extends StatelessWidget {
  const Mesh({
    super.key,
    required this.points,
  });

  /// The normalized points and the color they are assigned.
  ///
  /// Normalized means the offsets are between 0 and 1, i.e. a fraction
  /// of the width and height of the canvas.
  final List<(Offset, Color)> points;

  @override
  Widget build(BuildContext context) {
    return ShaderBuilder(
      (context, shader, child) {
        return CustomPaint(
          painter: MeshPainter(
            shader,
            points,
          ),
        );
      },
      assetKey: 'shaders/mesh.frag',
    );
  }
}

class MeshPainter extends CustomPainter {
  MeshPainter(this.shader, this.points);

  final FragmentShader shader;

  final List<(Offset, Color)> points;

  @override
  void paint(Canvas canvas, Size size) {
    var i = 0;
    assert(
      points.length <= maxPoints,
      'Too many points in mesh (max $maxPoints, got ${points.length}',
    );

    shader.setFloat(i++, size.width);
    shader.setFloat(i++, size.height);

    for (var p = 0; p < maxPoints; p++) {
      var x = points.elementAtOrNull(p)?.$1.dx;
      var y = points.elementAtOrNull(p)?.$1.dy;

      assert(x == null || (x >= 0 && x <= 1),
          'x must be between 0 and 1 (was $x)');
      assert(y == null || (y >= 0 && y <= 1),
          'y must be between 0 and 1 (was $y)');

      shader.setFloat(i++, x ?? -1);
      shader.setFloat(i++, y ?? -1);
    }

    for (var p = 0; p < maxPoints; p++) {
      final color = points.elementAtOrNull(p)?.$2 ?? Colors.transparent;
      shader.setFloat(i++, color.red / 255);
      shader.setFloat(i++, color.green / 255);
      shader.setFloat(i++, color.blue / 255);
      shader.setFloat(i++, color.alpha / 255);
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(MeshPainter oldDelegate) {
    return true;
  }
}
