import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    const supabaseUrl = 'YOUR_SUPABASE_URL';
    if (!supabaseUrl.startsWith('YOUR_')) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: 'YOUR_SUPABASE_ANON_KEY',
      );
    }
  } catch (e) {
    debugPrint("Init failed: $e");
  }

  runApp(const TravelMasterApp());
}

class TravelMasterApp extends StatefulWidget {
  const TravelMasterApp({super.key});

  @override
  State<TravelMasterApp> createState() => _TravelMasterAppState();
}

class _TravelMasterAppState extends State<TravelMasterApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
      } else {
        // If system, toggle to the opposite of current brightness
        final brightness = MediaQuery.platformBrightnessOf(context);
        _themeMode = brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
      }
    });
  }

  Widget _getInitialScreen() {
    try {
      if (Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null) {
        return HomeScreen(onThemeToggle: _toggleTheme);
      }
    } catch (e) {
      debugPrint("Auth check error: $e");
    }
    return LoginScreen(onThemeToggle: _toggleTheme);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TravelMaster',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: _getInitialScreen(),
    );
  }
}
