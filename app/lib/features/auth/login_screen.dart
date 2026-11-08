import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers/auth_providers.dart';
import '../../app/providers/repository_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/responsive_content.dart';
import '../../core/widgets/inspectly_logo.dart';
import 'welcome_screen.dart';

/// Sign-in form in the welcome screen's visual language: the same field
/// inspector photo, blue wash, white shield and wordmark, and button system.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(
    text: useApiMode ? '' : 'michael.carter@inspectly.test',
  );
  final _passwordController = TextEditingController(
    text: useApiMode ? '' : 'password',
  );
  bool _obscurePassword = true;
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    final failure = await ref
        .read(authStateProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _errorText = failure?.message;
    });
  }

  InputDecoration _field(String hint, IconData icon, {Widget? suffix}) {
    final radius = BorderRadius.circular(16);
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(vertical: 17),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: context.palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.red, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: p.surface,
        body: LayoutBuilder(
          builder: (context, c) {
            if (ResponsiveContent.isTablet(context) &&
                c.maxWidth >= tabletMinWidth) {
              return _tabletLayout(context);
            }
            final heroHeight = c.maxHeight * 0.42;
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight),
                child: Stack(
                  children: [
                    SizedBox(
                      height: heroHeight + 32,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            heroInspectorAsset,
                            fit: BoxFit.cover,
                            alignment: const Alignment(0, -0.45),
                            excludeFromSemantics: true,
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xD92A5C96),
                                  Color(0x803F73AD),
                                  Color(0xB30A1424),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SafeArea(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Column(
                            children: [
                              SizedBox(
                                height:
                                    heroHeight -
                                    MediaQuery.paddingOf(context).top,
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: IconButton(
                                        tooltip: 'Back',
                                        icon: const Icon(
                                          LucideIcons.arrowLeft,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => context.canPop()
                                            ? context.pop()
                                            : context.go('/welcome'),
                                      ),
                                    ),
                                    Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const InspectlyLogo(
                                            size: 56,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(height: 12),
                                          const InspectlyWordmark(
                                            fontSize: 36,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Inspect. Document. Report.',
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.92,
                                              ),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(
                                  28,
                                  30,
                                  28,
                                  28,
                                ),
                                decoration: BoxDecoration(
                                  color: p.surface,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(28),
                                  ),
                                ),
                                child: _form(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Screen width from which the two-column tablet layout is used.
  static const tabletMinWidth = 840.0;

  Future<void> _continueWithDemo() {
    _emailController.text = demoAccountEmail;
    _passwordController.text = demoAccountPassword;
    return _submit();
  }

  void _showForgotPassword() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot your password?'),
        content: const Text(
          'Inspector accounts are managed by your Inspectly administrator. '
          'Ask them to set a new password in the admin panel '
          '(Inspectors → Edit).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Tablet: brand hero on the left, sign-in panel on the right
  /// (docs/design/reference_a_tablet_admin.png, panel 1).
  Widget _tabletLayout(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Expanded(
          flex: 11,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                heroInspectorAsset,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.35),
                excludeFromSemantics: true,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xB30E1A33),
                      Color(0x4D1E4A8A),
                      Color(0xF20E1A33),
                    ],
                    stops: [0, 0.4, 1],
                  ),
                ),
              ),
              SafeArea(
                right: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 28, 40, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          InspectlyLogo(size: 34, color: Colors.white),
                          SizedBox(width: 10),
                          InspectlyWordmark(fontSize: 26, color: Colors.white),
                        ],
                      ),
                      const Spacer(),
                      const Text(
                        'Safer Sites.\nBetter Decisions.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Inspect. Document. Report.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Feature(
                            icon: LucideIcons.clipboardCheck,
                            title: 'Digital Checklist',
                            text: 'Stay consistent,\nreduce risk.',
                          ),
                          _Feature(
                            icon: LucideIcons.camera,
                            title: 'Photo Evidence',
                            text: 'Capture with GPS\n& watermark.',
                          ),
                          _Feature(
                            icon: LucideIcons.fileText,
                            title: 'PDF Reports',
                            text: 'Professional &\nready to share.',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 10,
          child: ColoredBox(
            color: p.surface,
            child: SafeArea(
              left: false,
              child: Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 32,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: _tabletForm(context),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: IconButton(
                      tooltip: 'Back',
                      icon: Icon(LucideIcons.arrowLeft, color: p.textPrimary),
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go('/welcome'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabletForm(BuildContext context) {
    final p = context.palette;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InspectlyLogo(size: 34, color: p.primary),
              const SizedBox(width: 10),
              InspectlyWordmark(fontSize: 26, color: p.textPrimary),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            'Welcome back',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: p.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to access your inspections\nand field reports.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.textSecondary,
              fontSize: 14.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          _emailField(),
          const SizedBox(height: 14),
          _passwordField(),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPassword,
              child: const Text('Forgot password?'),
            ),
          ),
          ..._errorRow(),
          const SizedBox(height: 10),
          _loginButton(),
          if (demoLoginAvailable) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: Divider(color: p.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or',
                    style: TextStyle(color: p.textMuted, fontSize: 13),
                  ),
                ),
                Expanded(child: Divider(color: p.border)),
              ],
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 54),
                foregroundColor: p.primary,
                side: BorderSide(color: p.primary, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _submitting ? null : _continueWithDemo,
              icon: const Icon(LucideIcons.userRound, size: 19),
              label: const Text('Continue with Demo Account'),
            ),
          ],
          const SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.lock, size: 14, color: p.textMuted),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  useApiMode
                      ? 'Your session is stored securely on this device.'
                      : 'Demo mode — sample data, no backend required.',
                  style: TextStyle(fontSize: 12.5, color: p.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emailField() => TextFormField(
    controller: _emailController,
    keyboardType: TextInputType.emailAddress,
    autofillHints: const [AutofillHints.email],
    decoration: _field('Email', LucideIcons.mail),
    validator: (v) => (v == null || v.isEmpty) ? 'Enter your email' : null,
  );

  Widget _passwordField() => TextFormField(
    controller: _passwordController,
    obscureText: _obscurePassword,
    autofillHints: const [AutofillHints.password],
    decoration: _field(
      'Password',
      LucideIcons.lock,
      suffix: IconButton(
        tooltip: _obscurePassword ? 'Show password' : 'Hide password',
        icon: Icon(
          _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
          size: 20,
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
    ),
    validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
    onFieldSubmitted: (_) => _submit(),
  );

  List<Widget> _errorRow() => [
    if (_errorText != null) ...[
      const SizedBox(height: 12),
      Row(
        children: [
          const Icon(LucideIcons.circleAlert, size: 16, color: AppColors.red),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _errorText!,
              style: const TextStyle(color: AppColors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    ],
  ];

  Widget _loginButton() => ElevatedButton(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(0, 54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    onPressed: _submitting ? null : _submit,
    child: _submitting
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : const Text('Login'),
  );

  Widget _form(BuildContext context) {
    final p = context.palette;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Login',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: p.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sign in to continue your inspections.',
            style: TextStyle(color: p.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 22),
          _emailField(),
          const SizedBox(height: 14),
          _passwordField(),
          ..._errorRow(),
          const SizedBox(height: 24),
          _loginButton(),
          if (!useApiMode) ...[
            const SizedBox(height: 16),
            Text(
              'Demo mode · $demoAccountEmail / $demoAccountPassword',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: p.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
