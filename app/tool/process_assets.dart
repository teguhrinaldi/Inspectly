// Dev helper: crops the downloaded Pexels source photos (see docs/assets.md)
// into the aspect ratios the UI uses. Usage:
//   dart run tool/process_assets.dart <raw_dir>
import 'dart:io';

import 'package:image/image.dart' as img;

void main(List<String> args) {
  final raw = args[0];

  img.Image load(String name) =>
      img.decodeJpg(File('$raw/$name').readAsBytesSync())!;

  void save(img.Image image, String path, {int quality = 86}) {
    File(path).parent.createSync(recursive: true);
    File(path).writeAsBytesSync(img.encodeJpg(image, quality: quality));
  }

  /// Square crop centered at (cx, cy) as fractions, [size] as a fraction of
  /// the shorter side, resized to [out] px.
  img.Image square(img.Image src, double cx, double cy, double size, int out) {
    final side = (src.width < src.height ? src.width : src.height) * size;
    var x = (src.width * cx - side / 2).round().clamp(
      0,
      src.width - side.round(),
    );
    var y = (src.height * cy - side / 2).round().clamp(
      0,
      src.height - side.round(),
    );
    final c = img.copyCrop(
      src,
      x: x,
      y: y,
      width: side.round(),
      height: side.round(),
    );
    return img.copyResize(
      c,
      width: out,
      height: out,
      interpolation: img.Interpolation.cubic,
    );
  }

  /// Crop to [ratio] (w/h) centered at (cx, cy), resized to [outW].
  img.Image ratio(img.Image src, double r, double cx, double cy, int outW) {
    var w = src.width.toDouble();
    var h = w / r;
    if (h > src.height) {
      h = src.height.toDouble();
      w = h * r;
    }
    final x = (src.width * cx - w / 2).round().clamp(
      0,
      (src.width - w).round(),
    );
    final y = (src.height * cy - h / 2).round().clamp(
      0,
      (src.height - h).round(),
    );
    final c = img.copyCrop(
      src,
      x: x,
      y: y,
      width: w.round(),
      height: h.round(),
    );
    return img.copyResize(
      c,
      width: outW,
      interpolation: img.Interpolation.cubic,
    );
  }

  const a = 'assets/images';

  // Splash hero: portrait crop keeping the inspector + tablet.
  save(
    ratio(load('hero2.jpg'), 0.47, 0.42, 0.5, 1000),
    '$a/demo/hero_inspector.jpg',
    quality: 88,
  );

  // Avatars (face-centered squares).
  save(
    square(load('av_michael.jpg'), 0.49, 0.24, 0.42, 256),
    '$a/avatars/michael_carter.jpg',
  );
  save(
    square(load('av_sarah.jpg'), 0.49, 0.45, 0.92, 256),
    '$a/avatars/sarah_johnson.jpg',
  );
  save(
    square(load('av_daniel.jpg'), 0.5, 0.4, 0.8, 256),
    '$a/avatars/daniel_brooks.jpg',
  );
  save(
    square(load('av_admin.jpg'), 0.47, 0.5, 0.95, 256),
    '$a/avatars/admin.jpg',
  );

  // Evidence photos, 4:3.
  save(
    ratio(load('ev_pipe.jpg'), 4 / 3, 0.5, 0.42, 1000),
    '$a/evidence/leaking_pipe.jpg',
  );
  save(
    ratio(load('ev_exit.jpg'), 4 / 3, 0.5, 0.5, 1000),
    '$a/evidence/blocked_exit.jpg',
  );
  save(
    ratio(load('ev_roof.jpg'), 4 / 3, 0.5, 0.5, 1000),
    '$a/evidence/roof_damage.jpg',
  );
  save(
    ratio(load('ev_panel2.jpg'), 4 / 3, 0.5, 0.5, 1000),
    '$a/evidence/electrical_panel_current.jpg',
  );
  save(
    ratio(load('ev_control.jpg'), 4 / 3, 0.4, 0.5, 1000),
    '$a/evidence/electrical_room.jpg',
  );

  save(
    ratio(load('ev_pipe2.jpg'), 4 / 3, 0.5, 0.42, 1000),
    '$a/evidence/leaking_pipe_2.jpg',
  );
  save(
    ratio(load('ev_roof2.jpg'), 4 / 3, 0.5, 0.18, 1000),
    '$a/evidence/roof_damage_2.jpg',
  );
  save(
    ratio(load('ev_wiring.jpg'), 4 / 3, 0.45, 0.22, 1000),
    '$a/evidence/exposed_wiring.jpg',
  );

  save(
    ratio(load('site_riverside.jpg'), 3 / 2, 0.5, 0.45, 1200),
    '$a/sites/riverside_office_complex.jpg',
  );

  save(
    ratio(load('ev_smoke.jpg'), 4 / 3, 0.5, 0.5, 1000),
    '$a/evidence/smoke_detector.jpg',
  );
  save(
    ratio(load('ev_ceiling.jpg'), 4 / 3, 0.5, 0.25, 1000),
    '$a/evidence/water_stained_ceiling.jpg',
  );
  save(
    ratio(load('ev_exitsign.jpg'), 4 / 3, 0.5, 0.3, 1000),
    '$a/evidence/exit_sign.jpg',
  );
  save(
    ratio(load('ev_pipe3.jpg'), 4 / 3, 0.5, 0.35, 1000),
    '$a/evidence/leaking_pipe_3.jpg',
  );

  // Oakwood Medical Center site cover, 3:2.
  final oak = load('site_oakwood.jpg');
  save(
    img.copyResize(
      img.copyCrop(oak, x: 0, y: oak.height - 540, width: 810, height: 540),
      width: 1200,
      interpolation: img.Interpolation.cubic,
    ),
    '$a/sites/oakwood_medical_center.jpg',
  );

  // ignore: avoid_print
  print('Processed assets.');
}
