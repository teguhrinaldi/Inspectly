// Crops the master mockup into per-screen images (upscaled) for detailed
// visual reference. Run: dart run tool/crop_mockup.dart
import 'dart:io';

import 'package:image/image.dart' as img;

const _regions = <String, List<int>>{
  // name: [x, y, w, h]
  '00_header': [15, 15, 265, 375],
  '01_splash': [284, 34, 148, 333],
  '02_home': [432, 34, 150, 333],
  '03_list': [580, 34, 148, 333],
  '04_detail': [728, 34, 152, 333],
  '05_checklist': [882, 30, 146, 337],
  '06_findings': [1028, 30, 144, 337],
  '07_evidence': [1172, 30, 122, 337],
  '08_signature': [1293, 30, 104, 337],
  '09_qr': [1396, 30, 124, 337],
  '10_admin': [24, 405, 590, 378],
  '11_template': [616, 405, 362, 375],
  '12_comparison': [976, 405, 272, 375],
  '13_risk': [1246, 405, 272, 375],
  '14_footer': [20, 812, 1500, 210],
};

void main() {
  final src = img.decodePng(
    File('../docs/design/inspectly_master_mockup.png').readAsBytesSync(),
  )!;
  final outDir = Directory('../docs/design/crops')..createSync(recursive: true);
  for (final entry in _regions.entries) {
    final r = entry.value;
    final crop = img.copyCrop(src, x: r[0], y: r[1], width: r[2], height: r[3]);
    final scale = r[2] < 400 ? 4 : 2;
    final up = img.copyResize(
      crop,
      width: crop.width * scale,
      interpolation: img.Interpolation.cubic,
    );
    File('${outDir.path}/${entry.key}.png').writeAsBytesSync(img.encodePng(up));
  }
  // ignore: avoid_print
  print('Wrote ${_regions.length} crops to ${outDir.path}');
}
