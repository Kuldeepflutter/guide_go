import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:guidego/core/app_theme.dart';
import 'package:guidego/core/widgets.dart';
import 'package:guidego/models/guide.dart';
import 'package:guidego/models/location.dart';
import 'package:guidego/providers/guide_provider.dart';
import 'package:guidego/providers/location_provider.dart';
import 'package:guidego/providers/traveler_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().fetchLocations();
      context.read<GuideProvider>().fetchGuides();
      context.read<TravelerProvider>().loadTraveler();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await context.read<LocationProvider>().fetchLocations();
            await context.read<GuideProvider>().fetchGuides();
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header + Search ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(),
                      const SizedBox(height: AppSpacing.lg),
                      _GreetingText(),
                      const SizedBox(height: AppSpacing.md),
                      _SearchBar(),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),

              // ── Nearby Guides ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: SectionHeader(
                    title: '🔥 Nearby Guides',
                    onSeeAll: () => context.push('/search'),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              SliverToBoxAdapter(child: _NearbyGuidesList()),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

              // ── Popular Destinations ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: SectionHeader(title: '📍 Popular Destinations'),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              SliverToBoxAdapter(child: _DestinationsList()),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

              // ── Top Rated Guides Grid ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: SectionHeader(
                    title: '⭐ Top Rated Guides',
                    onSeeAll: () => context.push('/search'),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              SliverToBoxAdapter(child: _TopGuidesGrid()),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── HEADER ──────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(Icons.explore_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'GuideGo',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        // Notifications + Profile
        Consumer<TravelerProvider>(
          builder: (context, prov, _) {
            return Row(
              children: [
                _iconButton(Icons.notifications_outlined, () {}),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: () => context.go('/profile'),
                  child: UserAvatar(
                    imageUrl: prov.traveler?.profileImage,
                    name: prov.traveler?.fullName,
                    radius: 18,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: AppShadows.card,
      ),
      child: Icon(icon, size: 20, color: AppColors.textPrimary),
    ),
  );
}

// ─── GREETING ────────────────────────────────────────────────────────────────
class _GreetingText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TravelerProvider>(
      builder: (context, prov, _) {
        final name = prov.traveler?.fullName.split(' ').first ?? 'Traveler';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $name 👋',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Where do you want to go?',
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
          ],
        );
      },
    );
  }
}

// ─── SEARCH BAR ──────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/search'),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Search destinations, guides...',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(Icons.tune_rounded, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── NEARBY GUIDES (horizontal scroll) ────────────────────────────────────────
class _NearbyGuidesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GuideProvider>(
      builder: (context, prov, _) {
        if (prov.loading && prov.guides.isEmpty) {
          return SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (_, __) => const ShimmerBox(width: 140, height: 190, radius: AppRadius.lg),
            ),
          );
        }

        if (prov.guides.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(child: Text('No guides available', style: TextStyle(color: AppColors.textSecondary))),
          );
        }

        return SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: prov.guides.take(8).length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (_, i) => NearbyGuideCard(guide: prov.guides[i]),
          ),
        );
      },
    );
  }
}

class NearbyGuideCard extends StatelessWidget {
  final Guide guide;
  const NearbyGuideCard({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/guide/${guide.id}'),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
              child: guide.profileImage != null
                  ? Image.network(
                      guide.profileImage!,
                      width: 140, height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guide.fullName,
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.star_rounded, size: 12, color: AppColors.starYellow),
                    const SizedBox(width: 2),
                    Text(
                      guide.rating?.toStringAsFixed(1) ?? '—',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    '₹${guide.dayRate?.toStringAsFixed(0) ?? '—'}/day',
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 140, height: 110,
    color: AppColors.primaryLight,
    child: const Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
  );
}

// ─── POPULAR DESTINATIONS (horizontal) ────────────────────────────────────────
class _DestinationsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading && prov.locations.isEmpty) {
          return SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (_, __) => const ShimmerBox(width: 160, height: 140, radius: AppRadius.lg),
            ),
          );
        }

        if (prov.locations.isEmpty) {
          return const SizedBox(
            height: 80,
            child: Center(child: Text('No destinations', style: TextStyle(color: AppColors.textSecondary))),
          );
        }

        return SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: prov.locations.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (_, i) => DestinationCard(location: prov.locations[i]),
          ),
        );
      },
    );
  }
}

class DestinationCard extends StatelessWidget {
  final Location location;
  const DestinationCard({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        width: 160,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            if (location.imageUrl != null)
              Image.network(
                location.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.primaryLight),
              )
            else
              Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              ),
            // Gradient overlay
            const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.darkOverlay)),
            // Text
            Positioned(
              bottom: AppSpacing.md,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Text(
                location.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── TOP RATED GUIDES (2-column grid) ────────────────────────────────────────
class _TopGuidesGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GuideProvider>(
      builder: (context, prov, _) {
        if (prov.loading && prov.guides.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12,
                mainAxisSpacing: 12, childAspectRatio: 0.8,
              ),
              itemCount: 4,
              itemBuilder: (_, __) => const ShimmerBox(width: double.infinity, height: 220, radius: AppRadius.lg),
            ),
          );
        }

        if (prov.error != null) {
          return const Center(child: Text('Could not load guides.', style: TextStyle(color: AppColors.textSecondary)));
        }

        final sorted = [...prov.guides]
          ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 12,
              mainAxisSpacing: 12, childAspectRatio: 0.78,
            ),
            itemCount: sorted.take(6).length,
            itemBuilder: (_, i) => TopGuideCard(guide: sorted[i]),
          ),
        );
      },
    );
  }
}

class TopGuideCard extends StatelessWidget {
  final Guide guide;
  const TopGuideCard({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/guide/${guide.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
              child: guide.profileImage != null
                  ? Image.network(
                      guide.profileImage!,
                      width: double.infinity, height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guide.fullName,
                    style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.star_rounded, size: 13, color: AppColors.starYellow),
                    const SizedBox(width: 3),
                    Text(
                      guide.rating?.toStringAsFixed(1) ?? '—',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    Text(
                      '₹${guide.dayRate?.toStringAsFixed(0) ?? '—'}',
                      style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ]),
                  if (guide.languages != null && guide.languages!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      guide.languages!.take(2).join(' · '),
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: double.infinity, height: 120,
    color: AppColors.primaryLight,
    child: const Icon(Icons.person_rounded, size: 42, color: AppColors.primary),
  );
}