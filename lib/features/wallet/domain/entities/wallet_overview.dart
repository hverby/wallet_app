import 'package:equatable/equatable.dart';
import '../../../../core/entities/meta.dart';
import 'balance.dart';
import 'transaction.dart';

class WalletOverview extends Equatable {
  final Balance balance;
  final List<Transaction> transactions;
  final Meta meta;

  const WalletOverview({
    required this.balance,
    required this.transactions,
    required this.meta,
  });

  @override
  List<Object?> get props => [balance, transactions, meta];
}
