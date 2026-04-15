import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Screens
import 'package:guidego/screens/splash_screen.dart';
import 'package:guidego/screens/home_screen.dart';
import 'package:guidego/screens/profile_screen.dart';
import 'package:guidego/screens/guide_detail_screen.dart';
import 'package:guidego/screens/booking_screen.dart';
import 'package:guidego/screens/my_bookings_screen.dart';
import 'package:guidego/screens/search_screen.dart';
import 'package:guidego/screens/auth/login_screen.dart';
import 'package:guidego/screens/auth/signup_screen.dart';

// Theme
import 'package:guidego/core/app_theme.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: false,

    redirect: (BuildContext context, GoRouterState state) {
      final loggedIn = Supabase.instance.client.auth.currentUser != null;
      final isAuth   = state.matchedLocation == '/login' ||
                       state.matchedLocation == '/signup';

      if (!loggedIn && !isAuth && state.matchedLocation != '/splash') {
        return '/login';
      }
      if (loggedIn && isAuth) return '/';
      return null;
    },

    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignupScreen(),
      ),
      // ── Search (outside shell so it slides over) ──────────────────
      GoRoute(
        path: '/search',
        builder: (_, __) => const SearchScreen(),
      ),

      // ── Main shell with bottom nav ────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            _AppShell(navigationShell: shell),
        branches: [
          // Home branch
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (_, __) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'guide/:id',
                  name: 'guideDetail',
                  builder: (_, state) =>
                      GuideDetailScreen(guideId: state.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'book/:amount',
                      name: 'bookGuide',
                      builder: (_, state) => BookingScreen(
                        guideId: state.pathParameters['id']!,
                        amount: state.pathParameters['amount']!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ]),

          // Bookings branch
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/bookings',
              name: 'bookings',
              builder: (_, __) => const MyBookingsScreen(),
            ),
          ]),

          // Profile branch
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (_, __) => const ProfileScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
}

// ─── PREMIUM BOTTOM NAV SHELL ─────────────────────────────────────────────────
class _AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const _AppShell({required this.navigationShell});

  static const _items = [
    _NavItem(icon: Icons.home_outlined,    activeIcon: Icons.home_rounded,            label: 'Home'),
    _NavItem(icon: Icons.book_outlined,    activeIcon: Icons.book_rounded,            label: 'Bookings'),
    _NavItem(icon: Icons.person_outlined,  activeIcon: Icons.person_rounded,          label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (i) {
                final item     = _items[i];
                final selected = navigationShell.currentIndex == i;
                return _NavButton(
                  item: item,
                  selected: selected,
                  onTap: () => navigationShell.goBranch(
                    i,
                    initialLocation: i == navigationShell.currentIndex,
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item, required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              size: 22,
              color: selected ? AppColors.primary : AppColors.textTertiary,
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
