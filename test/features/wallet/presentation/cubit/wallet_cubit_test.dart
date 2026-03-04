import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wallet_app/core/entities/meta.dart';
import 'package:wallet_app/core/error/failures.dart';
import 'package:wallet_app/core/usecases/usecase.dart';
import 'package:wallet_app/features/wallet/domain/entities/balance.dart';
import 'package:wallet_app/features/wallet/domain/entities/transaction.dart';
import 'package:wallet_app/features/wallet/domain/entities/wallet_overview.dart';
import 'package:wallet_app/features/wallet/domain/usecases/get_transactions_usecase.dart';
import 'package:wallet_app/features/wallet/domain/usecases/get_wallet_overview_usecase.dart';
import 'package:wallet_app/features/wallet/presentation/cubit/wallet_cubit.dart';

class MockGetWalletOverviewUseCase extends Mock
    implements GetWalletOverviewUseCase {}

class MockGetTransactionsUseCase extends Mock
    implements GetTransactionsUseCase {}

void main() {
  late WalletCubit cubit;
  late MockGetWalletOverviewUseCase mockGetWalletOverviewUseCase;
  late MockGetTransactionsUseCase mockGetTransactionsUseCase;

  setUp(() {
    mockGetWalletOverviewUseCase = MockGetWalletOverviewUseCase();
    mockGetTransactionsUseCase = MockGetTransactionsUseCase();
    cubit = WalletCubit(
      getWalletOverviewUseCase: mockGetWalletOverviewUseCase,
      getTransactionsUseCase: mockGetTransactionsUseCase,
    );
  });

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(GetTransactionsParams(page: 1, take: 10));
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
  const testMeta = Meta(page: 1, take: 10, totalCount: 47, hasNextPage: true);
  final testWalletOverview = WalletOverview(
    balance: testBalance,
    transactions: testTransactions,
    meta: testMeta,
  );

  group('WalletCubit', () {
    test('initial state should be WalletInitial', () {
      expect(cubit.state, const WalletInitial());
    });

    group('getWalletOverview', () {
      blocTest<WalletCubit, WalletState>(
        'emits [WalletLoading, WalletLoaded] when successful',
        build: () {
          when(() => mockGetWalletOverviewUseCase(any()))
              .thenAnswer((_) async => Right(testWalletOverview));
          return cubit;
        },
        act: (cubit) => cubit.getWalletOverview(),
        expect: () => [
          const WalletLoading(transactions: [], balance: null, meta: null),
          WalletLoaded(
            balance: testBalance,
            transactions: testTransactions,
            meta: testMeta,
          ),
        ],
        verify: (_) {
          verify(() => mockGetWalletOverviewUseCase(const NoParams())).called(1);
        },
      );

      blocTest<WalletCubit, WalletState>(
        'emits [WalletLoading, WalletError] when fails with NetworkFailure',
        build: () {
          when(() => mockGetWalletOverviewUseCase(any())).thenAnswer(
            (_) async => const Left(
              NetworkFailure(message: 'No internet connection'),
            ),
          );
          return cubit;
        },
        act: (cubit) => cubit.getWalletOverview(),
        expect: () => [
          const WalletLoading(transactions: [], balance: null, meta: null),
          const WalletError(
            message: 'No internet connection',
            transactions: [],
            balance: null,
            meta: null,
          ),
        ],
      );

      blocTest<WalletCubit, WalletState>(
        'emits [WalletLoading, WalletError] when fails with ServerFailure',
        build: () {
          when(() => mockGetWalletOverviewUseCase(any())).thenAnswer(
            (_) async => const Left(
              ServerFailure(message: 'Server error', statusCode: 500),
            ),
          );
          return cubit;
        },
        act: (cubit) => cubit.getWalletOverview(),
        expect: () => [
          const WalletLoading(transactions: [], balance: null, meta: null),
          const WalletError(
            message: 'Server error',
            transactions: [],
            balance: null,
            meta: null,
          ),
        ],
      );

      blocTest<WalletCubit, WalletState>(
        'maintains existing data in WalletLoading state',
        build: () {
          when(() => mockGetWalletOverviewUseCase(any()))
              .thenAnswer((_) async => Right(testWalletOverview));
          return cubit;
        },
        seed: () => WalletLoaded(
          balance: testBalance,
          transactions: testTransactions,
          meta: testMeta,
        ),
        act: (cubit) => cubit.getWalletOverview(),
        expect: () => [
          WalletLoading(
            transactions: testTransactions,
            balance: testBalance,
            meta: testMeta,
          ),
          WalletLoaded(
            balance: testBalance,
            transactions: testTransactions,
            meta: testMeta,
          ),
        ],
      );
    });

    group('loadMoreTransactions', () {
      final moreTransactions = [
        Transaction(
          id: '3',
          alias: 'Solana',
          ticker: 'SOL',
          date: testDate,
          amount: 3446.49,
          cryptoAmount: 2.187698,
          type: TransactionType.credit,
        ),
      ];
      const nextMeta = Meta(page: 2, take: 10, totalCount: 47, hasNextPage: true);

      blocTest<WalletCubit, WalletState>(
        'emits [TransactionsLoading, WalletLoaded] with appended transactions',
        build: () {
          when(() => mockGetTransactionsUseCase(any()))
              .thenAnswer((_) async => Right((moreTransactions, nextMeta)));
          return cubit;
        },
        seed: () => WalletLoaded(
          balance: testBalance,
          transactions: testTransactions,
          meta: testMeta,
        ),
        act: (cubit) => cubit.loadMoreTransactions(),
        expect: () => [
          TransactionsLoading(
            transactions: testTransactions,
            balance: testBalance,
            meta: testMeta,
          ),
          WalletLoaded(
            balance: testBalance,
            transactions: [...testTransactions, ...moreTransactions],
            meta: nextMeta,
          ),
        ],
        verify: (_) {
          verify(() => mockGetTransactionsUseCase(
                GetTransactionsParams(page: 2, take: 10),
              )).called(1);
        },
      );

      blocTest<WalletCubit, WalletState>(
        'does not load more when hasNextPage is false',
        build: () => cubit,
        seed: () => const WalletLoaded(
          balance: testBalance,
          transactions: [],
          meta: Meta(page: 5, take: 10, totalCount: 47, hasNextPage: false),
        ),
        act: (cubit) => cubit.loadMoreTransactions(),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockGetTransactionsUseCase(any()));
        },
      );

      blocTest<WalletCubit, WalletState>(
        'emits [TransactionsLoading, WalletError] when fails',
        build: () {
          when(() => mockGetTransactionsUseCase(any())).thenAnswer(
            (_) async => const Left(
              NetworkFailure(message: 'Failed to load more'),
            ),
          );
          return cubit;
        },
        seed: () => WalletLoaded(
          balance: testBalance,
          transactions: testTransactions,
          meta: testMeta,
        ),
        act: (cubit) => cubit.loadMoreTransactions(),
        expect: () => [
          TransactionsLoading(
            transactions: testTransactions,
            balance: testBalance,
            meta: testMeta,
          ),
          WalletError(
            message: 'Failed to load more',
            transactions: testTransactions,
            balance: testBalance,
            meta: testMeta,
          ),
        ],
      );

      blocTest<WalletCubit, WalletState>(
        'maintains existing transactions on error',
        build: () {
          when(() => mockGetTransactionsUseCase(any())).thenAnswer(
            (_) async => const Left(
              ServerFailure(message: 'Server error'),
            ),
          );
          return cubit;
        },
        seed: () => WalletLoaded(
          balance: testBalance,
          transactions: testTransactions,
          meta: testMeta,
        ),
        act: (cubit) => cubit.loadMoreTransactions(),
        expect: () => [
          TransactionsLoading(
            transactions: testTransactions,
            balance: testBalance,
            meta: testMeta,
          ),
          WalletError(
            message: 'Server error',
            transactions: testTransactions,
            balance: testBalance,
            meta: testMeta,
          ),
        ],
      );
    });

    group('refresh', () {
      blocTest<WalletCubit, WalletState>(
        'emits [WalletLoading, WalletLoaded] when successful',
        build: () {
          when(() => mockGetWalletOverviewUseCase(any()))
              .thenAnswer((_) async => Right(testWalletOverview));
          return cubit;
        },
        seed: () => WalletLoaded(
          balance: testBalance,
          transactions: testTransactions,
          meta: testMeta,
        ),
        act: (cubit) => cubit.refresh(),
        expect: () => [
          WalletLoading(
            transactions: testTransactions,
            balance: testBalance,
            meta: testMeta,
          ),
          WalletLoaded(
            balance: testBalance,
            transactions: testTransactions,
            meta: testMeta,
          ),
        ],
      );

      blocTest<WalletCubit, WalletState>(
        'maintains existing data during refresh',
        build: () {
          when(() => mockGetWalletOverviewUseCase(any()))
              .thenAnswer((_) async => Right(testWalletOverview));
          return cubit;
        },
        seed: () => WalletLoaded(
          balance: testBalance,
          transactions: testTransactions,
          meta: testMeta,
        ),
        act: (cubit) => cubit.refresh(),
        expect: () => [
          WalletLoading(
            transactions: testTransactions,
            balance: testBalance,
            meta: testMeta,
          ),
          WalletLoaded(
            balance: testBalance,
            transactions: testTransactions,
            meta: testMeta,
          ),
        ],
      );

      blocTest<WalletCubit, WalletState>(
        'emits [WalletLoading, WalletError] when fails',
        build: () {
          when(() => mockGetWalletOverviewUseCase(any())).thenAnswer(
            (_) async => const Left(
              NetworkFailure(message: 'Refresh failed'),
            ),
          );
          return cubit;
        },
        seed: () => WalletLoaded(
          balance: testBalance,
          transactions: testTransactions,
          meta: testMeta,
        ),
        act: (cubit) => cubit.refresh(),
        expect: () => [
          WalletLoading(
            transactions: testTransactions,
            balance: testBalance,
            meta: testMeta,
          ),
          WalletError(
            message: 'Refresh failed',
            transactions: testTransactions,
            balance: testBalance,
            meta: testMeta,
          ),
        ],
      );
    });

    group('reset', () {
      blocTest<WalletCubit, WalletState>(
        'emits [WalletInitial, WalletLoading, WalletLoaded] when successful',
        build: () {
          when(() => mockGetWalletOverviewUseCase(any()))
              .thenAnswer((_) async => Right(testWalletOverview));
          return cubit;
        },
        seed: () => WalletLoaded(
          balance: testBalance,
          transactions: testTransactions,
          meta: testMeta,
        ),
        act: (cubit) => cubit.reset(),
        expect: () => [
          const WalletInitial(),
          const WalletLoading(transactions: [], balance: null, meta: null),
          WalletLoaded(
            balance: testBalance,
            transactions: testTransactions,
            meta: testMeta,
          ),
        ],
      );

      blocTest<WalletCubit, WalletState>(
        'clears all existing data before reloading',
        build: () {
          when(() => mockGetWalletOverviewUseCase(any()))
              .thenAnswer((_) async => Right(testWalletOverview));
          return cubit;
        },
        seed: () => WalletLoaded(
          balance: testBalance,
          transactions: testTransactions,
          meta: testMeta,
        ),
        act: (cubit) => cubit.reset(),
        expect: () => [
          const WalletInitial(),
          const WalletLoading(transactions: [], balance: null, meta: null),
          WalletLoaded(
            balance: testBalance,
            transactions: testTransactions,
            meta: testMeta,
          ),
        ],
        verify: (_) {
          verify(() => mockGetWalletOverviewUseCase(const NoParams())).called(1);
        },
      );

      blocTest<WalletCubit, WalletState>(
        'emits [WalletInitial, WalletLoading, WalletError] when fails',
        build: () {
          when(() => mockGetWalletOverviewUseCase(any())).thenAnswer(
            (_) async => const Left(
              NetworkFailure(message: 'Reset failed'),
            ),
          );
          return cubit;
        },
        seed: () => WalletLoaded(
          balance: testBalance,
          transactions: testTransactions,
          meta: testMeta,
        ),
        act: (cubit) => cubit.reset(),
        expect: () => [
          const WalletInitial(),
          const WalletLoading(transactions: [], balance: null, meta: null),
          const WalletError(
            message: 'Reset failed',
            transactions: [],
            balance: null,
            meta: null,
          ),
        ],
      );
    });
  });
}
