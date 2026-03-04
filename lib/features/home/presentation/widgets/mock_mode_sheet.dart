import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../wallet/data/datasources/wallet_remote_datasource.dart';
import '../../../wallet/presentation/cubit/wallet_cubit.dart';

class MockModeSheet {
  static void show(BuildContext context) {
    final cubit = context.read<WalletCubit>();
    final datasource = sl<WalletRemoteDataSource>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Debug: Mock Mode',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _ModeOption(
              icon: Icons.check_circle,
              color: AppTheme.successColor,
              label: 'Success',
              subtitle: 'Normal data flow',
              onTap: () {
                datasource.setMode(MockMode.success);
                Navigator.pop(sheetContext);
                cubit.reset();
              },
            ),
            _ModeOption(
              icon: Icons.wifi_off,
              color: AppTheme.errorColor,
              label: 'Network Error',
              subtitle: 'Simulates no internet connection',
              onTap: () {
                datasource.setMode(MockMode.networkError);
                Navigator.pop(sheetContext);
                cubit.reset();
              },
            ),
            _ModeOption(
              icon: Icons.cloud_off,
              color: Colors.orange,
              label: 'Server Error',
              subtitle: 'Simulates HTTP 500 error',
              onTap: () {
                datasource.setMode(MockMode.serverError);
                Navigator.pop(sheetContext);
                cubit.reset();
              },
            ),
            _ModeOption(
              icon: Icons.timer_off,
              color: Colors.purple,
              label: 'Timeout',
              subtitle: 'Simulates 5s delay then timeout error',
              onTap: () {
                datasource.setMode(MockMode.timeout);
                Navigator.pop(sheetContext);
                cubit.reset();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
