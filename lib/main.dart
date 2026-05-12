import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // This imports the class you provided

import 'core/theme/app_colors.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

void main() async {
  // 1. Ensure plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase using the currentPlatform getter from your provided code
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
      home: const DashboardScreen(),
    );
  }
}