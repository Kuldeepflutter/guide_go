import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:guidego/core/app_theme.dart';
import 'package:guidego/core/widgets.dart';
import 'package:guidego/providers/booking_provider.dart';
import 'package:guidego/services/auth_service.dart';

class BookingScreen extends StatefulWidget {
  final String guideId;
  final String amount;
  const BookingScreen({super.key, required this.guideId, required this.amount});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _loading = false;

  // Allowed time window — 6:00 to 21:00
  final int _minStart = 6 * 60;
  final int _maxEnd   = 21 * 60;

  int _toMin(TimeOfDay t) => t.hour * 60 + t.minute;

  void _snack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickStart() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 8, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (t == null) return;
    if (_toMin(t) < _minStart) {
      _snack('Start time must be 6:00 AM or later');
      return;
    }
    setState(() { _startTime = t; _endTime = null; });
  }

  Future<void> _pickEnd() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay(hour: 9, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (t == null) return;
    if (_startTime != null && _toMin(t) <= _toMin(_startTime!)) {
      _snack('End time must be after start time');
      return;
    }
    if (_toMin(t) > _maxEnd) {
      _snack('End time cannot be later than 9:00 PM');
      return;
    }
    setState(() => _endTime = t);
  }

  Future<void> _submit() async {
    if (_selectedDate == null || _startTime == null || _endTime == null) {
      _snack('Please select date and both times');
      return;
    }

    final user = AuthService().currentUser;
    if (user == null) { _snack('Not authenticated'); return; }

    final start = DateTime(
      _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
      _startTime!.hour, _startTime!.minute,
    );
    final end = DateTime(
      _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
      _endTime!.hour, _endTime!.minute,
    );

    final bookingData = {
      'traveler_id': user.id,
      'guide_id': widget.guideId,
      'start_time': start.toIso8601String(),
      'end_time': end.toIso8601String(),
      'total_amount': (double.tryParse(widget.amount) ?? 0).round(),
      'message': '',
      'status': 'pending',
      'payment_status': 'pending',
    };

    setState(() => _loading = true);
    try {
      await context.read<BookingProvider>().createBookingAndPay(context, bookingData);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _snack('Booking failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(widget.amount) ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Guide'),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section title ─────────────────────────────────────────
            const Text('Select Schedule',
                style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('Choose your preferred date and time',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.lg),

            // ── Date card ─────────────────────────────────────────────
            _SelectionCard(
              icon: Icons.calendar_today_rounded,
              iconColor: AppColors.primary,
              label: 'Date',
              value: _selectedDate == null
                  ? 'Tap to select date'
                  : DateFormat('EEEE, MMM d, yyyy').format(_selectedDate!),
              isPlaceholder: _selectedDate == null,
              onTap: _pickDate,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Time row ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _SelectionCard(
                    icon: Icons.access_time_rounded,
                    iconColor: AppColors.accent,
                    label: 'Start Time',
                    value: _startTime == null
                        ? 'Select'
                        : _startTime!.format(context),
                    isPlaceholder: _startTime == null,
                    onTap: _pickStart,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _SelectionCard(
                    icon: Icons.access_time_filled_rounded,
                    iconColor: AppColors.success,
                    label: 'End Time',
                    value: _endTime == null
                        ? 'Select'
                        : _endTime!.format(context),
                    isPlaceholder: _endTime == null,
                    onTap: _startTime == null ? null : _pickEnd,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Price summary ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Price Summary',
                      style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                  const SizedBox(height: AppSpacing.md),
                  _PriceRow(label: 'Day rate', value: '₹${amount.toStringAsFixed(0)}'),
                  const SizedBox(height: AppSpacing.sm),
                  _PriceRow(label: 'Service fee', value: '₹0', isAccent: true),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Divider(color: AppColors.divider),
                  ),
                  _PriceRow(
                    label: 'Total',
                    value: '₹${amount.toStringAsFixed(0)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── CTA ───────────────────────────────────────────────────
            AppPrimaryButton(
              label: 'Confirm Booking',
              icon: Icons.check_circle_outline_rounded,
              onPressed: _submit,
              isLoading: _loading,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Note ──────────────────────────────────────────────────
            const Center(
              child: Text(
                'You can cancel or reschedule up to 24 hours before',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isPlaceholder;
  final VoidCallback? onTap;

  const _SelectionCard({
    required this.icon, required this.iconColor,
    required this.label, required this.value,
    required this.isPlaceholder, this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
        border: Border.all(
          color: !isPlaceholder ? iconColor.withValues(alpha: 0.3) : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(
                  fontSize: 12, color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isPlaceholder ? FontWeight.w400 : FontWeight.w600,
              color: isPlaceholder ? AppColors.textTertiary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    ),
  );
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isAccent;
  final bool isTotal;

  const _PriceRow({
    required this.label, required this.value,
    this.isAccent = false, this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          )),
      Text(value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: isTotal
                ? AppColors.primary
                : isAccent
                    ? AppColors.success
                    : AppColors.textPrimary,
          )),
    ],
  );
}
