import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'providers/sync_provider.dart';
import 'providers/equipment_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/fuel_entry_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/transaction_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'services/database_service.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local database
  await DatabaseService.instance.database;
  
  // Log API URL for verification
  debugPrint('🚀 APP STARTING - API URL: ${ApiService.baseUrl}');
  
  runApp(const FuelManagementApp());
}

class FuelManagementApp extends StatelessWidget {
  const FuelManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
        ChangeNotifierProvider(create: (_) => EquipmentProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'Fuel Management',
            debugShowCheckedModeBanner: false,
            
            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            
            // Localization
            locale: languageProvider.locale,
            supportedLocales: const [
              Locale('ar', ''), // Arabic
              Locale('en', ''), // English
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            
            // Routes
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(), // Main screen with bottom nav
              '/fuel-entry': (context) => const FuelEntryScreen(),
              '/scanner': (context) => const ScannerScreen(),
              '/transaction': (context) => const TransactionScreen(),
              '/history': (context) => const HistoryScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
