import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'features/loading/screens/loading_screen.dart';
import 'features/landing/screens/landing_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEST',
      theme: AppColors.lightTheme,
      darkTheme: AppColors.darkTheme,
      themeMode: ThemeMode.system,
      home: const LoadingScreen(),
      routes: {
        '/loading': (context) => const LoadingScreen(),
        '/landing': (context) => const LandingPage(),
      },
    );
  }
}
