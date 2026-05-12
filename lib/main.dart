import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'firebase_options.dart';

import 'core/theme/app_colors.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/auth/screens/login_page.dart'; // Add this import
import 'features/auth/screens/signup_page.dart';

void main() async {
  // 1. Ensure plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const NestApp());
}

class NestApp extends StatelessWidget {
  const NestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEST Microblog',
      debugShowCheckedModeBanner: false,
      theme: AppColors.lightTheme,
      darkTheme: AppColors.darkTheme,
      themeMode: ThemeMode.system,
      routes: {
        '/signup': (context) => const SignupPage(),
      },
      // 3. Setup StreamBuilder for automatic redirect logic
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show a loading spinner while Firebase initializes the auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // If a user is successfully logged in, redirect to Dashboard
          if (snapshot.hasData) {
            return const DashboardScreen();
          }

          // Otherwise, redirect to Login Page
          return const LoginPage();
        },
      ),
    );
  }
}