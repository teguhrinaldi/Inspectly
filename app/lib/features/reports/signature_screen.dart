import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:signature/signature.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers/inspection_providers.dart';
import '../../app/providers/repository_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/media_source.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/responsive_content.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/enums.dart';
import '../../data/models/inspection.dart';
import '../../data/models/signature.dart';
import '../../data/services/pdf_report_service.dart';
import '../../core/errors/failure.dart';

/// Inspector signature + customer acknowledgement. Once both are captured
/// the inspection is completed and the risk summary opens.
class SignatureScreen extends ConsumerWidget {
  const SignatureScreen({super.key, required this.inspectionId});
  final String inspectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(inspectionByIdProvider(inspectionId));
    return Scaffold(
      appBar: const ScreenHeader(title: 'Signature'),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: LucideIcons.cloudOff,
          title: 'Could not load inspection',
          message: userMessage(e),
          action: RetryButton(
            onPressed: () =>
                ref.invalidate(inspectionByIdProvider(inspectionId)),
          ),
        ),
        data: (inspection) => _SignatureBody(inspection: inspection),
      ),
    );
  }
}

class _SignatureBody extends ConsumerStatefulWidget {
  const _SignatureBody({required this.inspection});
  final Inspection inspection;

  @override
  ConsumerState<_SignatureBody> createState() => _SignatureBodyState();
}

class _SignatureBodyState extends ConsumerState<_SignatureBody> {
  final _inspectorPad = SignatureController(
    penStrokeWidth: 2.6,
    penColor: AppColors.navy,
    exportBackgroundColor: Colors.white,
  );
  final _customerPad = SignatureController(
    penStrokeWidth: 2.6,
    penColor: AppColors.navy,
    exportBackgroundColor: Colors.white,
  );
  final Set<SignatureType> _resigning = {};
  bool _saving = false;
  bool _sharing = false;

  Inspection get inspection => widget.inspection;

  InspectionSignature? _existing(SignatureType type) =>
      inspection.signatures.where((s) => s.type == type).lastOrNull;

  @override
  void initState() {
    super.initState();
    _inspectorPad.addListener(_changed);
    _customerPad.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    _inspectorPad.dispose();
    _customerPad.dispose();
    super.dispose();
  }

  Future<String?> _export(SignatureController c) async {
    final bytes = await c.toPngBytes();
    if (bytes == null) return null;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'inspectly', 'tmp_signatures'));
    if (!await dir.exists()) await dir.create(recursive: true);
    final path = p.join(dir.path, '${const Uuid().v4()}.png');
    await File(path).writeAsBytes(bytes);
    return path;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = ref.read(signatureRepositoryProvider);
    try {
      for (final (type, pad, signer) in [
        (SignatureType.inspector, _inspectorPad, inspection.inspectorName),
        (SignatureType.customer, _customerPad, inspection.customerName),
      ]) {
        if (pad.isEmpty) continue;
        final path = await _export(pad);
        if (path == null) continue;
        final result = await repo.save(
          inspectionId: inspection.id,
          type: type,
          signerName: signer,
          localFilePath: path,
        );
        if (result.dataOrNull == null) throw StateError('save failed');
        pad.clear();
        _resigning.remove(type);
      }

      final fresh =
          (await ref.read(inspectionRepositoryProvider).getById(inspection.id))
              .dataOrNull;
      final signed = fresh?.signatures.map((s) => s.type).toSet() ?? {};
      final complete =
          signed.contains(SignatureType.inspector) &&
          signed.contains(SignatureType.customer);
      if (complete && fresh!.status != InspectionStatus.completed) {
        final done = await ref
            .read(inspectionRepositoryProvider)
            .complete(inspection.id);
        if (done.dataOrNull == null) throw StateError('complete failed');
      }
      ref.invalidateInspection(inspection.id);
      if (!mounted) return;
      if (complete) {
        context.go('/inspections/${inspection.id}/summary');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Signature saved. Both signatures complete the inspection.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save the signature.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      final bytes = await PdfReportService().generate(inspection);
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${inspection.siteName.replaceAll(' ', '_')}_report.pdf',
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = inspection.status == InspectionStatus.completed;
    final hasDrawing = _inspectorPad.isNotEmpty || _customerPad.isNotEmpty;

    return ResponsiveContent(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          _SignatureBlock(
            title: 'Inspector Signature',
            signer: inspection.inspectorName,
            controller: _inspectorPad,
            existing: _existing(SignatureType.inspector),
            editing: _resigning.contains(SignatureType.inspector),
            readOnly: completed,
            onResign: () =>
                setState(() => _resigning.add(SignatureType.inspector)),
          ),
          const SizedBox(height: 22),
          _SignatureBlock(
            title: 'Customer Acknowledgement',
            signer: inspection.customerName,
            controller: _customerPad,
            existing: _existing(SignatureType.customer),
            editing: _resigning.contains(SignatureType.customer),
            readOnly: completed,
            onResign: () =>
                setState(() => _resigning.add(SignatureType.customer)),
          ),
          const SizedBox(height: 24),
          if (!completed)
            ElevatedButton(
              onPressed: hasDrawing && !_saving ? _save : null,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save Signature'),
            ),
          if (!completed) const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _sharing ? null : _share,
            icon: const Icon(LucideIcons.share, size: 18),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }
}

class _SignatureBlock extends StatelessWidget {
  const _SignatureBlock({
    required this.title,
    required this.signer,
    required this.controller,
    required this.existing,
    required this.editing,
    required this.readOnly,
    required this.onResign,
  });

  final String title;
  final String signer;
  final SignatureController controller;
  final InspectionSignature? existing;
  final bool editing;
  final bool readOnly;
  final VoidCallback onResign;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final showSaved = existing != null && !editing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: p.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(signer, style: TextStyle(fontSize: 13, color: p.textSecondary)),
        const SizedBox(height: 10),
        SurfaceCard(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                label: showSaved ? '$title captured' : '$title pad',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 140,
                    child: showSaved
                        ? ColoredBox(
                            color: Colors.white,
                            child: AppImage(
                              existing!.displaySource,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Signature(
                            controller: controller,
                            backgroundColor: Colors.white,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (showSaved)
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.circleCheck,
                          size: 16,
                          color: AppColors.green,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Signed',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: p.fg(Tone.green),
                          ),
                        ),
                      ],
                    ),
                  const Spacer(),
                  if (!readOnly)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        side: BorderSide(color: p.border),
                        foregroundColor: p.textPrimary,
                      ),
                      onPressed: showSaved ? onResign : controller.clear,
                      child: Text(showSaved ? 'Re-sign' : 'Clear'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
