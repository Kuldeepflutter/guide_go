import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:guidego/core/app_theme.dart';
import 'package:guidego/core/widgets.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String guideName;
  final String date;
  final String time;
  final String amount;

  const PaymentSuccessScreen({
    super.key,
    required this.guideName,
    required this.date,
    required this.time,
    required this.amount,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    Future.delayed(const Duration(milliseconds: 200), () => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                const Spacer(),

                // ── Success icon ──────────────────────────────────────
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 64,
                      color: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Heading ───────────────────────────────────────────
                const Text(
                  'Booking Confirmed!',
                  style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary, letterSpacing: -0.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Your guide has been booked successfully.',
                  style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Booking details card ───────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.person_rounded,
                        label: 'Guide',
                        value: widget.guideName,
                        iconColor: AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _DetailRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Date',
                        value: widget.date,
                        iconColor: AppColors.accent,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _DetailRow(
                        icon: Icons.access_time_rounded,
                        label: 'Time',
                        value: widget.time,
                        iconColor: AppColors.warning,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Divider(color: AppColors.divider),
                      ),
                      _DetailRow(
                        icon: Icons.currency_rupee_rounded,
                        label: 'Amount Paid',
                        value: '₹${widget.amount}',
                        iconColor: AppColors.success,
                        isTotal: true,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ── CTAs ─────────────────────────────────────────────
                AppPrimaryButton(
                  label: 'View My Bookings',
                  icon: Icons.book_online_rounded,
                  onPressed: () => context.go('/bookings'),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Back to Home'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final bool isTotal;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            Text(
              value,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
                color: isTotal ? AppColors.success : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
