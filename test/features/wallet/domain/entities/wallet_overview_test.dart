import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_app/core/entities/meta.dart';
import 'package:wallet_app/features/wallet/domain/entities/balance.dart';
import 'package:wallet_app/features/wallet/domain/entities/transaction.dart';
import 'package:wallet_app/features/wallet/domain/entities/wallet_overview.dart';

void main() {
  group('WalletOverview Entity', () {
    final testDate = DateTime(2024, 3, 4, 10, 30);
    const testBalance = Balance(amount: 25175.00, currency: '€');
    final testTransactions = [
      Transaction(
        id: '1',
        alias: 'Ripple',
        ticker: 'XRP',
        date: testDate,
        amount: 3200.47,
        cryptoAmount: 413.444252,
        type: TransactionType.credit,
      ),
    ];
    const testMeta = Meta(page: 1, take: 10, totalCount: 47, hasNextPage: true);

    test('should create a valid WalletOverview instance', () {
      final walletOverview = WalletOverview(
        balance: testBalance,
        transactions: testTransactions,
        meta: testMeta,
      );

      expect(walletOverview.balance, testBalance);
      expect(walletOverview.transactions, testTransactions);
      expect(walletOverview.meta, testMeta);
    });

    test('should support equality comparison', () {
      final walletOverview1 = WalletOverview(
        balance: testBalance,
        transactions: testTransactions,
        meta: testMeta,
      );

      final walletOverview2 = WalletOverview(
        balance: testBalance,
        transactions: testTransactions,
        meta: testMeta,
      );

      final walletOverview3 = WalletOverview(
        balance: const Balance(amount: 30000.00, currency: '€'),
        transactions: testTransactions,
        meta: testMeta,
      );

      expect(walletOverview1, equals(walletOverview2));
      expect(walletOverview1, isNot(equals(walletOverview3)));
    });

    test('props should return correct list', () {
      final walletOverview = WalletOverview(
        balance: testBalance,
        transactions: testTransactions,
        meta: testMeta,
      );

      expect(walletOverview.props, [testBalance, testTransactions, testMeta]);
    });
  });
}
