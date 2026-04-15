import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Providers
import '../providers/traveler_provider.dart';
import '../providers/guide_provider.dart';
import '/providers/booking_provider.dart';
import '/providers/location_provider.dart';

// Router
import 'app_router.dart';

// Theme
import 'core/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Load environment variables from .env
  await dotenv.load(fileName: ".env");

  // ✅ Initialize Supabase using env vars (no hardcoded keys!)
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const GuideGoUserApp());
}

class GuideGoUserApp extends StatelessWidget {
  const GuideGoUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TravelerProvider()),
        ChangeNotifierProvider(create: (_) => GuideProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'GuideGo User',
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
