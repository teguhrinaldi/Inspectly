import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:printing/printing.dart';

import '../../app/providers/inspection_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/date_labels.dart';
import '../../core/utils/risk_breakdown.dart';
import '../../core/widgets/responsive_content.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/enums.dart';
import '../../data/models/inspection.dart';
import '../../data/services/pdf_report_service.dart';
import '../findings/widgets/finding_widgets.dart';
import '../../core/errors/failure.dart';

class RiskSummaryScreen extends ConsumerWidget {
  const RiskSummaryScreen({super.key, required this.inspectionId});
  final String inspectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(inspectionByIdProvider(inspectionId));
    return Scaffold(
      appBar: ScreenHeader(
        title: 'Inspection Risk Summary',
        onBack: () => context.canPop()
            ? context.pop()
            : context.go('/inspections/$inspectionId'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: LucideIcons.cloudOff,
          title: 'Could not load summary',
          message: userMessage(e),
          action: RetryButton(
            onPressed: () =>
                ref.invalidate(inspectionByIdProvider(inspectionId)),
          ),
        ),
        data: (i) => ResponsiveContent(child: _SummaryBody(inspection: i)),
      ),
    );
  }
}

class _SummaryBody extends StatefulWidget {
  const _SummaryBody({required this.inspection});
  final Inspection inspection;

  @override
  State<_SummaryBody> createState() => _SummaryBodyState();
}

class _SummaryBodyState extends State<_SummaryBody> {
  bool _sharing = false;

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      final i = widget.inspection;
      await Printing.sharePdf(
        bytes: await PdfReportService().generate(i),
        filename: '${i.siteName.replaceAll(' ', '_')}_report.pdf',
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final i = widget.inspection;
    final risk = RiskBreakdown(i);
    final done = i.status == InspectionStatus.completed;
    final bannerTone = done ? Tone.green : Tone.orange;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: p.tint(bannerTone),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: bannerTone.fg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  done ? LucideIcons.check : LucideIcons.clock,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      done ? 'Inspection Complete!' : 'Inspection In Progress',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: p.fg(bannerTone),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      i.siteName,
                      style: TextStyle(fontSize: 14, color: p.textPrimary),
                    ),
                    Text(
                      i.templateName,
                      style: TextStyle(fontSize: 13.5, color: p.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Semantics(
                label: '${risk.compliance} percent overall compliance',
                excludeSemantics: true,
                child: SizedBox.square(
                  dimension: 132,
                  child: CustomPaint(
                    painter: _RingPainter(
                      value: risk.compliance / 100,
                      color: AppColors.teal,
                      track: p.tint(Tone.teal),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${risk.compliance}%',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: p.textPrimary,
                            ),
                          ),
                          SizedBox(
                            width: 86,
                            child: Text(
                              'Overall Compliance',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10.5,
                                height: 1.2,
                                color: p.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _CountRow(
                      icon: LucideIcons.check,
                      tone: Tone.green,
                      count: risk.passed,
                      label: 'Passed',
                    ),
                    const SizedBox(height: 12),
                    _CountRow(
                      icon: LucideIcons.circleAlert,
                      tone: Tone.orange,
                      count: risk.needsAttention,
                      label: 'Needs Attention',
                    ),
                    const SizedBox(height: 12),
                    _CountRow(
                      icon: LucideIcons.x,
                      tone: Tone.red,
                      count: risk.failed,
                      label: 'Failed',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (risk.notApplicable > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${risk.notApplicable} item(s) marked N/A are excluded from the pass rate.',
              style: TextStyle(fontSize: 12, color: p.textMuted),
            ),
          ),
        const SizedBox(height: 20),
        const SectionTitle('Findings by Severity'),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => context.go('/inspections/${i.id}/findings'),
          child: SeverityTiles(inspection: i, numberFirst: true),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: p.tint(Tone.green),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                LucideIcons.calendarCheck,
                size: 34,
                color: p.fg(Tone.green),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Inspection',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: p.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      i.nextDueAt == null
                          ? 'No recurring schedule set'
                          : '${shortDate(i.nextDueAt!)} (${inTimeLabel(i.nextDueAt!)})',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: p.fg(Tone.green),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      i.nextDueAt == null ? i.recurrence.label : i.templateName,
                      style: TextStyle(fontSize: 13, color: p.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.push('/report/${i.id}'),
                child: const Text('View Report'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _sharing ? null : _share,
                icon: const Icon(LucideIcons.share, size: 18),
                label: const Text('Share'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({
    required this.icon,
    required this.tone,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final Tone tone;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: p.tint(tone),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: p.fg(tone)),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 26,
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: p.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13.5, color: p.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.color, required this.track});

  final double value;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    canvas.drawArc(
      arc,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    final sweep = math.pi * 2 * value.clamp(0, 1);
    canvas.drawArc(
      arc,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: math.pi * 2,
          transform: const GradientRotation(-math.pi / 2),
          colors: [const Color(0xFF34D399), color, const Color(0xFF0E7C66)],
          stops: const [0, 0.5, 1],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt,
    );
    final tick = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke + 1;
    for (var k = 1; k < 8; k++) {
      final a = -math.pi / 2 + k * math.pi / 4;
      if (a - (-math.pi / 2) > sweep) break;
      canvas.drawArc(arc, a - 0.015, 0.03, false, tick);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}
