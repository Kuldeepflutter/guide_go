import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:guidego/core/app_theme.dart';
import 'package:guidego/core/widgets.dart';
import 'package:guidego/providers/booking_provider.dart';

class LocationScreen extends StatefulWidget {
  final String bookingId;
  const LocationScreen({super.key, required this.bookingId});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  LatLng _selected = const LatLng(23.2830, 77.4552); // Default: Bhopal
  final MapController _mapCtrl = MapController();
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await context.read<BookingProvider>().updateBookingLocation(
        bookingId: widget.bookingId,
        location: '${_selected.latitude},${_selected.longitude}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location saved!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
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
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: AppShadows.card,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: AppColors.textPrimary),
            ),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: AppShadows.card,
          ),
          child: const Text(
            'Pin Meeting Location',
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: _selected,
              initialZoom: 14.0,
              onTap: (_, point) => setState(() => _selected = point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.guidego.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selected,
                    width: 64,
                    height: 64,
                    child: Column(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.button,
                          ),
                          child: const Icon(Icons.person_pin_rounded,
                              color: Colors.white, size: 20),
                        ),
                        // Pin stem
                        Container(width: 2, height: 10, color: AppColors.primary),
                        Container(
                          width: 8, height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Bottom card ───────────────────────────────────────────────
          Positioned(
            bottom: 20, left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.strong,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 14, color: AppColors.textTertiary),
                      SizedBox(width: 6),
                      Text(
                        'Tap on the map to select a meeting point',
                        style: TextStyle(
                          fontSize: 12, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(children: [
                      const Icon(Icons.location_on_rounded,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_selected.latitude.toStringAsFixed(5)},  ${_selected.longitude.toStringAsFixed(5)}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppPrimaryButton(
                    label: 'Save This Location',
                    icon: Icons.check_rounded,
                    onPressed: _save,
                    isLoading: _saving,
                  ),
                ],
              ),
            ),
          ),

          // ── Crosshair hint ─────────────────────────────────────────
          const Center(
            child: IgnorePointer(
              child: Icon(Icons.add, color: AppColors.textTertiary, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}