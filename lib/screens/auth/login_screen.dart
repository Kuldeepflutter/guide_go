import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:guidego/core/app_theme.dart';
import 'package:guidego/core/widgets.dart';
import 'package:guidego/providers/traveler_provider.dart';
import 'package:guidego/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email   = TextEditingController();
  final _pass    = TextEditingController();
  bool _loading  = false;
  bool _obscure  = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final travelerProv = context.read<TravelerProvider>();
    final router       = GoRouter.of(context);
    final messenger    = ScaffoldMessenger.of(context);

    try {
      await AuthService().signIn(
        email: _email.text.trim(),
        password: _pass.text.trim(),
      );
      await travelerProv.loadTraveler();
      if (mounted) router.go('/');
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Login failed: ${e.toString().split(']').last}'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),

                  // ── Logo / Brand ─────────────────────────────────
                  Center(
                    child: Column(children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          boxShadow: AppShadows.button,
                        ),
                        child: const Icon(Icons.explore_rounded,
                            color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text('GuideGo',
                          style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w900,
                            color: AppColors.primary, letterSpacing: -0.5)),
                      const Text('Find your perfect local guide',
                          style: TextStyle(
                            fontSize: 14, color: AppColors.textSecondary)),
                    ]),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Heading ──────────────────────────────────────
                  const Text('Welcome back 👋',
                      style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('Sign in to continue your journey',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Email ────────────────────────────────────────
                  AuthInputField(
                    controller: _email,
                    label: 'Email address',
                    icon: Icons.email_outlined,
                    hint: 'your@email.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || !v.contains('@')
                        ? 'Enter a valid email' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Password ─────────────────────────────────────
                  AuthInputField(
                    controller: _pass,
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    hint: '••••••••',
                    obscureText: _obscure,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_outlined
                                 : Icons.visibility_off_outlined,
                        size: 18, color: AppColors.textTertiary,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) => v == null || v.length < 6
                        ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Login button ─────────────────────────────────
                  AppPrimaryButton(
                    label: 'Sign In',
                    onPressed: _login,
                    isLoading: _loading,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Sign up link ─────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/signup'),
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 14, color: AppColors.textSecondary),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
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
          ),
        ),
      ),
    );
  }
}
