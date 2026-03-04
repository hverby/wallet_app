import '../../../../core/models/meta_model.dart';
import '../../domain/entities/wallet_overview.dart';
import 'balance_model.dart';
import 'transaction_model.dart';

class WalletOverviewModel extends WalletOverview {
  const WalletOverviewModel({
    required super.balance,
    required super.transactions,
    required super.meta,
  });

  factory WalletOverviewModel.fromMap(Map<String, dynamic> map) {
    return WalletOverviewModel(
      balance: BalanceModel.fromMap(map['balance'] as Map<String, dynamic>),
      transactions: (map['transactions'] as List<dynamic>)
          .map((t) => TransactionModel.fromMap(t as Map<String, dynamic>))
          .toList(),
      meta: MetaModel.fromMap(map['meta'] as Map<String, dynamic>),
    );
  }
}
