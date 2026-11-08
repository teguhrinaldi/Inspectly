import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/app_colors.dart';

/// White rounded card with the mockup's hairline border and soft shadow.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.radius = 16,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final shape = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? p.surface,
        borderRadius: shape,
        border: Border.all(color: p.border),
        boxShadow: p.isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0A1B3A6B),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: shape,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Top bar used by pushed screens: back arrow, title, optional trailing icon.
class ScreenHeader extends StatelessWidget implements PreferredSizeWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.showBack = true,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SafeArea(
      bottom: false,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: p.background,
          border: Border(bottom: BorderSide(color: p.border)),
        ),
        child: Row(
          children: [
            if (showBack)
              IconButton(
                tooltip: 'Back',
                icon: Icon(
                  LucideIcons.arrowLeft,
                  color: p.textPrimary,
                  size: 22,
                ),
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              )
            else
              const SizedBox(width: 12),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: p.textPrimary,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: context.palette.textPrimary,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Square rounded tile holding a tinted icon (finding cards, quick actions).
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    required this.tone,
    this.size = 44,
    this.solid = false,
  });

  final IconData icon;
  final Tone tone;
  final double size;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: solid ? tone.fg : p.tint(tone),
        borderRadius: BorderRadius.circular(size * 0.27),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: size * 0.48,
        color: solid ? Colors.white : p.fg(tone),
      ),
    );
  }
}

/// Centered empty/error message with an icon.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    // Scrolls when squeezed (keyboard open, phone landscape, large text).
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTile(icon: icon, tone: Tone.blue, size: 56),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: p.textPrimary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: p.textSecondary),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

/// "Try again" action for error states (QC-011).
class RetryButton extends StatelessWidget {
  const RetryButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) =>
      OutlinedButton(onPressed: onPressed, child: const Text('Try again'));
}

/// Compact error line with a retry action, for sections inside a screen.
class InlineError extends StatelessWidget {
  const InlineError({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 4,
      children: [
        Text(message, style: TextStyle(color: p.textSecondary)),
        TextButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    );
  }
}

/// Lays [child] (typically a Column with a Spacer) out at least as tall as
/// the available space, and lets it scroll when the space is too short
/// (phone landscape, large text) instead of overflowing.
class FillOrScroll extends StatelessWidget {
  const FillOrScroll({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: box.maxHeight),
        child: IntrinsicHeight(child: child),
      ),
    ),
  );
}
