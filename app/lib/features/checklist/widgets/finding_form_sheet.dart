import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/status_style.dart';
import '../../../data/models/enums.dart';
import '../../findings/widgets/photo_capture.dart';
import '../../../core/widgets/confirm_discard.dart';

class FindingDraft {
  const FindingDraft({
    required this.title,
    required this.description,
    required this.severity,
    this.recommendation,
    this.location,
    required this.photos,
  });

  final String title;
  final String description;
  final FindingSeverity severity;
  final String? recommendation;
  final String? location;
  final List<CapturedPhoto> photos;
}

/// Fail → finding flow: opened when an item is marked FAIL, or from
/// "Add Finding". Severity, title and description are required; location,
/// recommendation and photos are optional so poor site access never blocks
/// the inspection.
class FindingFormSheet extends StatefulWidget {
  const FindingFormSheet({
    super.key,
    this.itemLabel,
    required this.siteName,
    required this.inspectorName,
  });

  final String? itemLabel;
  final String siteName;
  final String inspectorName;

  static Future<FindingDraft?> show(
    BuildContext context, {
    String? itemLabel,
    required String siteName,
    required String inspectorName,
  }) {
    return showModalBottomSheet<FindingDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (_) => FindingFormSheet(
        itemLabel: itemLabel,
        siteName: siteName,
        inspectorName: inspectorName,
      ),
    );
  }

  @override
  State<FindingFormSheet> createState() => _FindingFormSheetState();
}

class _FindingFormSheetState extends State<FindingFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(
    text: widget.itemLabel ?? '',
  );
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _recommendationController = TextEditingController();
  FindingSeverity _severity = FindingSeverity.medium;
  final List<CapturedPhoto> _photos = [];
  bool _capturing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _recommendationController.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    setState(() => _capturing = true);
    try {
      final photo = await capturePhoto(
        context,
        siteName: widget.siteName,
        inspectorName: widget.inspectorName,
      );
      if (photo != null) setState(() => _photos.add(photo));
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  String? _optional(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      FindingDraft(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        severity: _severity,
        location: _optional(_locationController),
        recommendation: _optional(_recommendationController),
        photos: _photos,
      ),
    );
  }

  bool get _dirty =>
      _titleController.text.trim() != (widget.itemLabel ?? '').trim() ||
      _descriptionController.text.trim().isNotEmpty ||
      _photos.isNotEmpty;

  @override
  Widget build(BuildContext context) => PopScope(
    // A filled-in finding asks before being discarded (QC-031). Save pops
    // with Navigator.pop, which is not affected by this.
    canPop: false,
    onPopInvokedWithResult: (didPop, _) async {
      if (didPop) return;
      final navigator = Navigator.of(context);
      if (!_dirty || await confirmDiscard(context)) navigator.pop();
    },
    child: _form(context),
  );

  Widget _form(BuildContext context) {
    final p = context.palette;
    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
          color: p.textPrimary,
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Form(
          key: _formKey,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              Text(
                'New Finding',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: p.textPrimary,
                ),
              ),
              if (widget.itemLabel != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Checklist item failed: ${widget.itemLabel}',
                  style: TextStyle(color: p.textSecondary, fontSize: 13),
                ),
              ],
              const SizedBox(height: 20),
              label('Severity'),
              Row(
                children: [
                  for (final (i, s) in FindingSeverity.values.indexed) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: _SeverityOption(
                        severity: s,
                        selected: _severity == s,
                        onTap: () => setState(() => _severity = s),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              label('Title'),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Damaged Electrical Panel',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter a short title'
                    : null,
              ),
              const SizedBox(height: 14),
              label('Description'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'What did you observe?',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Describe what you observed'
                    : null,
              ),
              const SizedBox(height: 14),
              label('Location (optional)'),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Building A · Floor 2',
                  prefixIcon: Icon(LucideIcons.building2, size: 18),
                ),
              ),
              const SizedBox(height: 14),
              label('Recommendation (optional)'),
              TextFormField(
                controller: _recommendationController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Suggested corrective action',
                ),
              ),
              const SizedBox(height: 18),
              label('Photo (${_photos.length})'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final photo in _photos)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AppImage(photo.path, width: 80, height: 80),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _photos.remove(photo)),
                            child: const CircleAvatar(
                              radius: 11,
                              backgroundColor: Colors.black54,
                              child: Icon(
                                LucideIcons.x,
                                size: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  AddPhotoTile(loading: _capturing, onTap: _addPhoto, size: 80),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save Finding'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeverityOption extends StatelessWidget {
  const _SeverityOption({
    required this.severity,
    required this.selected,
    required this.onTap,
  });

  final FindingSeverity severity;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final style = StatusStyle.forSeverity(severity);
    final fg = p.fg(style.tone);
    return Semantics(
      selected: selected,
      button: true,
      label: style.label,
      excludeSemantics: true,
      child: Material(
        color: selected ? style.tone.fg : p.tint(style.tone),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(style.icon, size: 18, color: selected ? Colors.white : fg),
                const SizedBox(height: 4),
                Text(
                  style.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dashed-looking outlined tile with "Add Photo".
class AddPhotoTile extends StatelessWidget {
  const AddPhotoTile({
    super.key,
    required this.onTap,
    this.loading = false,
    this.size = 80,
    this.width,
  });

  final VoidCallback onTap;
  final bool loading;
  final double size;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: 'Add photo',
      excludeSemantics: true,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width ?? size,
          height: size,
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.border, width: 1.2),
          ),
          alignment: Alignment.center,
          child: loading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.camera, size: 17, color: p.textSecondary),
                    if ((width ?? size) > 100) ...[
                      const SizedBox(width: 6),
                      Text(
                        'Add Photo',
                        style: TextStyle(
                          fontSize: 13,
                          color: p.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
