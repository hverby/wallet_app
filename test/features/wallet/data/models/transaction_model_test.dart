import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_app/features/wallet/data/models/transaction_model.dart';
import 'package:wallet_app/features/wallet/domain/entities/transaction.dart';

void main() {
  final testDate = DateTime(2024, 3, 4, 10, 30);
  final testTransactionModel = TransactionModel(
    id: '1',
    alias: 'Ripple',
    ticker: 'XRP',
    date: testDate,
    amount: 3200.47,
    cryptoAmount: 413.444252,
    type: TransactionType.credit,
  );

  group('TransactionModel', () {
    test('should be a subclass of Transaction entity', () {
      expect(testTransactionModel, isA<Transaction>());
    });

    group('fromMap', () {
      test('should return a valid model from JSON map with credit type', () {
        final Map<String, dynamic> jsonMap = {
          'id': '1',
          'alias': 'Ripple',
          'ticker': 'XRP',
          'date': testDate.toIso8601String(),
          'amount': 3200.47,
          'cryptoAmount': 413.444252,
          'type': 'credit',
        };

        final result = TransactionModel.fromMap(jsonMap);

        expect(result, testTransactionModel);
      });

      test('should return a valid model from JSON map with debit type', () {
        final Map<String, dynamic> jsonMap = {
          'id': '2',
          'alias': 'Ethereum',
          'ticker': 'ETH',
          'date': testDate.toIso8601String(),
          'amount': 7196.76,
          'cryptoAmount': 0.243342,
          'type': 'debit',
        };

        final result = TransactionModel.fromMap(jsonMap);

        expect(result.type, TransactionType.debit);
      });

      test('should parse type case-insensitively', () {
        final Map<String, dynamic> jsonMap1 = {
          'id': '1',
          'alias': 'Ripple',
          'ticker': 'XRP',
          'date': testDate.toIso8601String(),
          'amount': 3200.47,
          'cryptoAmount': 413.444252,
          'type': 'CREDIT',
        };

        final Map<String, dynamic> jsonMap2 = {
          'id': '1',
          'alias': 'Ripple',
          'ticker': 'XRP',
          'date': testDate.toIso8601String(),
          'amount': 3200.47,
          'cryptoAmount': 413.444252,
          'type': 'Credit',
        };

        final result1 = TransactionModel.fromMap(jsonMap1);
        final result2 = TransactionModel.fromMap(jsonMap2);

        expect(result1.type, TransactionType.credit);
        expect(result2.type, TransactionType.credit);
      });

      test('should default to debit for unknown type', () {
        final Map<String, dynamic> jsonMap = {
          'id': '1',
          'alias': 'Ripple',
          'ticker': 'XRP',
          'date': testDate.toIso8601String(),
          'amount': 3200.47,
          'cryptoAmount': 413.444252,
          'type': 'unknown',
        };

        final result = TransactionModel.fromMap(jsonMap);

        expect(result.type, TransactionType.debit);
      });

      test('should handle integer amounts', () {
        final Map<String, dynamic> jsonMap = {
          'id': '1',
          'alias': 'Ripple',
          'ticker': 'XRP',
          'date': testDate.toIso8601String(),
          'amount': 3200,
          'cryptoAmount': 413,
          'type': 'credit',
        };

        final result = TransactionModel.fromMap(jsonMap);

        expect(result.amount, 3200.0);
        expect(result.cryptoAmount, 413.0);
      });
    });

    group('fromJson', () {
      test('should return a valid model from JSON string', () {
        final String jsonString =
            '{"id":"1","alias":"Ripple","ticker":"XRP","date":"${testDate.toIso8601String()}","amount":3200.47,"cryptoAmount":413.444252,"type":"credit"}';

        final result = TransactionModel.fromJson(jsonString);

        expect(result, testTransactionModel);
      });
    });

    group('toMap', () {
      test('should return a JSON map containing proper data for credit', () {
        final result = testTransactionModel.toMap();

        final expectedMap = {
          'id': '1',
          'alias': 'Ripple',
          'ticker': 'XRP',
          'date': testDate.toIso8601String(),
          'amount': 3200.47,
          'cryptoAmount': 413.444252,
          'type': 'credit',
        };

        expect(result, expectedMap);
      });

      test('should return a JSON map containing proper data for debit', () {
        final debitTransaction = TransactionModel(
          id: '2',
          alias: 'Ethereum',
          ticker: 'ETH',
          date: testDate,
          amount: 7196.76,
          cryptoAmount: 0.243342,
          type: TransactionType.debit,
        );

        final result = debitTransaction.toMap();

        expect(result['type'], 'debit');
      });
    });

    group('toJson', () {
      test('should return a JSON string containing proper data', () {
        final result = testTransactionModel.toJson();

        final expectedJson =
            '{"id":"1","alias":"Ripple","ticker":"XRP","date":"${testDate.toIso8601String()}","amount":3200.47,"cryptoAmount":413.444252,"type":"credit"}';

        expect(result, expectedJson);
      });
    });
  });
}
