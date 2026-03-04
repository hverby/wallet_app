import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../wallet/presentation/cubit/wallet_cubit.dart';
import '../../../wallet/presentation/widgets/balance_card.dart';
import '../../../wallet/presentation/widgets/balance_shimmer.dart';
import '../../../wallet/presentation/widgets/error_retry_widget.dart';
import '../../../wallet/presentation/widgets/transaction_list_shimmer.dart';
import '../../../wallet/presentation/widgets/transaction_tile.dart';
import '../../../wallet/presentation/widgets/upgrade_account_card.dart';
import '../widgets/make_payment_button_widget.dart';
import '../widgets/mock_mode_sheet.dart';
import '../widgets/payments_header_widget.dart';
import '../widgets/top_bar_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WalletCubit>()..getWalletOverview(),
      child: const Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: _HomeContent()),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final ScrollController _scrollController = ScrollController();
  bool _canLoadMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll == 0) return;
    final trigger = 0.8 * maxScroll;
    if (_scrollController.position.pixels > trigger && _canLoadMore) {
      _canLoadMore = false;
      context.read<WalletCubit>().loadMoreTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopBarWidget(onDebugTap: () => MockModeSheet.show(context)),
        Expanded(
          child: BlocConsumer<WalletCubit, WalletState>(
            listener: (context, state) {
              if (state is WalletLoaded) {
                if (state.meta != null && state.meta!.hasNextPage) {
                  _canLoadMore = true;
                }
              }
              if (state is WalletError && state.transactions.isNotEmpty) {
                _canLoadMore = true;
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
                    children: [
                      const BalanceShimmer(),
                      const SizedBox(height: 12),
                      const UpgradeAccountCard(),
                      const SizedBox(height: 24),
                      const PaymentsHeaderWidget(),
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
                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        color: AppTheme.accentColor,
                        onRefresh: () => context.read<WalletCubit>().refresh(),
                        child: CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  BalanceCard(balance: state.balance!),
                                  const UpgradeAccountCard(),
                                  const SizedBox(height: 24),
                                  const PaymentsHeaderWidget(),
                                ],
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                if (index < state.transactions.length) {
                                  return Column(
                                    children: [
                                      TransactionTile(
                                        transaction: state.transactions[index],
                                      ),
                                      if (index < state.transactions.length - 1)
                                        const Divider(
                                          height: 1,
                                          indent: 76,
                                          endIndent: 20,
                                        ),
                                    ],
                                  );
                                }
                                return null;
                              }, childCount: state.transactions.length),
                            ),
                            if (state is TransactionsLoading)
                              const SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppTheme.accentColor,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const MakePaymentButtonWidget(),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
