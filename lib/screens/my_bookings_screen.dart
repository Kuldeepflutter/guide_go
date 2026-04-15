import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:guidego/core/app_theme.dart';
import 'package:guidego/core/widgets.dart';
import 'package:guidego/models/booking.dart';
import 'package:guidego/providers/booking_provider.dart';
import 'package:guidego/providers/guide_provider.dart';
import 'package:guidego/screens/booking_location_screen.dart';
import 'package:guidego/screens/location_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  static const _tabs = ['Upcoming', 'Past', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadBookings();
      context.read<GuideProvider>().fetchGuides();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppColors.background,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, prov, _) {
          if (prov.loading && prov.bookings.isEmpty) {
            return _LoadingList();
          }

          if (prov.bookings.isEmpty) {
            return EmptyState(
              icon: Icons.book_online_rounded,
              title: 'No Bookings Yet',
              subtitle: 'Your confirmed bookings\nwill appear here.',
            );
          }

          final now = DateTime.now();

          final upcoming   = prov.bookings.where((b) => b.status != 'cancelled' && b.endTime.isAfter(now)).toList();
          final past       = prov.bookings.where((b) => b.status != 'cancelled' && b.endTime.isBefore(now)).toList();
          final cancelled  = prov.bookings.where((b) => b.status == 'cancelled').toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<BookingProvider>().loadBookings(),
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _BookingList(bookings: upcoming, emptyLabel: 'No upcoming bookings'),
                _BookingList(bookings: past, emptyLabel: 'No past bookings'),
                _BookingList(bookings: cancelled, emptyLabel: 'No cancelled bookings'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(AppSpacing.md),
    itemCount: 4,
    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
    itemBuilder: (_, __) => const ShimmerBox(
        width: double.infinity, height: 130, radius: AppRadius.lg),
  );
}

class _BookingList extends StatelessWidget {
  final List<Booking> bookings;
  final String emptyLabel;

  const _BookingList({required this.bookings, required this.emptyLabel});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return EmptyState(
        icon: Icons.inbox_rounded,
        title: emptyLabel,
        subtitle: '',
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, i) => BookingCard(booking: bookings[i]),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Booking booking;
  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final guideProvider = context.watch<GuideProvider>();

    final guide = guideProvider.guides
        .where((g) => g.id == booking.guideId)
        .isEmpty
        ? null
        : guideProvider.guides
        .firstWhere((g) => g.id == booking.guideId);

    // ✅ FIX: check if booking is still upcoming
    final isUpcoming = booking.endTime.isAfter(DateTime.now());

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                UserAvatar(
                  imageUrl: guide?.profileImage,
                  name: guide?.fullName ?? 'G',
                  radius: 26,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide?.fullName ?? 'Unknown Guide',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('EEE, MMM d, yyyy')
                            .format(booking.startTime),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusChip(status: booking.status),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // ── Time + Price ───────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                _Chip(
                  icon: Icons.access_time_rounded,
                  label:
                  '${DateFormat('hh:mm a').format(booking.startTime)} – ${DateFormat('hh:mm a').format(booking.endTime)}',
                ),
                const Spacer(),
                _Chip(
                  icon: Icons.currency_rupee_rounded,
                  label:
                  '₹${booking.totalAmount.toStringAsFixed(0)}',
                  isAccent: true,
                ),
              ],
            ),
          ),

          // 🔥 FIXED CONDITION HERE
          if (booking.status == 'confirmed' && isUpcoming) ...[
            const Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.location_on_outlined,
                      label: 'View Location',
                      color: AppColors.accent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingLocationView(
                            bookingId: booking.id,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.edit_location_alt_outlined,
                      label: 'Update Location',
                      color: AppColors.primary,
                      onTap: () =>
                          _showUpdateDialog(context, booking.id),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(AppRadius.lg)),
        title: const Text('Update Location',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Do you want to share a meeting location with your guide?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      LocationScreen(bookingId: bookingId),
                ),
              );
            },
            child: const Text('Yes, Share'),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isAccent;
  const _Chip({required this.icon, required this.label, this.isAccent = false});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: isAccent ? AppColors.success : AppColors.textSecondary),
      const SizedBox(width: 4),
      Text(label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isAccent ? FontWeight.w700 : FontWeight.w400,
            color: isAccent ? AppColors.success : AppColors.textSecondary,
          )),
    ],
  );
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon, required this.label,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 15, color: color),
    label: Text(label,
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    style: TextButton.styleFrom(
      backgroundColor: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      padding: const EdgeInsets.symmetric(vertical: 8),
    ),
  );
}
