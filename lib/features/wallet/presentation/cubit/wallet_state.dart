part of 'wallet_cubit.dart';

abstract class WalletState extends Equatable {
  final Balance? balance;
  final List<Transaction> transactions;
  final Meta? meta;
  final String? message;

  const WalletState({
    this.balance,
    this.transactions = const [],
    this.meta,
    this.message,
  });

  @override
  List<Object?> get props => [balance, transactions, meta, message];
}

class WalletInitial extends WalletState {
  const WalletInitial() : super();
}

class WalletLoading extends WalletState {
  const WalletLoading({super.balance, required super.transactions, super.meta});
}

class TransactionsLoading extends WalletState {
  const TransactionsLoading({
    super.balance,
    required super.transactions,
    super.meta,
  });
}

class WalletLoaded extends WalletState {
  const WalletLoaded({
    required Balance super.balance,
    required super.transactions,
    required Meta super.meta,
  });
}

class WalletError extends WalletState {
  const WalletError({
    required String super.message,
    super.balance,
    required super.transactions,
    super.meta,
  });
}
