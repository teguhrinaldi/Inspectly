// Dev helper: prints the median color of a 3x3 patch at mockup coordinates.
// Usage: dart run tool/sample_colors.dart name:x,y name:x,y ...
import 'dart:io';

import 'package:image/image.dart' as img;

void main(List<String> args) {
  final src = img.decodePng(
    File('../docs/design/inspectly_master_mockup.png').readAsBytesSync(),
  )!;
  for (final a in args) {
    final parts = a.split(':');
    final xy = parts[1].split(',').map(int.parse).toList();
    final rs = <int>[], gs = <int>[], bs = <int>[];
    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        final p = src.getPixel(xy[0] + dx, xy[1] + dy);
        rs.add(p.r.toInt());
        gs.add(p.g.toInt());
        bs.add(p.b.toInt());
      }
    }
    int med(List<int> l) => (l..sort())[l.length ~/ 2];
    String h(int v) => v.toRadixString(16).padLeft(2, '0').toUpperCase();
    // ignore: avoid_print
    print('${parts[0].padRight(16)} #${h(med(rs))}${h(med(gs))}${h(med(bs))}');
  }
}
