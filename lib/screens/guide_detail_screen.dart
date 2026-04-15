import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:guidego/core/app_theme.dart';
import 'package:guidego/core/widgets.dart';
import 'package:guidego/providers/guide_provider.dart';

class GuideDetailScreen extends StatefulWidget {
  final String guideId;
  const GuideDetailScreen({super.key, required this.guideId});

  @override
  State<GuideDetailScreen> createState() => _GuideDetailScreenState();
}

class _GuideDetailScreenState extends State<GuideDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuideProvider>().fetchGuideById(widget.guideId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<GuideProvider>();
    final guide = prov.selectedGuide;

    if (prov.loading || guide == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (prov.error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Oops!',
          subtitle: 'Failed to load guide details.',
          buttonLabel: 'Retry',
          onButtonTap: () =>
              context.read<GuideProvider>().fetchGuideById(widget.guideId),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      // ── Sticky bottom bar ──────────────────────────────────────────────
      bottomNavigationBar: _BottomBar(
        price: guide.dayRate ?? 0,
        onBook: () => context.push('/guide/${guide.id}/book/${guide.dayRate ?? 0}'),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── SliverAppBar – Hero image ────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.card,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _CircleIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => context.pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: guide.profileImage != null
                  ? Image.network(
                      guide.profileImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                        child: const Icon(Icons.person_rounded, size: 80, color: Colors.white),
                      ),
                    )
                  : Container(
                      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                      child: const Icon(Icons.person_rounded, size: 80, color: Colors.white),
                    ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Rating row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          guide.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _RatingBadge(rating: guide.rating),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Language chips
                  if (guide.languages != null && guide.languages!.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: guide.languages!
                          .map((l) => _LanguageChip(label: l))
                          .toList(),
                    ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Stats row ─────────────────────────────────────────
                  _StatsRow(guide: guide),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Bio ───────────────────────────────────────────────
                  if (guide.bio != null && guide.bio!.isNotEmpty) ...[
                    const Text('About',
                        style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      guide.bio!,
                      style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondary, height: 1.6),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // ── Info Cards ────────────────────────────────────────
                  _InfoGrid(guide: guide),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: AppShadows.card,
      ),
      child: Icon(icon, size: 16, color: AppColors.textPrimary),
    ),
  );
}

class _RatingBadge extends StatelessWidget {
  final double? rating;
  const _RatingBadge({this.rating});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.starYellow.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppRadius.full),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 16, color: AppColors.starYellow),
        const SizedBox(width: 3),
        Text(
          rating?.toStringAsFixed(1) ?? '—',
          style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ],
    ),
  );
}

class _LanguageChip extends StatelessWidget {
  final String label;
  const _LanguageChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.accentLight,
      borderRadius: BorderRadius.circular(AppRadius.full),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent),
    ),
  );
}

class _StatsRow extends StatelessWidget {
  final dynamic guide;
  const _StatsRow({required this.guide});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.star_rounded,
            value: guide.rating?.toStringAsFixed(1) ?? '—',
            label: 'Rating',
            iconColor: AppColors.starYellow,
          ),
          _divider(),
          _StatItem(
            icon: Icons.work_history_rounded,
            value: '${guide.experienceYears ?? 0}yr',
            label: 'Experience',
            iconColor: AppColors.primary,
          ),
          _divider(),
          _StatItem(
            icon: Icons.currency_rupee_rounded,
            value: guide.dayRate?.toStringAsFixed(0) ?? '—',
            label: 'Per Day',
            iconColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1, height: 40, color: AppColors.divider,
    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
  );
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  const _StatItem({
    required this.icon, required this.value,
    required this.label, required this.iconColor,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, size: 22, color: iconColor),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
      ],
    ),
  );
}

class _InfoGrid extends StatelessWidget {
  final dynamic guide;
  const _InfoGrid({required this.guide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Details',
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: AppSpacing.sm),
        _InfoTile(
          icon: Icons.language_rounded,
          title: 'Languages',
          value: guide.languages?.join(', ') ?? 'Not specified',
        ),
        const SizedBox(height: AppSpacing.sm),
        _InfoTile(
          icon: Icons.work_rounded,
          title: 'Experience',
          value: '${guide.experienceYears ?? 0} years',
        ),
        const SizedBox(height: AppSpacing.sm),
        _InfoTile(
          icon: Icons.currency_rupee_rounded,
          title: 'Day Rate',
          value: '₹${guide.dayRate?.toStringAsFixed(0) ?? '—'} per day',
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.md),
      boxShadow: AppShadows.card,
    ),
    child: Row(
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ],
        ),
      ],
    ),
  );
}

class _BottomBar extends StatelessWidget {
  final double price;
  final VoidCallback onBook;
  const _BottomBar({required this.price, required this.onBook});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(
      AppSpacing.md, AppSpacing.md,
      AppSpacing.md, AppSpacing.md + MediaQuery.of(context).padding.bottom,
    ),
    decoration: BoxDecoration(
      color: AppColors.card,
      boxShadow: AppShadows.strong,
    ),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Price', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            Text(
              '₹${price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
            const Text('per day', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppPrimaryButton(
            label: 'Book Now',
            icon: Icons.calendar_month_rounded,
            onPressed: onBook,
          ),
        ),
      ],
    ),
  );
}
