import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TopBarWidget extends StatelessWidget {
  final VoidCallback onDebugTap;

  const TopBarWidget({
    super.key,
    required this.onDebugTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('🇬🇧', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              const Text(
                'English',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: AppTheme.textSecondaryColor,
                size: 22,
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onDebugTap,
                child: Icon(
                  Icons.bug_report_outlined,
                  color: AppTheme.textSecondaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFAFAFA),
                ),
                child: const Center(
                  child: Icon(
                    Icons.notifications,
                    size: 20,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
