import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/date_formatter_id.dart';
import 'features/splash/splash_screen.dart';
import 'providers/profile_provider.dart';
import 'providers/report_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DateFormatterId.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(CollageGeneratorApp(storage: LocalStorageService(prefs)));
}

final class CollageGeneratorApp extends StatelessWidget {
  const CollageGeneratorApp({super.key, required this.storage});

  final LocalStorageService storage;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(storage)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportProvider(storage)..load(),
        ),
      ],
      child: MaterialApp(
        title: 'Collage Generator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        supportedLocales: const [Locale('id'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SplashScreen(),
      ),
    );
  }
}

