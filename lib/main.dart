import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'providers/auth_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/meal_provider.dart';
import 'services/preferences_service.dart';
import 'theme/app_theme.dart';

import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/activity/add_activity_screen.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized for local storage access
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Core Services
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Preferences Service
  await PreferencesService.init();

  runApp(const FitTrackApp());
}

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<ActivityProvider>(
          create: (_) => ActivityProvider(),
        ),
        ChangeNotifierProvider<MealProvider>(
          create: (_) => MealProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'FitTrack',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/email-verification': (context) => const EmailVerificationScreen(),
          '/main': (context) => const MainNavigation(),
          '/add': (context) => const AddActivityScreen(),
        },
      ),
    );
  }
}
