import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../widgets/login_form.dart';
import '../widgets/divider_text.dart';
import '../widgets/social_login_button.dart';
import '../../../core/typography/app_text_styles.dart';
import 'signup_page.dart'; // Import the signup page

/// Login page - Main authentication screen
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  String _email = '';
  String _password = ''; // Added state for password

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      // Use Firebase Auth to sign in
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.trim(),
        password: _password,
      );

      // We do not need Navigator.pushReplacementNamed anymore
      // because the StreamBuilder in main.dart handles the navigation automatically
      // when it detects a successful login state.

    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed. Please try again.";
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        errorMessage = 'No user found for that email, or incorrect password.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password provided for that user.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleGoogleLogin() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Google login - Coming soon')));
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset - Coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ============ HEADER SECTION ============
                // NEST Logo
                SizedBox(
                  height: 80,
                  child: Image.asset(
                    'resources/LOGO.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        'NEST',
                        style: AppTextStyles.heading(
                          context,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 32,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // App Name
                Text(
                  'NEST',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading(
                    context,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 12),

                // Tagline
                Text(
                  'Take flight and find a home',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(context, fontSize: 16),
                ),
                const SizedBox(height: 40),

                // ============ FORM SECTION ============
                LoginForm(
                  isLoading: _isLoading,
                  onEmailChanged: (email) => _email = email,
                  onPasswordChanged: (password) => _password = password, // Capture password
                  onLoginPressed: _handleLogin,
                  onForgotPassword: _handleForgotPassword,
                ),
                const SizedBox(height: 32),

                // ============ DIVIDER SECTION ============
                const DividerText(),
                const SizedBox(height: 24),

                // ============ SOCIAL LOGIN SECTION ============
                SocialLoginButton(
                  imageAsset: 'resources/google_icon.webp',
                  isImageOnly: true,
                  onPressed: _handleGoogleLogin,
                ),
                const SizedBox(height: 16),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.body(context, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to the real SignupPage
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignupPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign up',
                        style: AppTextStyles.subheading(
                          context,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}