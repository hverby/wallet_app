import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_app/core/error/exceptions.dart';
import 'package:wallet_app/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:wallet_app/features/wallet/data/models/wallet_overview_model.dart';

void main() {
  late WalletRemoteDataSourceImpl dataSource;

  setUp(() {
    dataSource = WalletRemoteDataSourceImpl(mode: MockMode.success);
  });

  group('WalletRemoteDataSource', () {
    group('getWalletOverview', () {
      test('should return WalletOverviewModel when mode is success', () async {
        dataSource.setMode(MockMode.success);

        final result = await dataSource.getWalletOverview();

        expect(result, isA<WalletOverviewModel>());
        expect(result.balance.amount, 25175.00);
        expect(result.balance.currency, '€');
        expect(result.transactions.length, 10);
        expect(result.meta.page, 1);
        expect(result.meta.take, 10);
        expect(result.meta.totalCount, 47);
        expect(result.meta.hasNextPage, true);
      });

      test('should throw NetworkException when mode is networkError', () async {
        dataSource.setMode(MockMode.networkError);

        expect(
          () => dataSource.getWalletOverview(),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should throw ServerException when mode is serverError', () async {
        dataSource.setMode(MockMode.serverError);

        expect(
          () => dataSource.getWalletOverview(),
          throwsA(isA<ServerException>()),
        );
      });

      test('should throw NetworkException when mode is timeout', () async {
        dataSource.setMode(MockMode.timeout);

        expect(
          () => dataSource.getWalletOverview(),
          throwsA(isA<NetworkException>()),
        );
      });

      test('NetworkException should contain proper message', () async {
        dataSource.setMode(MockMode.networkError);

        try {
          await dataSource.getWalletOverview();
          fail('Should have thrown NetworkException');
        } catch (e) {
          expect(e, isA<NetworkException>());
          final exception = e as NetworkException;
          expect(
            exception.message,
            'No internet connection. Please check your network.',
          );
        }
      });

      test('ServerException should contain proper message and status code',
          () async {
        dataSource.setMode(MockMode.serverError);

        try {
          await dataSource.getWalletOverview();
          fail('Should have thrown ServerException');
        } catch (e) {
          expect(e, isA<ServerException>());
          final exception = e as ServerException;
          expect(
            exception.message,
            'Failed to fetch wallet overview. Internal server error.',
          );
          expect(exception.statusCode, 500);
        }
      });
    });

    group('getTransactions', () {
      test('should return transactions for page 1', () async {
        dataSource.setMode(MockMode.success);

        final result = await dataSource.getTransactions(page: 1, take: 10);

        expect(result.$1.length, 10);
        expect(result.$2.page, 1);
        expect(result.$2.take, 10);
        expect(result.$2.totalCount, 47);
        expect(result.$2.hasNextPage, true);
      });

      test('should return transactions for page 2', () async {
        dataSource.setMode(MockMode.success);

        final result = await dataSource.getTransactions(page: 2, take: 10);

        expect(result.$1.length, 10);
        expect(result.$2.page, 2);
        expect(result.$2.hasNextPage, true);
      });

      test('should return correct hasNextPage for last page', () async {
        dataSource.setMode(MockMode.success);

        final result = await dataSource.getTransactions(page: 5, take: 10);

        expect(result.$1.length, 7);
        expect(result.$2.page, 5);
        expect(result.$2.hasNextPage, false);
      });

      test('should return empty list when page exceeds total', () async {
        dataSource.setMode(MockMode.success);

        final result = await dataSource.getTransactions(page: 10, take: 10);

        expect(result.$1, isEmpty);
      });

      test('should throw NetworkException when mode is networkError', () async {
        dataSource.setMode(MockMode.networkError);

        expect(
          () => dataSource.getTransactions(page: 1, take: 10),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should throw ServerException when mode is serverError', () async {
        dataSource.setMode(MockMode.serverError);

        expect(
          () => dataSource.getTransactions(page: 1, take: 10),
          throwsA(isA<ServerException>()),
        );
      });

      test('should have 47 total mock transactions', () async {
        dataSource.setMode(MockMode.success);

        final allTransactions = <dynamic>[];
        for (int page = 1; page <= 5; page++) {
          final result = await dataSource.getTransactions(page: page, take: 10);
          allTransactions.addAll(result.$1);
        }

        expect(allTransactions.length, 47);
      });

      test('should return transactions with ticker and cryptoAmount', () async {
        dataSource.setMode(MockMode.success);

        final result = await dataSource.getTransactions(page: 1, take: 1);

        expect(result.$1.first.ticker, isNotEmpty);
        expect(result.$1.first.cryptoAmount, greaterThan(0));
      });
    });

    group('setMode', () {
      test('should change mode correctly', () async {
        dataSource.setMode(MockMode.success);
        final successResult = await dataSource.getWalletOverview();
        expect(successResult, isA<WalletOverviewModel>());

        dataSource.setMode(MockMode.networkError);
        expect(
          () => dataSource.getWalletOverview(),
          throwsA(isA<NetworkException>()),
        );
      });
    });
  });
}
