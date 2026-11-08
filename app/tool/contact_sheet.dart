// Dev helper: tiles every .jpg/.png in a directory into one labeled grid
// image, for comparing candidate stock photos side by side.
// Usage: dart run tool/contact_sheet.dart <dir> <out.png>
import 'dart:io';

import 'package:image/image.dart' as img;

void main(List<String> args) {
  final dir = Directory(args[0]);
  final files =
      dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.png'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  const cell = 300;
  const cols = 3;
  final rows = (files.length / cols).ceil();
  final sheet = img.Image(width: cols * cell, height: rows * (cell + 20));
  img.fill(sheet, color: img.ColorRgb8(255, 255, 255));
  for (var i = 0; i < files.length; i++) {
    final decoded = img.decodeImage(files[i].readAsBytesSync());
    if (decoded == null) continue;
    final thumb = img.copyResize(
      decoded,
      width: decoded.width >= decoded.height ? cell : null,
      height: decoded.height > decoded.width ? cell : null,
    );
    final x = (i % cols) * cell;
    final y = (i ~/ cols) * (cell + 20);
    img.compositeImage(sheet, thumb, dstX: x, dstY: y + 20);
    img.drawString(
      sheet,
      files[i].uri.pathSegments.last,
      font: img.arial14,
      x: x + 4,
      y: y + 2,
      color: img.ColorRgb8(0, 0, 0),
    );
  }
  File(args[1]).writeAsBytesSync(img.encodePng(sheet));
}
