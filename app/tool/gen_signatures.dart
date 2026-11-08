// One-off generator for the two placeholder demo signature images referenced
// by lib/data/datasources/demo/demo_inspections_seed.dart. Run with:
//   dart run tool/gen_signatures.dart
// These are abstract stroke drawings, not a depiction of any real person's
// actual signature — see docs/assets.md.
import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

void main() {
  _generate('assets/images/demo/signature_inspector.png', seed: 1);
  _generate('assets/images/demo/signature_customer.png', seed: 2);
  // ignore: avoid_print
  print('Generated placeholder signatures.');
}

void _generate(String path, {required int seed}) {
  final image = img.Image(width: 600, height: 200, numChannels: 4);
  img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));

  final rnd = Random(seed);
  final ink = img.ColorRgba8(20, 25, 35, 255);

  // Draw a handful of overlapping cursive-like wave strokes to suggest a
  // signature without depicting any real person's handwriting.
  for (var stroke = 0; stroke < 3; stroke++) {
    final baseY = 90.0 + stroke * 12 + rnd.nextDouble() * 10;
    final amplitude = 30.0 + rnd.nextDouble() * 20;
    final frequency = 0.03 + rnd.nextDouble() * 0.02;
    final xStart = 40.0 + stroke * 30;
    final xEnd = 560.0 - stroke * 20;

    img.Point? prev;
    for (var x = xStart; x <= xEnd; x += 4) {
      final y =
          baseY +
          sin((x - xStart) * frequency * 2 * pi + stroke) *
              amplitude *
              (0.6 + 0.4 * sin(x * 0.01));
      final point = img.Point(x, y);
      if (prev != null) {
        img.drawLine(
          image,
          x1: prev.xi,
          y1: prev.yi,
          x2: point.xi,
          y2: point.yi,
          color: ink,
          thickness: 3,
        );
      }
      prev = point;
    }
  }

  File(path).writeAsBytesSync(img.encodePng(image));
}
