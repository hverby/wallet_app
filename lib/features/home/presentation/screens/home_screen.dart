import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../wallet/data/datasources/wallet_remote_datasource.dart';
import '../../../wallet/presentation/cubit/wallet_cubit.dart';
import '../../../wallet/presentation/widgets/balance_card.dart';
import '../../../wallet/presentation/widgets/balance_shimmer.dart';
import '../../../wallet/presentation/widgets/error_retry_widget.dart';
import '../../../wallet/presentation/widgets/transaction_list.dart';
import '../../../wallet/presentation/widgets/transaction_list_shimmer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WalletCubit>()..getWalletOverview(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wallet'),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.bug_report_outlined),
                tooltip: 'Debug: Change mock mode',
                onPressed: () => _showMockModeSheet(context),
              ),
            ),
          ],
        ),
        body: BlocConsumer<WalletCubit, WalletState>(
          listener: (context, state) {
            if (state is WalletError && state.transactions.isNotEmpty) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message ?? 'An error occurred'),
                  backgroundColor: AppTheme.errorColor,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: () {
                      context.read<WalletCubit>().refresh();
                    },
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is WalletInitial ||
                (state is WalletLoading && state.transactions.isEmpty)) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BalanceShimmer(),
                    _buildAssetsHeader(),
                    const TransactionListShimmer(),
                  ],
                ),
              );
            }

            if (state is WalletError && state.transactions.isEmpty) {
              return ErrorRetryWidget(
                message: state.message ?? 'An error occurred',
                onRetry: () {
                  context.read<WalletCubit>().getWalletOverview();
                },
              );
            }

            if (state.balance != null && state.transactions.isNotEmpty) {
              return RefreshIndicator(
                onRefresh: () => context.read<WalletCubit>().refresh(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BalanceCard(balance: state.balance!),
                    _buildAssetsHeader(),
                    Expanded(
                      child: TransactionList(
                        transactions: state.transactions,
                        meta: state.meta,
                        state: state,
                      ),
                    ),
                    Visibility(
                      visible: state is TransactionsLoading,
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildAssetsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Assets',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8C00),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 18, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Deposit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMockModeSheet(BuildContext context) {
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
            _buildModeOption(
              sheetContext,
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
            _buildModeOption(
              sheetContext,
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
            _buildModeOption(
              sheetContext,
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
            _buildModeOption(
              sheetContext,
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

  Widget _buildModeOption(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
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
