import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_app/features/wallet/domain/entities/transaction.dart';

void main() {
  group('Transaction Entity', () {
    final testDate = DateTime(2024, 3, 4, 10, 30);

    test('should create a valid Transaction instance', () {
      final transaction = Transaction(
        id: '1',
        alias: 'Ripple',
        ticker: 'XRP',
        date: testDate,
        amount: 3200.47,
        cryptoAmount: 413.444252,
        type: TransactionType.credit,
      );

      expect(transaction.id, '1');
      expect(transaction.alias, 'Ripple');
      expect(transaction.ticker, 'XRP');
      expect(transaction.date, testDate);
      expect(transaction.amount, 3200.47);
      expect(transaction.cryptoAmount, 413.444252);
      expect(transaction.type, TransactionType.credit);
    });

    test('should support equality comparison', () {
      final transaction1 = Transaction(
        id: '1',
        alias: 'Ripple',
        ticker: 'XRP',
        date: testDate,
        amount: 3200.47,
        cryptoAmount: 413.444252,
        type: TransactionType.credit,
      );

      final transaction2 = Transaction(
        id: '1',
        alias: 'Ripple',
        ticker: 'XRP',
        date: testDate,
        amount: 3200.47,
        cryptoAmount: 413.444252,
        type: TransactionType.credit,
      );

      final transaction3 = Transaction(
        id: '2',
        alias: 'Ethereum',
        ticker: 'ETH',
        date: testDate,
        amount: 7196.76,
        cryptoAmount: 0.243342,
        type: TransactionType.debit,
      );

      expect(transaction1, equals(transaction2));
      expect(transaction1, isNot(equals(transaction3)));
    });

    test('should include all properties in equality check', () {
      final transaction1 = Transaction(
        id: '1',
        alias: 'Ripple',
        ticker: 'XRP',
        date: testDate,
        amount: 3200.47,
        cryptoAmount: 413.444252,
        type: TransactionType.credit,
      );

      final transaction2 = Transaction(
        id: '1',
        alias: 'Ripple',
        ticker: 'XRP',
        date: testDate,
        amount: 3200.47,
        cryptoAmount: 413.444252,
        type: TransactionType.debit,
      );

      expect(transaction1, isNot(equals(transaction2)));
    });

    test('props should return correct list', () {
      final transaction = Transaction(
        id: '1',
        alias: 'Ripple',
        ticker: 'XRP',
        date: testDate,
        amount: 3200.47,
        cryptoAmount: 413.444252,
        type: TransactionType.credit,
      );

      expect(transaction.props, [
        '1',
        'Ripple',
        'XRP',
        testDate,
        3200.47,
        413.444252,
        TransactionType.credit,
      ]);
    });
  });

  group('TransactionType Enum', () {
    test('should have credit and debit values', () {
      expect(TransactionType.values, [
        TransactionType.credit,
        TransactionType.debit,
      ]);
    });
  });
}
