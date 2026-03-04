import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_app/features/wallet/data/models/balance_model.dart';
import 'package:wallet_app/features/wallet/domain/entities/balance.dart';

void main() {
  const testBalanceModel = BalanceModel(amount: 25175.00, currency: '€');

  group('BalanceModel', () {
    test('should be a subclass of Balance entity', () {
      expect(testBalanceModel, isA<Balance>());
    });

    group('fromMap', () {
      test('should return a valid model from JSON map', () {
        final Map<String, dynamic> jsonMap = {
          'amount': 25175.00,
          'currency': '€',
        };

        final result = BalanceModel.fromMap(jsonMap);

        expect(result, testBalanceModel);
      });

      test('should handle integer amount', () {
        final Map<String, dynamic> jsonMap = {'amount': 25175, 'currency': '€'};

        final result = BalanceModel.fromMap(jsonMap);

        expect(result.amount, 25175.00);
      });
    });

    group('fromJson', () {
      test('should return a valid model from JSON string', () {
        final String jsonString = '{"amount":25175.00,"currency":"€"}';

        final result = BalanceModel.fromJson(jsonString);

        expect(result, testBalanceModel);
      });
    });

    group('toMap', () {
      test('should return a JSON map containing proper data', () {
        final result = testBalanceModel.toMap();

        final expectedMap = {'amount': 25175.00, 'currency': '€'};

        expect(result, expectedMap);
      });
    });

    group('toJson', () {
      test('should return a JSON string containing proper data', () {
        final result = testBalanceModel.toJson();

        final expectedJson = '{"amount":25175.0,"currency":"€"}';

        expect(result, expectedJson);
      });
    });
  });
}
