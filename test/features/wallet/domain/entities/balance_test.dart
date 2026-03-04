import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_app/features/wallet/domain/entities/balance.dart';

void main() {
  group('Balance Entity', () {
    test('should create a valid Balance instance', () {
      const balance = Balance(amount: 25175.00, currency: '€');

      expect(balance.amount, 25175.00);
      expect(balance.currency, '€');
    });

    test('should support equality comparison', () {
      const balance1 = Balance(amount: 25175.00, currency: '€');
      const balance2 = Balance(amount: 25175.00, currency: '€');
      const balance3 = Balance(amount: 30000.00, currency: '€');

      expect(balance1, equals(balance2));
      expect(balance1, isNot(equals(balance3)));
    });

    test('should include all properties in equality check', () {
      const balance1 = Balance(amount: 25175.00, currency: '€');
      const balance2 = Balance(amount: 25175.00, currency: '\$');

      expect(balance1, isNot(equals(balance2)));
    });

    test('props should return correct list', () {
      const balance = Balance(amount: 25175.00, currency: '€');

      expect(balance.props, [25175.00, '€']);
    });
  });
}
