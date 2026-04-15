import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:guidego/core/app_theme.dart';
import 'package:guidego/core/widgets.dart';
import 'package:guidego/providers/booking_provider.dart';
import 'package:guidego/services/razorpay_service.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final int amount;
  final String orderId;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.orderId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  final RazorpayService _razorpayService = RazorpayService();
  bool _loading = true;
  bool _paymentFailed = false;
  String _statusMessage = 'Opening payment gateway...';

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _razorpayService.init(
      onSuccess: _handleSuccess,
      onError: _handleError,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _startPayment());
  }

  void _startPayment() {
    setState(() { _loading = false; _paymentFailed = false; _statusMessage = 'Opening payment gateway...'; });
    _razorpayService.openCheckout(
      key: dotenv.env['RAZORPAY_KEY'] ?? '',
      orderId: widget.orderId,
      amount: widget.amount,
      name: 'GuideGo',
      description: 'Guide Booking Payment',
    );
  }

  void _handleSuccess(PaymentSuccessResponse response) async {
    if (response.orderId == null || response.paymentId == null || response.signature == null) {
      _snack('Payment failed: Missing transaction details', isError: true);
      return;
    }

    setState(() { _loading = true; _statusMessage = 'Verifying payment...'; });

    try {
      await context.read<BookingProvider>().verifyPayment(
        bookingId: widget.bookingId,
        razorpayOrderId: response.orderId!,
        razorpayPaymentId: response.paymentId!,
        razorpaySignature: response.signature!,
      );
      if (mounted) {
        _snack('Payment verified! Booking confirmed.', isError: false);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _snack('Verification failed: $e', isError: true);
        Navigator.pop(context, false);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _handleError(PaymentFailureResponse response) async {
    await context.read<BookingProvider>().markPaymentFailed(widget.bookingId);
    if (mounted) {
      setState(() { _paymentFailed = true; _statusMessage = response.message ?? 'Payment was declined'; });
    }
  }

  void _snack(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.success,
    ));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _razorpayService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Icon (animated) ───────────────────────────────────────
            ScaleTransition(
              scale: _paymentFailed ? const AlwaysStoppedAnimation(1.0) : _pulseAnim,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: _paymentFailed
                      ? AppColors.errorLight
                      : _loading
                          ? AppColors.primaryLight
                          : AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _paymentFailed
                      ? Icons.error_outline_rounded
                      : _loading
                          ? Icons.lock_outline_rounded
                          : Icons.payment_rounded,
                  size: 48,
                  color: _paymentFailed ? AppColors.error : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Status ────────────────────────────────────────────────
            Text(
              _paymentFailed ? 'Payment Failed' : 'Secure Payment',
              style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _statusMessage,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Amount card ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.card,
              ),
              child: Column(children: [
                const Text('Amount to Pay',
                    style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '₹${widget.amount}',
                  style: const TextStyle(
                    fontSize: 36, fontWeight: FontWeight.w900,
                    color: AppColors.primary, letterSpacing: -1),
                ),
              ]),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Loading ───────────────────────────────────────────────
            if (_loading)
              const CircularProgressIndicator(color: AppColors.primary),

            // ── Retry / Go Back ───────────────────────────────────────
            if (_paymentFailed) ...[
              AppPrimaryButton(
                label: 'Retry Payment',
                icon: Icons.refresh_rounded,
                onPressed: _startPayment,
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
              ),
            ],

            // ── Security note ─────────────────────────────────────────
            if (!_paymentFailed)
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_rounded, size: 12, color: AppColors.textTertiary),
                    SizedBox(width: 4),
                    Text(
                      'Secured by Razorpay · 256-bit SSL',
                      style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}