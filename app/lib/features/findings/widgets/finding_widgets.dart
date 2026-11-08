import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/media_source.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/status_style.dart';
import '../../../core/widgets/surfaces.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/evidence.dart';
import '../../../data/models/finding.dart';
import '../../../data/models/inspection.dart';

extension InspectionEvidence on Inspection {
  List<Evidence> get allEvidence => [
    ...items.expand((i) => i.evidence),
    ...findings.expand((f) => f.evidence),
  ];

  List<Finding> get findingsBySeverity =>
      [...findings]..sort((a, b) => a.severity.rank.compareTo(b.severity.rank));

  int findingCount(FindingSeverity s) =>
      findings.where((f) => f.severity == s).length;
}

String photoCount(int n) => '$n photo${n == 1 ? '' : 's'}';

IconData severityGlyph(FindingSeverity s) => switch (s) {
  FindingSeverity.critical => LucideIcons.flame,
  FindingSeverity.high => LucideIcons.zap,
  FindingSeverity.medium => LucideIcons.droplets,
  FindingSeverity.low => LucideIcons.house,
};

/// Four tinted tiles: Critical / High / Medium / Low with counts.
class SeverityTiles extends StatelessWidget {
  const SeverityTiles({
    super.key,
    required this.inspection,
    this.numberFirst = false,
  });

  final Inspection inspection;
  final bool numberFirst;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        for (final (i, s) in FindingSeverity.values.indexed) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Builder(
              builder: (context) {
                final style = StatusStyle.forSeverity(s);
                final tone = numberFirst && s == FindingSeverity.low
                    ? Tone.blue
                    : style.tone;
                final fg = p.fg(tone);
                final count = Text(
                  '${inspection.findingCount(s)}',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: fg,
                    height: 1.1,
                  ),
                );
                final label = Text(
                  style.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                );
                return Semantics(
                  label: '${inspection.findingCount(s)} ${style.label}',
                  excludeSemantics: true,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: p.tint(tone),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: numberFirst
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: numberFirst
                          ? [count, const SizedBox(height: 6), label]
                          : [label, const SizedBox(height: 8), count],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class FindingCard extends StatelessWidget {
  const FindingCard({super.key, required this.finding, this.onTap});

  final Finding finding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final style = StatusStyle.forSeverity(finding.severity);
    final fg = p.fg(style.tone);
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(
            icon: severityGlyph(finding.severity),
            tone: style.tone,
            size: 48,
            solid: true,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  finding.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(style.icon, size: 13, color: fg),
                    const SizedBox(width: 4),
                    Text(
                      style.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: fg,
                      ),
                    ),
                    Text(
                      '  ·  ${photoCount(finding.evidence.length)}',
                      style: TextStyle(fontSize: 13, color: p.textSecondary),
                    ),
                    if (finding.status == FindingStatus.resolved) ...[
                      const SizedBox(width: 8),
                      const StatusBadge(
                        style: StatusStyle(
                          icon: LucideIcons.circleCheck,
                          tone: Tone.green,
                          label: 'Resolved',
                        ),
                      ),
                    ],
                  ],
                ),
                if (finding.location != null) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(LucideIcons.building2, size: 13, color: p.textMuted),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          finding.location!,
                          style: TextStyle(
                            fontSize: 13,
                            color: p.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            Icon(LucideIcons.chevronRight, size: 18, color: p.textMuted),
        ],
      ),
    );
  }
}

/// Horizontal strip of evidence thumbnails, tapping opens a full-screen view.
class EvidenceStrip extends StatelessWidget {
  const EvidenceStrip({super.key, required this.evidence, this.size = 76});

  final List<Evidence> evidence;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: evidence.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) => EvidenceThumb(
          evidence: evidence[i],
          size: size,
          gallery: evidence,
          index: i,
        ),
      ),
    );
  }
}

class EvidenceThumb extends StatelessWidget {
  const EvidenceThumb({
    super.key,
    required this.evidence,
    this.size = 76,
    this.gallery,
    this.index = 0,
    this.onRemove,
  });

  final Evidence evidence;
  final double size;
  final List<Evidence>? gallery;
  final int index;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Evidence photo',
      child: Stack(
        children: [
          GestureDetector(
            onTap: () =>
                EvidenceViewer.open(context, gallery ?? [evidence], index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppImage(
                evidence.displaySource,
                width: size,
                height: size,
              ),
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onRemove,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(LucideIcons.x, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class EvidenceViewer extends StatefulWidget {
  const EvidenceViewer({super.key, required this.items, required this.index});

  final List<Evidence> items;
  final int index;

  static void open(BuildContext context, List<Evidence> items, int index) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => EvidenceViewer(items: items, index: index),
      ),
    );
  }

  @override
  State<EvidenceViewer> createState() => _EvidenceViewerState();
}

/// Stateful so the "n / total" title follows the swiped photo and the
/// PageController is created once and disposed (QC-046).
class _EvidenceViewerState extends State<EvidenceViewer> {
  late final PageController _controller = PageController(
    initialPage: widget.index,
  );
  late int _current = widget.index;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_current + 1} / ${widget.items.length}'),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.items.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (context, i) => InteractiveViewer(
          child: Center(
            child: AppImage(widget.items[i].displaySource, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
