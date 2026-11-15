import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/editor/poster_preview_screen.dart';
import 'features/home/history_tab.dart';
import 'features/home/home_tab.dart';
import 'features/profile/profile_tab.dart';
import 'providers/profile_provider.dart';
import 'providers/report_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        home: const HomeShell(),
      ),
    );
  }
}

/// Root shell with bottom navigation: Beranda, Riwayat, Profile.
final class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Beranda',
    ),
    NavigationDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history_rounded),
      label: 'Riwayat',
    ),
    NavigationDestination(
      icon: Icon(Icons.business_outlined),
      selectedIcon: Icon(Icons.business_rounded),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Deep in the report flow (template picked), offer to continue draft.
    final inFlow = context.watch<ReportProvider>().report.templateId != null;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeTab(),
          HistoryTab(),
          ProfileTab(),
        ],
      ),
      floatingActionButton: inFlow
          ? FloatingActionButton.extended(
              heroTag: 'continue-flow',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PosterPreviewScreen(),
                ),
              ),
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Lanjut Draft'),
            )
          : null,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: _destinations,
          ),
        ],
      ),
    );
  }
}

