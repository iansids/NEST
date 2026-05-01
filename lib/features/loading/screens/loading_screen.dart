import 'package:flutter/material.dart';
import '../widgets/loading_animation.dart';

/// Loading screen that displays on app startup
/// Shows animation for 3 seconds then navigates to landing page
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLanding();
  }

  Future<void> _navigateToLanding() async {
    // Wait for animation + buffer time (3 seconds total)
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.surface,
        child: const LoadingAnimation(duration: Duration(milliseconds: 2000)),
      ),
    );
  }
}
