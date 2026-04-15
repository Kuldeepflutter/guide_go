import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:guidego/core/app_theme.dart';
import 'package:guidego/core/widgets.dart';
import 'package:guidego/providers/traveler_provider.dart';
import 'package:guidego/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name    = TextEditingController();
  final _email   = TextEditingController();
  final _pass    = TextEditingController();
  bool _loading  = false;
  bool _obscure  = true;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService().signUpTraveler(
        email: _email.text.trim(),
        password: _pass.text.trim(),
        fullName: _name.text.trim(),
      );
      if (mounted) {
        await context.read<TravelerProvider>().loadTraveler();
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Signup failed: ${e.toString().split(']').last}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
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
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // ── Back button ───────────────────────────────────
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      boxShadow: AppShadows.card,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Heading ───────────────────────────────────────
                const Text('Create account 🚀',
                    style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                const Text('Join thousands of happy travelers',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.xl),

                // ── Name ─────────────────────────────────────────
                AuthInputField(
                  controller: _name,
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  hint: 'John Doe',
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Email ─────────────────────────────────────────
                AuthInputField(
                  controller: _email,
                  label: 'Email address',
                  icon: Icons.email_outlined,
                  hint: 'your@email.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Password ──────────────────────────────────────
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
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 8),

                // Terms
                const Text(
                  'By signing up you agree to our Terms & Privacy Policy',
                  style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Signup button ─────────────────────────────────
                AppPrimaryButton(
                  label: 'Create Account',
                  onPressed: _signup,
                  isLoading: _loading,
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Login link ────────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/login'),
                    child: RichText(
                      text: const TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary),
                        children: [
                          TextSpan(
                            text: 'Sign In',
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
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
