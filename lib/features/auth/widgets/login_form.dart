import 'package:flutter/material.dart';
import '../../../core/typography/app_text_styles.dart';

/// Reusable login form with email and password fields
class LoginForm extends StatefulWidget {
  final ValueChanged<String>? onEmailChanged;
  final ValueChanged<String>? onPasswordChanged;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onLoginPressed;
  final bool isLoading;

  const LoginForm({
    super.key,
    this.onEmailChanged,
    this.onPasswordChanged,
    this.onForgotPassword,
    this.onLoginPressed,
    this.isLoading = false,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isEmailValid =
        _emailController.text.isNotEmpty && _emailController.text.contains('@');
    final isPasswordValid =
        _passwordController.text.isNotEmpty &&
        _passwordController.text.length >= 6;

    setState(() {
      _isFormValid = isEmailValid && isPasswordValid;
    });

    widget.onEmailChanged?.call(_emailController.text);
    widget.onPasswordChanged?.call(_passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email field
        Text(
          'Email or Username',
          style: AppTextStyles.subheading(context, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          enabled: !widget.isLoading,
          decoration: InputDecoration(
            hintText: 'Enter your email or username',
            hintStyle: AppTextStyles.body(context),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),

        // Password field
        Text(
          'Password',
          style: AppTextStyles.subheading(context, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          enabled: !widget.isLoading,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: AppTextStyles.body(context),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Forgot password link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: widget.isLoading ? null : widget.onForgotPassword,
            child: Text(
              'Forgot password?',
              style: AppTextStyles.body(
                context,
                color: Theme.of(context).colorScheme.primary,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Login button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (!_isFormValid || widget.isLoading)
                ? null
                : widget.onLoginPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              disabledBackgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(
                    'Login',
                    style: AppTextStyles.subheading(
                      context,
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
