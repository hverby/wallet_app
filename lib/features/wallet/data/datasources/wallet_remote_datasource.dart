import '../../../../core/error/exceptions.dart';
import '../../../../core/models/meta_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_overview_model.dart';

enum MockMode { success, failure, slow }

abstract class WalletRemoteDataSource {
  Future<WalletOverviewModel> getWalletOverview();
  Future<(List<TransactionModel>, MetaModel)> getTransactions({
    required int page,
    required int take,
  });
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final MockMode mode;

  WalletRemoteDataSourceImpl({this.mode = MockMode.success});

  @override
  Future<WalletOverviewModel> getWalletOverview() async {
    await _simulateDelay();

    if (mode == MockMode.failure) {
      throw ServerException(
        message: 'Failed to fetch wallet overview',
        statusCode: 500,
      );
    }

    final mockData = {
      'balance': {'amount': 25175.00, 'currency': '€'},
      'transactions': _generateMockTransactions(1, 10),
      'meta': {'page': 1, 'take': 10, 'totalCount': 47, 'hasNextPage': true},
    };

    return WalletOverviewModel.fromMap(mockData);
  }

  @override
  Future<(List<TransactionModel>, MetaModel)> getTransactions({
    required int page,
    required int take,
  }) async {
    await _simulateDelay();

    if (mode == MockMode.failure) {
      throw ServerException(
        message: 'Failed to fetch transactions',
        statusCode: 500,
      );
    }

    final totalCount = 47;
    final hasNextPage = (page * take) < totalCount;

    final transactions = _generateMockTransactions(
      page,
      take,
    ).map((t) => TransactionModel.fromMap(t)).toList();

    final meta = MetaModel(
      page: page,
      take: take,
      totalCount: totalCount,
      hasNextPage: hasNextPage,
    );

    return (transactions, meta);
  }

  Future<void> _simulateDelay() async {
    if (mode == MockMode.slow) {
      await Future.delayed(const Duration(seconds: 3));
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  List<Map<String, dynamic>> _generateMockTransactions(int page, int take) {
    final startIndex = (page - 1) * take;
    final mockTransactions = [
      {
        'id': '1',
        'alias': 'Ripple',
        'date': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        'amount': 3200.47,
        'type': 'credit',
      },
      {
        'id': '2',
        'alias': 'Ethereum',
        'date': DateTime.now()
            .subtract(const Duration(hours: 5))
            .toIso8601String(),
        'amount': 1500.00,
        'type': 'debit',
      },
      {
        'id': '3',
        'alias': 'Solana',
        'date': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        'amount': 3446.49,
        'type': 'credit',
      },
      {
        'id': '4',
        'alias': 'Dogecoin',
        'date': DateTime.now()
            .subtract(const Duration(days: 1, hours: 3))
            .toIso8601String(),
        'amount': 8624.00,
        'type': 'credit',
      },
      {
        'id': '5',
        'alias': 'Bitcoin',
        'date': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
        'amount': 2020.09,
        'type': 'debit',
      },
      {
        'id': '6',
        'alias': 'Cardano',
        'date': DateTime.now()
            .subtract(const Duration(days: 2, hours: 5))
            .toIso8601String(),
        'amount': 1250.00,
        'type': 'credit',
      },
      {
        'id': '7',
        'alias': 'Polkadot',
        'date': DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String(),
        'amount': 890.50,
        'type': 'debit',
      },
      {
        'id': '8',
        'alias': 'Chainlink',
        'date': DateTime.now()
            .subtract(const Duration(days: 3, hours: 8))
            .toIso8601String(),
        'amount': 2100.00,
        'type': 'credit',
      },
      {
        'id': '9',
        'alias': 'Litecoin',
        'date': DateTime.now()
            .subtract(const Duration(days: 4))
            .toIso8601String(),
        'amount': 750.25,
        'type': 'debit',
      },
      {
        'id': '10',
        'alias': 'Stellar',
        'date': DateTime.now()
            .subtract(const Duration(days: 4, hours: 6))
            .toIso8601String(),
        'amount': 1800.00,
        'type': 'credit',
      },
      {
        'id': '11',
        'alias': 'Uniswap',
        'date': DateTime.now()
            .subtract(const Duration(days: 5))
            .toIso8601String(),
        'amount': 950.75,
        'type': 'debit',
      },
      {
        'id': '12',
        'alias': 'Avalanche',
        'date': DateTime.now()
            .subtract(const Duration(days: 5, hours: 10))
            .toIso8601String(),
        'amount': 3200.00,
        'type': 'credit',
      },
      {
        'id': '13',
        'alias': 'Polygon',
        'date': DateTime.now()
            .subtract(const Duration(days: 6))
            .toIso8601String(),
        'amount': 1100.50,
        'type': 'debit',
      },
      {
        'id': '14',
        'alias': 'Cosmos',
        'date': DateTime.now()
            .subtract(const Duration(days: 6, hours: 4))
            .toIso8601String(),
        'amount': 2500.00,
        'type': 'credit',
      },
      {
        'id': '15',
        'alias': 'Algorand',
        'date': DateTime.now()
            .subtract(const Duration(days: 7))
            .toIso8601String(),
        'amount': 680.30,
        'type': 'debit',
      },
    ];

    final endIndex = (startIndex + take).clamp(0, mockTransactions.length);

    if (startIndex >= mockTransactions.length) {
      return [];
    }

    return mockTransactions.sublist(startIndex, endIndex);
  }
}
