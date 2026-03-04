import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wallet_app/core/error/exceptions.dart';
import 'package:wallet_app/core/error/failures.dart';
import 'package:wallet_app/core/models/meta_model.dart';
import 'package:wallet_app/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:wallet_app/features/wallet/data/models/balance_model.dart';
import 'package:wallet_app/features/wallet/data/models/transaction_model.dart';
import 'package:wallet_app/features/wallet/data/models/wallet_overview_model.dart';
import 'package:wallet_app/features/wallet/domain/entities/transaction.dart';
import 'package:wallet_app/features/wallet/data/repositories/wallet_repository_impl.dart';

class MockWalletRemoteDataSource extends Mock
    implements WalletRemoteDataSource {}

void main() {
  late WalletRepositoryImpl repository;
  late MockWalletRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockWalletRemoteDataSource();
    repository = WalletRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  final testDate = DateTime(2024, 3, 4, 10, 30);
  const testBalanceModel = BalanceModel(amount: 25175.00, currency: '€');
  final testTransactionModels = [
    TransactionModel(
      id: '1',
      alias: 'Ripple',
      ticker: 'XRP',
      date: testDate,
      amount: 3200.47,
      cryptoAmount: 413.444252,
      type: TransactionType.credit,
    ),
  ];
  final testMetaModel = MetaModel(
    page: 1,
    take: 10,
    totalCount: 47,
    hasNextPage: true,
  );
  final testWalletOverviewModel = WalletOverviewModel(
    balance: testBalanceModel,
    transactions: testTransactionModels,
    meta: testMetaModel,
  );

  group('WalletRepositoryImpl', () {
    group('getWalletOverview', () {
      test(
        'should return WalletOverview when remote call is successful',
        () async {
          when(
            () => mockRemoteDataSource.getWalletOverview(),
          ).thenAnswer((_) async => testWalletOverviewModel);

          final result = await repository.getWalletOverview();

          expect(result, Right(testWalletOverviewModel));
          verify(() => mockRemoteDataSource.getWalletOverview()).called(1);
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should return NetworkFailure when NetworkException is thrown',
        () async {
          when(() => mockRemoteDataSource.getWalletOverview()).thenThrow(
            NetworkException(
              message: 'No internet connection. Please check your network.',
            ),
          );

          final result = await repository.getWalletOverview();

          expect(
            result,
            Left(
              NetworkFailure(
                message: 'No internet connection. Please check your network.',
              ),
            ),
          );
          verify(() => mockRemoteDataSource.getWalletOverview()).called(1);
        },
      );

      test(
        'should return ServerFailure when ServerException is thrown',
        () async {
          when(() => mockRemoteDataSource.getWalletOverview()).thenThrow(
            ServerException(message: 'Internal server error', statusCode: 500),
          );

          final result = await repository.getWalletOverview();

          expect(
            result,
            Left(
              ServerFailure(message: 'Internal server error', statusCode: 500),
            ),
          );
          verify(() => mockRemoteDataSource.getWalletOverview()).called(1);
        },
      );

      test(
        'should return ServerFailure when unexpected exception is thrown',
        () async {
          when(
            () => mockRemoteDataSource.getWalletOverview(),
          ).thenThrow(Exception('Unexpected error'));

          final result = await repository.getWalletOverview();

          expect(result.isLeft(), true);
          result.fold((failure) {
            expect(failure, isA<ServerFailure>());
            expect(
              (failure as ServerFailure).message,
              contains('Unexpected error'),
            );
          }, (_) => fail('Should return Left'));
        },
      );
    });

    group('getTransactions', () {
      test(
        'should return transactions when remote call is successful',
        () async {
          when(
            () => mockRemoteDataSource.getTransactions(page: 2, take: 10),
          ).thenAnswer((_) async => (testTransactionModels, testMetaModel));

          final result = await repository.getTransactions(page: 2, take: 10);

          expect(result, Right((testTransactionModels, testMetaModel)));
          verify(
            () => mockRemoteDataSource.getTransactions(page: 2, take: 10),
          ).called(1);
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should return NetworkFailure when NetworkException is thrown',
        () async {
          when(
            () => mockRemoteDataSource.getTransactions(page: 2, take: 10),
          ).thenThrow(
            NetworkException(message: 'Request timed out. Please try again.'),
          );

          final result = await repository.getTransactions(page: 2, take: 10);

          expect(
            result,
            Left(
              NetworkFailure(message: 'Request timed out. Please try again.'),
            ),
          );
        },
      );

      test(
        'should return ServerFailure when ServerException is thrown',
        () async {
          when(
            () => mockRemoteDataSource.getTransactions(page: 2, take: 10),
          ).thenThrow(
            ServerException(
              message: 'Failed to fetch transactions. Internal server error.',
              statusCode: 500,
            ),
          );

          final result = await repository.getTransactions(page: 2, take: 10);

          expect(
            result,
            Left(
              ServerFailure(
                message: 'Failed to fetch transactions. Internal server error.',
                statusCode: 500,
              ),
            ),
          );
        },
      );

      test('should pass correct parameters to remote data source', () async {
        when(
          () => mockRemoteDataSource.getTransactions(
            page: any(named: 'page'),
            take: any(named: 'take'),
          ),
        ).thenAnswer((_) async => (testTransactionModels, testMetaModel));

        await repository.getTransactions(page: 3, take: 20);

        verify(
          () => mockRemoteDataSource.getTransactions(page: 3, take: 20),
        ).called(1);
      });
    });
  });
}
