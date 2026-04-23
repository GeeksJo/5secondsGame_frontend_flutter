import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class SettingSection extends StatelessWidget {
  const SettingSection({
    super.key,
    required this.title,
    this.titleIcon,
    required this.children,
  });

  final String title;
  final IconData? titleIcon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          child: Row(
            children: [
              if (titleIcon != null) ...[
                Icon(titleIcon, size: 18, color: AppColors.textMuted),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppFonts.family,
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }
}
