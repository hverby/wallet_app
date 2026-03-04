import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_app/features/wallet/presentation/cubit/wallet_cubit.dart';
import '../../../../core/entities/meta.dart';
import '../../domain/entities/transaction.dart';
import 'transaction_tile.dart';

class TransactionList extends StatefulWidget {
  final List<Transaction> transactions;
  final Meta? meta;
  final WalletState state;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.meta,
    required this.state,
  });

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
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
    var nextPageTrigger = 0.8 * _scrollController.position.maxScrollExtent;
    if (_scrollController.position.pixels > nextPageTrigger && _canLoadMore) {
      _canLoadMore = false;
      context.read<WalletCubit>().loadMoreTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state is WalletLoaded) {
      if (widget.state.meta != null && widget.state.meta!.hasNextPage) {
        _canLoadMore = true;
      }
    }
    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: widget.transactions.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, indent: 80),
      itemBuilder: (context, index) {
        return TransactionTile(transaction: widget.transactions[index]);
      },
    );
  }
}
