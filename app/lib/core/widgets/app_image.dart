import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/app_colors.dart';

/// Renders a photo from a bundled asset, a remote URL or a local file path —
/// the three places evidence, site covers and avatars can come from.
class AppImage extends StatelessWidget {
  const AppImage(
    this.source, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholderIcon = LucideIcons.image,
    this.alignment = Alignment.center,
  });

  final String? source;
  final BoxFit fit;
  final double? width;
  final double? height;
  final IconData placeholderIcon;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final src = source;
    Widget placeholder(BuildContext context, [Object? _, StackTrace? _]) {
      final p = context.palette;
      return Container(
        width: width,
        height: height,
        color: p.surfaceAlt,
        alignment: Alignment.center,
        child: Icon(placeholderIcon, color: p.textMuted, size: 22),
      );
    }

    if (src == null || src.isEmpty) return placeholder(context);
    // Decode at roughly the size shown instead of the full photo (a 2000 px
    // camera image in an 80 px thumbnail): 2x the longest side leaves room
    // for a "cover" crop of up to 2:1 without blur (QC-042).
    return LayoutBuilder(
      builder: (context, box) {
        final w = width ?? (box.hasBoundedWidth ? box.maxWidth : null);
        final h = height ?? (box.hasBoundedHeight ? box.maxHeight : null);
        final side = [w, h].whereType<double>().fold<double>(0, math.max);
        final cache = side > 0 && side.isFinite
            ? (side * MediaQuery.devicePixelRatioOf(context) * 2).round()
            : null;
        return _image(src, cache, placeholder);
      },
    );
  }

  Widget _image(
    String src,
    int? cacheWidth,
    Widget Function(BuildContext, [Object?, StackTrace?]) placeholder,
  ) {
    if (src.startsWith('assets/')) {
      return Image.asset(
        src,
        fit: fit,
        width: width,
        height: height,
        alignment: alignment,
        cacheWidth: cacheWidth,
        errorBuilder: placeholder,
      );
    }
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return Image.network(
        src,
        fit: fit,
        width: width,
        height: height,
        alignment: alignment,
        cacheWidth: cacheWidth,
        errorBuilder: placeholder,
      );
    }
    return Image.file(
      File(src),
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      cacheWidth: cacheWidth,
      errorBuilder: placeholder,
    );
  }
}

/// Circular person photo with an initials fallback.
class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, this.url, required this.name, this.size = 40});

  final String? url;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final initials = name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    return ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: url == null || url!.isEmpty
            ? Container(
                color: p.primarySoft,
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: p.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: size * 0.36,
                  ),
                ),
              )
            : AppImage(url, placeholderIcon: LucideIcons.user),
      ),
    );
  }
}
