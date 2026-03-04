import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wallet_app/core/entities/meta.dart';
import 'package:wallet_app/core/error/failures.dart';
import 'package:wallet_app/core/usecases/usecase.dart';
import 'package:wallet_app/features/wallet/domain/entities/balance.dart';
import 'package:wallet_app/features/wallet/domain/entities/transaction.dart';
import 'package:wallet_app/features/wallet/domain/entities/wallet_overview.dart';
import 'package:wallet_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_app/features/wallet/domain/usecases/get_wallet_overview_usecase.dart';

class MockWalletRepository extends Mock implements WalletRepository {}

void main() {
  late GetWalletOverviewUseCase useCase;
  late MockWalletRepository mockRepository;

  setUp(() {
    mockRepository = MockWalletRepository();
    useCase = GetWalletOverviewUseCase(mockRepository);
  });

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
  final testWalletOverview = WalletOverview(
    balance: testBalance,
    transactions: testTransactions,
    meta: testMeta,
  );

  group('GetWalletOverviewUseCase', () {
    test('should get wallet overview from repository', () async {
      when(() => mockRepository.getWalletOverview())
          .thenAnswer((_) async => Right(testWalletOverview));

      final result = await useCase(const NoParams());

      expect(result, Right(testWalletOverview));
      verify(() => mockRepository.getWalletOverview()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      const testFailure = ServerFailure(message: 'Server error');
      when(() => mockRepository.getWalletOverview())
          .thenAnswer((_) async => const Left(testFailure));

      final result = await useCase(const NoParams());

      expect(result, const Left(testFailure));
      verify(() => mockRepository.getWalletOverview()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when no internet connection', () async {
      const testFailure = NetworkFailure(message: 'No internet connection');
      when(() => mockRepository.getWalletOverview())
          .thenAnswer((_) async => const Left(testFailure));

      final result = await useCase(const NoParams());

      expect(result, const Left(testFailure));
      verify(() => mockRepository.getWalletOverview()).called(1);
    });
  });
}
