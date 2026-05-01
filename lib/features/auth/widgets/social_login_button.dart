import 'package:flutter/material.dart';
import '../../../core/typography/app_text_styles.dart';

/// Reusable social login button
/// Supports text+icon style or image-only style (for Google, Apple, etc.)
class SocialLoginButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final String? imageAsset;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isImageOnly;

  const SocialLoginButton({
    super.key,
    this.label,
    this.icon,
    this.imageAsset,
    required this.onPressed,
    this.isLoading = false,
    this.isImageOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Image-only button (for Google, Apple icons)
    if (isImageOnly && imageAsset != null) {
      return SizedBox(
        width: 56,
        height: 56,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline,
              width: 1.5,
            ),
            backgroundColor: isDark
                ? Theme.of(context).colorScheme.surface
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Image.asset(
            imageAsset!,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    // Text + Icon button (traditional style)
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            : Icon(icon),
        label: Text(
          label ?? '',
          style: AppTextStyles.subheading(context, fontSize: 15),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1.5,
          ),
          backgroundColor: isDark
              ? Theme.of(context).colorScheme.surface
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
