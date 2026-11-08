import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:printing/printing.dart';

import '../../app/providers/inspection_providers.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/services/pdf_report_service.dart';

/// On-device generated PDF report with print / share / save.
class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key, required this.inspectionId});
  final String inspectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(inspectionByIdProvider(inspectionId));
    return Scaffold(
      appBar: const ScreenHeader(title: 'Inspection Report'),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: LucideIcons.cloudOff,
          title: 'Could not load report',
          message: '$e',
        ),
        data: (inspection) => PdfPreview(
          build: (format) => PdfReportService().generate(inspection),
          allowPrinting: true,
          allowSharing: true,
          canChangeOrientation: false,
          canChangePageFormat: false,
          canDebug: false,
          pdfFileName: '${inspection.siteName.replaceAll(' ', '_')}_report.pdf',
        ),
      ),
    );
  }
}
