import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wallet_app/core/entities/meta.dart';
import 'package:wallet_app/core/error/failures.dart';
import 'package:wallet_app/features/wallet/domain/entities/transaction.dart';
import 'package:wallet_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_app/features/wallet/domain/usecases/get_transactions_usecase.dart';

class MockWalletRepository extends Mock implements WalletRepository {}

void main() {
  late GetTransactionsUseCase useCase;
  late MockWalletRepository mockRepository;

  setUp(() {
    mockRepository = MockWalletRepository();
    useCase = GetTransactionsUseCase(mockRepository);
  });

  final testDate = DateTime(2024, 3, 4, 10, 30);
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
    Transaction(
      id: '2',
      alias: 'Ethereum',
      ticker: 'ETH',
      date: testDate,
      amount: 7196.76,
      cryptoAmount: 0.243342,
      type: TransactionType.debit,
    ),
  ];
  const testMeta = Meta(page: 2, take: 10, totalCount: 47, hasNextPage: true);

  group('GetTransactionsUseCase', () {
    final testParams = GetTransactionsParams(page: 2, take: 10);

    test('should get transactions from repository', () async {
      when(
        () => mockRepository.getTransactions(page: 2, take: 10),
      ).thenAnswer((_) async => Right((testTransactions, testMeta)));

      final result = await useCase(testParams);

      expect(result, Right((testTransactions, testMeta)));
      verify(() => mockRepository.getTransactions(page: 2, take: 10)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      const testFailure = ServerFailure(message: 'Server error');
      when(
        () => mockRepository.getTransactions(page: 2, take: 10),
      ).thenAnswer((_) async => const Left(testFailure));

      final result = await useCase(testParams);

      expect(result, const Left(testFailure));
      verify(() => mockRepository.getTransactions(page: 2, take: 10)).called(1);
    });

    test('should return NetworkFailure when no internet connection', () async {
      const testFailure = NetworkFailure(message: 'No internet connection');
      when(
        () => mockRepository.getTransactions(page: 2, take: 10),
      ).thenAnswer((_) async => const Left(testFailure));

      final result = await useCase(testParams);

      expect(result, const Left(testFailure));
      verify(() => mockRepository.getTransactions(page: 2, take: 10)).called(1);
    });

    test('should pass correct parameters to repository', () async {
      final params1 = GetTransactionsParams(page: 1, take: 5);
      final params2 = GetTransactionsParams(page: 3, take: 20);

      when(
        () => mockRepository.getTransactions(
          page: any(named: 'page'),
          take: any(named: 'take'),
        ),
      ).thenAnswer((_) async => Right((testTransactions, testMeta)));

      await useCase(params1);
      verify(() => mockRepository.getTransactions(page: 1, take: 5)).called(1);

      await useCase(params2);
      verify(() => mockRepository.getTransactions(page: 3, take: 20)).called(1);
    });
  });

  group('GetTransactionsParams', () {
    test('should create params with correct values', () {
      final params = GetTransactionsParams(page: 2, take: 10);

      expect(params.page, 2);
      expect(params.take, 10);
    });
  });
}
