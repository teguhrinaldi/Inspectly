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
    if (src.startsWith('assets/')) {
      return Image.asset(
        src,
        fit: fit,
        width: width,
        height: height,
        alignment: alignment,
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
        errorBuilder: placeholder,
      );
    }
    return Image.file(
      File(src),
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
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
        child: url == null
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
