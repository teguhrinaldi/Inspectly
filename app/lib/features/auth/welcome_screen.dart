import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers/auth_providers.dart';
import '../../app/providers/repository_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/inspectly_logo.dart';

const heroInspectorAsset = 'assets/images/demo/hero_inspector.jpg';

/// First screen: field-inspector photo, brand, and the two entry points.
/// "Get Started" opens the bundled demo workspace in demo mode (no backend
/// needed) and the sign-in form when the app is pointed at a real API.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _starting = false;

  Future<void> _getStarted() async {
    if (useApiMode) {
      context.push('/login');
      return;
    }
    setState(() => _starting = true);
    final failure = await ref
        .read(authStateProvider.notifier)
        .login(email: 'michael.carter@inspectly.test', password: 'password');
    if (!mounted) return;
    setState(() => _starting = false);
    if (failure != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF0A1424);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: ink,
        body: LayoutBuilder(
          builder: (context, c) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Semantics(
                  image: true,
                  label: 'Field inspector holding a tablet on site',
                  child: Image.asset(
                    heroInspectorAsset,
                    fit: BoxFit.cover,
                    // Landscape tablets show a wide slice of this portrait
                    // photo: anchor higher so the face is not cut off.
                    alignment: c.maxWidth > c.maxHeight
                        ? const Alignment(0, -0.2)
                        : const Alignment(0, 0.35),
                  ),
                ),
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 420,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xD92A5C96),
                          Color(0x803F73AD),
                          Color(0x003F73AD),
                        ],
                        stops: [0, 0.55, 1],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 340,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x000A1424), Color(0xE60A1424), ink],
                        stops: [0, 0.55, 1],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 480),
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          SizedBox(height: c.maxHeight * 0.06),
                          const InspectlyLogo(size: 60, color: Colors.white),
                          const SizedBox(height: 14),
                          const InspectlyWordmark(
                            fontSize: 38,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Inspect. Document. Report.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                minimumSize: const Size(0, 54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _starting ? null : _getStarted,
                              child: _starting
                                  ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Get Started'),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 54),
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  width: 1.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () => context.push('/login'),
                              child: const Text('Login'),
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
