import 'package:flutter/material.dart';

/// Caps content width and centers it on tablet-and-wider screens, instead of
/// letting mobile-designed lists/cards stretch edge-to-edge (spec §19: "Do
/// not simply stretch mobile UI"). A full split-view (list | detail) is a
/// larger redesign than this product's mobile-first scope calls for, but
/// naive full-width stretching on a tablet is a real, visible defect — this
/// is the minimal fix that removes it. Below the breakpoint this is a no-op.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 760,
  });

  final Widget child;
  final double maxWidth;

  static const tabletBreakpoint = 720.0;

  /// A tablet in either orientation (shortest side ≥ 600 dp, Android's
  /// sw600dp). Tablet-only layouts (sidebar, tablet Home and login) check
  /// this so a phone turned to landscape keeps the phone UI.
  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < tabletBreakpoint) return child;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
