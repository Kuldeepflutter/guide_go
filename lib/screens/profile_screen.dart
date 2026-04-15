import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:guidego/core/app_theme.dart';
import 'package:guidego/core/widgets.dart';
import 'package:guidego/providers/traveler_provider.dart';
import 'package:guidego/services/auth_service.dart';
import 'package:guidego/services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  File? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final t = context.read<TravelerProvider>().traveler;
    _nameCtrl  = TextEditingController(text: t?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: t?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery, imageQuality: 85);
    if (x != null) setState(() => _pickedImage = File(x.path));
  }

  Future<void> _save() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final prov    = context.read<TravelerProvider>();
      final traveler = prov.traveler;
      if (traveler == null) throw Exception('User not found');

      String? newUrl;
      if (_pickedImage != null) {
        newUrl = await StorageService().uploadProfileImage(
          file: _pickedImage!, userId: traveler.id);
      }

      final updates = <String, dynamic>{};
      if (_nameCtrl.text.isNotEmpty && _nameCtrl.text != traveler.fullName) {
        updates['full_name'] = _nameCtrl.text;
      }
      if (_phoneCtrl.text != (traveler.phone ?? '')) {
        updates['phone'] = _phoneCtrl.text;
      }
      if (newUrl != null && newUrl != traveler.profileImage) {
        updates['profile_image'] = newUrl;
      }

      if (updates.isNotEmpty) await prov.updateProfile(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _pickedImage = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text('Sign Out?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService().signOut();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final traveler = context.watch<TravelerProvider>().traveler;

    if (traveler == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header banner ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.card,
            title: const Text('My Profile'),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: [
                    // ── Avatar ──────────────────────────────────────
                    _AvatarSection(
                      traveler: traveler,
                      pickedImage: _pickedImage,
                      onPick: _pickImage,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Name display ─────────────────────────────────
                    Text(
                      traveler.fullName,
                      style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary),
                    ),
                    Text(
                      traveler.email,
                      style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Edit fields ──────────────────────────────────
                    _SectionLabel(label: 'Personal Info'),
                    const SizedBox(height: AppSpacing.sm),

                    _FieldCard(
                      controller: _nameCtrl,
                      label: 'Full Name',
                      icon: Icons.person_outline_rounded,
                      hint: 'Enter your full name',
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    _FieldCard(
                      controller: _phoneCtrl,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      hint: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Email (read-only)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: AppShadows.card,
                      ),
                      child: Row(children: [
                        const Icon(Icons.email_outlined,
                            size: 20, color: AppColors.textTertiary),
                        const SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Email',
                                style: TextStyle(
                                  fontSize: 12, color: AppColors.textTertiary)),
                            Text(traveler.email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary)),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: const Text('Verified',
                              style: TextStyle(
                                fontSize: 11, color: AppColors.success,
                                fontWeight: FontWeight.w600)),
                        ),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Save button ──────────────────────────────────
                    AppPrimaryButton(
                      label: 'Save Changes',
                      icon: Icons.check_rounded,
                      onPressed: _save,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Sign out ─────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout_rounded, size: 18,
                            color: AppColors.error),
                        label: const Text('Sign Out',
                            style: TextStyle(color: AppColors.error)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          foregroundColor: AppColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarSection extends StatelessWidget {
  final dynamic traveler;
  final File? pickedImage;
  final VoidCallback onPick;
  const _AvatarSection({required this.traveler, this.pickedImage, required this.onPick});

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: AppShadows.strong,
        ),
        child: CircleAvatar(
          radius: 52,
          backgroundColor: AppColors.primaryLight,
          backgroundImage: pickedImage != null
              ? FileImage(pickedImage!) as ImageProvider
              : (traveler.profileImage != null && traveler.profileImage!.isNotEmpty)
                  ? NetworkImage(traveler.profileImage!)
                  : null,
          child: (pickedImage == null &&
              (traveler.profileImage == null || traveler.profileImage!.isEmpty))
              ? Text(
                  traveler.fullName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.primary),
                )
              : null,
        ),
      ),
      Positioned(
        bottom: 0, right: 0,
        child: GestureDetector(
          onTap: onPick,
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: AppShadows.card,
            ),
            child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
          ),
        ),
      ),
    ],
  );
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(label,
        style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w700,
          color: AppColors.textTertiary, letterSpacing: 0.5)),
  );
}

class _FieldCard extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;
  final TextInputType? keyboardType;

  const _FieldCard({
    required this.controller, required this.label,
    required this.icon, required this.hint, this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.md),
      boxShadow: AppShadows.card,
    ),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textTertiary),
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      ),
    ),
  );
}
