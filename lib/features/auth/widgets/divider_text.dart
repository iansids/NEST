import 'package:flutter/material.dart';
import '../../../core/typography/app_text_styles.dart';

/// Divider with centered text
/// Used for "Or continue with" sections
class DividerText extends StatelessWidget {
  final String text;

  const DividerText({super.key, this.text = 'Or continue with'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.outlineVariant,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(text, style: AppTextStyles.body(context, fontSize: 13)),
        ),
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.outlineVariant,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
