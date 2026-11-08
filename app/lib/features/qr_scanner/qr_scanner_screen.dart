import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/providers/auth_providers.dart';
import '../../app/providers/inspection_providers.dart';
import '../../app/providers/repository_providers.dart';
import '../../app/providers/template_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../data/models/enums.dart';
import '../../data/models/inspection_template.dart';
import '../../data/models/site.dart';
import '../../data/services/location_service.dart';
import '../../core/widgets/surfaces.dart';

/// The QR encodes a stable site identifier (`INSPECTLY:SITE:<SLUG>-<NUM>`),
/// never a URL — scanning only ever looks up a Site.
class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _handling = false;
  bool _starting = false;
  String? _error;
  Site? _site;
  String? _templateId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _lookup(String code) async {
    if (_handling) return;
    setState(() {
      _handling = true;
      _error = null;
    });
    final result = await ref.read(siteRepositoryProvider).findByQrCode(code);
    if (!mounted) return;
    result.when(
      success: (site) {
        _controller.stop();
        setState(() {
          _site = site;
          _handling = false;
        });
      },
      failure: (f) => setState(() {
        _error = f.message;
        _handling = false;
      }),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_site != null) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code != null) _lookup(code);
  }

  Future<void> _enterManually() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter site code'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(hintText: 'e.g. RIVERSIDE-001'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Find site'),
          ),
        ],
      ),
    );
    controller.dispose();
    final value = code?.trim().toUpperCase();
    if (value == null || value.isEmpty) return;
    await _lookup(
      value.startsWith('INSPECTLY:SITE:') ? value : 'INSPECTLY:SITE:$value',
    );
  }

  void _rescan() {
    setState(() {
      _site = null;
      _templateId = null;
      _error = null;
    });
    _controller.start();
  }

  Future<void> _start() async {
    final site = _site;
    final templateId = _templateId;
    final auth = ref.read(authStateProvider);
    if (site == null || templateId == null || auth is! AuthLoggedIn) return;
    setState(() => _starting = true);
    final repo = ref.read(inspectionRepositoryProvider);
    final container = ProviderScope.containerOf(context, listen: false);
    final created = await repo.create(
      templateId: templateId,
      siteId: site.id,
      customerId: site.customerId,
      inspectorId: auth.user.id,
      recurrence: RecurrenceType.oneTime,
    );
    final inspection = created.dataOrNull;
    if (inspection == null) {
      if (mounted) {
        setState(() {
          _starting = false;
          _error = created.when(
            success: (_) => 'Could not create the inspection.',
            failure: (f) => f.message,
          );
        });
      }
      return;
    }
    final location = await LocationService().getCurrentLocation();
    final started = await repo.start(
      inspection.id,
      locationLat: location is LocationSuccess ? location.latitude : null,
      locationLng: location is LocationSuccess ? location.longitude : null,
    );
    container.invalidateInspection(inspection.id);
    if (!mounted) return;
    final startError = started.when(
      success: (_) => null,
      failure: (f) => f.message,
    );
    context.go('/inspections/${inspection.id}');
    if (startError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inspection created, but not started: $startError'),
        ),
      );
    } else {
      context.push('/checklist/${inspection.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B1220),
        body: Column(
          children: [
            Expanded(
              flex: 11,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                    errorBuilder: (context, error) => const _CameraMessage(
                      'Camera unavailable. Allow camera access, or enter the site code manually.',
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(color: Color(0x33000000)),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 56,
                          child: Row(
                            children: [
                              IconButton(
                                tooltip: 'Back',
                                icon: const Icon(
                                  LucideIcons.arrowLeft,
                                  color: Colors.white,
                                ),
                                onPressed: () => context.pop(),
                              ),
                              const Expanded(
                                child: Text(
                                  'Scan QR',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Toggle flashlight',
                                icon: const Icon(
                                  LucideIcons.flashlight,
                                  color: Colors.white,
                                ),
                                onPressed: () => _controller.toggleTorch(),
                              ),
                            ],
                          ),
                        ),
                        // Centered as before; scaled down when the camera
                        // area is short (small phones, landscape).
                        const Expanded(
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox.square(
                                    dimension: 230,
                                    child: CustomPaint(
                                      painter: _FramePainter(),
                                    ),
                                  ),
                                  SizedBox(height: 22),
                                  Text(
                                    'Scan Site QR Code',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // At most ~60% of the screen; scrolls on short screens instead
            // of pushing the camera area into an overflow.
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.6,
              ),
              child: SingleChildScrollView(
                child: _BottomPanel(
                  site: _site,
                  handling: _handling,
                  starting: _starting,
                  error: _error,
                  selectedTemplateId: _templateId,
                  onSelectTemplate: (id) => setState(() => _templateId = id),
                  onStart: _start,
                  onManual: _enterManually,
                  onRescan: _rescan,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomPanel extends ConsumerWidget {
  const _BottomPanel({
    required this.site,
    required this.handling,
    required this.starting,
    required this.error,
    required this.selectedTemplateId,
    required this.onSelectTemplate,
    required this.onStart,
    required this.onManual,
    required this.onRescan,
  });

  final Site? site;
  final bool handling;
  final bool starting;
  final String? error;
  final String? selectedTemplateId;
  final ValueChanged<String> onSelectTemplate;
  final VoidCallback onStart;
  final VoidCallback onManual;
  final VoidCallback onRescan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final templates = ref.watch(templateListProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: p.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.mapPin,
                      size: 18,
                      color: site == null ? p.textMuted : AppColors.red,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: handling
                          ? const LinearProgressIndicator()
                          : Text(
                              site?.name ??
                                  'Point the camera at a site QR code',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: site == null
                                    ? FontWeight.w500
                                    : FontWeight.w600,
                                color: site == null
                                    ? p.textSecondary
                                    : p.textPrimary,
                              ),
                            ),
                    ),
                    TextButton(
                      onPressed: site == null ? onManual : onRescan,
                      child: Text(site == null ? 'Enter code' : 'Rescan'),
                    ),
                  ],
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.circleAlert,
                      size: 16,
                      color: AppColors.red,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        error!,
                        style: const TextStyle(
                          color: AppColors.red,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Available Templates',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: p.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              templates.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => InlineError(
                  message: 'Could not load templates.',
                  onRetry: () => ref.invalidate(templateListProvider),
                ),
                data: (list) => ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 190),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => _TemplateOption(
                      template: list[i],
                      selected: list[i].id == selectedTemplateId,
                      enabled: site != null,
                      onTap: () => onSelectTemplate(list[i].id),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed:
                    site != null && selectedTemplateId != null && !starting
                    ? onStart
                    : null,
                child: starting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Start Inspection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateOption extends StatelessWidget {
  const _TemplateOption({
    required this.template,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final InspectionTemplate template;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final icon = switch (template.category) {
      'safety' => LucideIcons.shieldCheck,
      'property' => LucideIcons.building2,
      'equipment' => LucideIcons.wrench,
      _ => LucideIcons.truck,
    };
    return Semantics(
      selected: selected,
      button: true,
      label: template.name,
      excludeSemantics: true,
      child: Material(
        color: selected ? p.primarySoft : p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: selected ? p.primary : p.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(icon, size: 20, color: enabled ? p.primary : p.textMuted),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    template.name,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: enabled ? p.textPrimary : p.textMuted,
                    ),
                  ),
                ),
                if (selected)
                  Icon(LucideIcons.circleCheck, size: 20, color: p.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraMessage extends StatelessWidget {
  const _CameraMessage(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFF1B2433),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 13.5),
        ),
      ),
    ),
  );
}

class _FramePainter extends CustomPainter {
  const _FramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const len = 42.0;
    const r = 18.0;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    final w = size.width;
    final h = size.height;
    Path corner(Offset o, double dx, double dy) => Path()
      ..moveTo(o.dx, o.dy + dy * len)
      ..lineTo(o.dx, o.dy + dy * r)
      ..quadraticBezierTo(o.dx, o.dy, o.dx + dx * r, o.dy)
      ..lineTo(o.dx + dx * len, o.dy);
    canvas
      ..drawPath(corner(Offset.zero, 1, 1), paint)
      ..drawPath(corner(Offset(w, 0), -1, 1), paint)
      ..drawPath(corner(Offset(0, h), 1, -1), paint)
      ..drawPath(corner(Offset(w, h), -1, -1), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
