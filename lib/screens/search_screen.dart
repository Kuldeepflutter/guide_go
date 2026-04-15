import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:guidego/core/app_theme.dart';
import 'package:guidego/core/widgets.dart';
import 'package:guidego/models/guide.dart';
import 'package:guidego/providers/guide_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  String? _selectedFilter; // 'location' | 'price' | 'rating'

  static const _filters = [
    ('location', Icons.location_on_rounded, 'Location'),
    ('price', Icons.currency_rupee_rounded, 'Price'),
    ('rating', Icons.star_rounded, 'Rating'),
    ('language', Icons.language_rounded, 'Language'),
  ];

  List<Guide> _filtered(List<Guide> all) {
    var result = all;

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      result = result.where((g) {
        final nameMatcher = g.fullName.toLowerCase().contains(q);
        final langMatcher = g.languages?.any((l) => l.toLowerCase().contains(q)) ?? false;
        final bioMatcher = g.bio?.toLowerCase().contains(q) ?? false;
        return nameMatcher || langMatcher || bioMatcher;
      }).toList();
    }

    if (_selectedFilter == 'rating') {
      result.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    } else if (_selectedFilter == 'price') {
      result.sort((a, b) => (a.dayRate ?? 0).compareTo(b.dayRate ?? 0));
    }

    return result;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Search Guides'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // ── Search Bar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, 0, AppSpacing.md, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.card,
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search by name, language, destination...',
                  hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textTertiary),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  filled: false,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Filter chips ──────────────────────────────────────────────
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              children: _filters.map((f) {
                final (id, icon, label) = f;
                final selected = _selectedFilter == id;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () => setState(() =>
                        _selectedFilter = selected ? null : id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        boxShadow: AppShadows.card,
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.divider,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 14,
                              color: selected ? Colors.white : AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Results ───────────────────────────────────────────────────
          Expanded(
            child: Consumer<GuideProvider>(
              builder: (context, prov, _) {
                if (prov.loading) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    itemCount: 5,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, __) => const ShimmerBox(
                        width: double.infinity, height: 90, radius: AppRadius.lg),
                  );
                }

                final results = _filtered(prov.guides);

                if (results.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No guides found',
                    subtitle: _query.isEmpty
                        ? 'Start typing to search for guides'
                        : 'Try a different keyword or filter',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  physics: const BouncingScrollPhysics(),
                  itemCount: results.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (_, i) =>
                      SearchGuideCard(guide: results[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchGuideCard extends StatelessWidget {
  final Guide guide;
  const SearchGuideCard({super.key, required this.guide});

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
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppRadius.lg)),
              child: guide.profileImage != null
                  ? Image.network(
                      guide.profileImage!,
                      width: 90, height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.fullName,
                      style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    if (guide.languages != null &&
                        guide.languages!.isNotEmpty)
                      Text(
                        guide.languages!.take(3).join(' · '),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          size: 13, color: AppColors.starYellow),
                      const SizedBox(width: 3),
                      Text(
                        guide.rating?.toStringAsFixed(1) ?? '—',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      Text(
                        '₹${guide.dayRate?.toStringAsFixed(0) ?? '—'}/day',
                        style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.md),
              child: Icon(Icons.chevron_right_rounded,
                  color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 90, height: 90,
    color: AppColors.primaryLight,
    child: const Icon(Icons.person_rounded, size: 36, color: AppColors.primary),
  );
}
