import '../../../../core/error/exceptions.dart';
import '../../../../core/models/meta_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_overview_model.dart';

enum MockMode { success, networkError, serverError, timeout }

abstract class WalletRemoteDataSource {
  Future<WalletOverviewModel> getWalletOverview();
  Future<(List<TransactionModel>, MetaModel)> getTransactions({
    required int page,
    required int take,
  });
  void setMode(MockMode newMode);
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  MockMode mode;

  WalletRemoteDataSourceImpl({this.mode = MockMode.success});

  @override
  void setMode(MockMode newMode) {
    mode = newMode;
  }

  @override
  Future<WalletOverviewModel> getWalletOverview() async {
    await _simulateDelay();
    _throwIfError('Failed to fetch wallet overview');

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
    _throwIfError('Failed to fetch transactions');

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

  void _throwIfError(String context) {
    switch (mode) {
      case MockMode.networkError:
        throw NetworkException(
          message: 'No internet connection. Please check your network.',
        );
      case MockMode.serverError:
        throw ServerException(
          message: '$context. Internal server error.',
          statusCode: 500,
        );
      case MockMode.timeout:
        throw NetworkException(message: 'Request timed out. Please try again.');
      case MockMode.success:
        break;
    }
  }

  Future<void> _simulateDelay() async {
    if (mode == MockMode.timeout) {
      await Future.delayed(const Duration(seconds: 5));
    } else {
      await Future.delayed(const Duration(milliseconds: 800));
    }
  }

  List<Map<String, dynamic>> _generateMockTransactions(int page, int take) {
    final startIndex = (page - 1) * take;
    final mockTransactions = [
      {
        'id': '1',
        'alias': 'Ripple',
        'ticker': 'XRP',
        'date': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        'amount': 3200.47,
        'cryptoAmount': 413.444252,
        'type': 'credit',
      },
      {
        'id': '2',
        'alias': 'Ethereum',
        'ticker': 'ETH',
        'date': DateTime.now()
            .subtract(const Duration(hours: 5))
            .toIso8601String(),
        'amount': 7196.76,
        'cryptoAmount': 0.243342,
        'type': 'credit',
      },
      {
        'id': '3',
        'alias': 'Solana',
        'ticker': 'SOL',
        'date': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        'amount': 3446.49,
        'cryptoAmount': 2.187698,
        'type': 'credit',
      },
      {
        'id': '4',
        'alias': 'Dogecoin',
        'ticker': 'DOGE',
        'date': DateTime.now()
            .subtract(const Duration(days: 1, hours: 3))
            .toIso8601String(),
        'amount': 8624.00,
        'cryptoAmount': 5000.0,
        'type': 'credit',
      },
      {
        'id': '5',
        'alias': 'Bitcoin',
        'ticker': 'BTC',
        'date': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
        'amount': 2020.09,
        'cryptoAmount': 0.021530,
        'type': 'debit',
      },
      {
        'id': '6',
        'alias': 'Cardano',
        'ticker': 'ADA',
        'date': DateTime.now()
            .subtract(const Duration(days: 2, hours: 5))
            .toIso8601String(),
        'amount': 1250.00,
        'cryptoAmount': 1562.50,
        'type': 'credit',
      },
      {
        'id': '7',
        'alias': 'Polkadot',
        'ticker': 'DOT',
        'date': DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String(),
        'amount': 890.50,
        'cryptoAmount': 127.214,
        'type': 'debit',
      },
      {
        'id': '8',
        'alias': 'Chainlink',
        'ticker': 'LINK',
        'date': DateTime.now()
            .subtract(const Duration(days: 3, hours: 8))
            .toIso8601String(),
        'amount': 2100.00,
        'cryptoAmount': 150.0,
        'type': 'credit',
      },
      {
        'id': '9',
        'alias': 'Litecoin',
        'ticker': 'LTC',
        'date': DateTime.now()
            .subtract(const Duration(days: 4))
            .toIso8601String(),
        'amount': 750.25,
        'cryptoAmount': 8.336,
        'type': 'debit',
      },
      {
        'id': '10',
        'alias': 'Stellar',
        'ticker': 'XLM',
        'date': DateTime.now()
            .subtract(const Duration(days: 4, hours: 6))
            .toIso8601String(),
        'amount': 1800.00,
        'cryptoAmount': 18000.0,
        'type': 'credit',
      },
      {
        'id': '11',
        'alias': 'Uniswap',
        'ticker': 'UNI',
        'date': DateTime.now()
            .subtract(const Duration(days: 5))
            .toIso8601String(),
        'amount': 950.75,
        'cryptoAmount': 95.075,
        'type': 'debit',
      },
      {
        'id': '12',
        'alias': 'Avalanche',
        'ticker': 'AVAX',
        'date': DateTime.now()
            .subtract(const Duration(days: 5, hours: 10))
            .toIso8601String(),
        'amount': 3200.00,
        'cryptoAmount': 91.428,
        'type': 'credit',
      },
      {
        'id': '13',
        'alias': 'Polygon',
        'ticker': 'MATIC',
        'date': DateTime.now()
            .subtract(const Duration(days: 6))
            .toIso8601String(),
        'amount': 1100.50,
        'cryptoAmount': 1375.625,
        'type': 'debit',
      },
      {
        'id': '14',
        'alias': 'Cosmos',
        'ticker': 'ATOM',
        'date': DateTime.now()
            .subtract(const Duration(days: 6, hours: 4))
            .toIso8601String(),
        'amount': 2500.00,
        'cryptoAmount': 250.0,
        'type': 'credit',
      },
      {
        'id': '15',
        'alias': 'Algorand',
        'ticker': 'ALGO',
        'date': DateTime.now()
            .subtract(const Duration(days: 7))
            .toIso8601String(),
        'amount': 680.30,
        'cryptoAmount': 3401.50,
        'type': 'debit',
      },
      {
        'id': '16',
        'alias': 'Ripple',
        'ticker': 'XRP',
        'date': DateTime.now()
            .subtract(const Duration(days: 8))
            .toIso8601String(),
        'amount': 2100.00,
        'cryptoAmount': 275.0,
        'type': 'credit',
      },
      {
        'id': '17',
        'alias': 'Ethereum',
        'ticker': 'ETH',
        'date': DateTime.now()
            .subtract(const Duration(days: 9))
            .toIso8601String(),
        'amount': 5500.00,
        'cryptoAmount': 0.186,
        'type': 'debit',
      },
      {
        'id': '18',
        'alias': 'Solana',
        'ticker': 'SOL',
        'date': DateTime.now()
            .subtract(const Duration(days: 10))
            .toIso8601String(),
        'amount': 2800.00,
        'cryptoAmount': 1.778,
        'type': 'credit',
      },
      {
        'id': '19',
        'alias': 'Bitcoin',
        'ticker': 'BTC',
        'date': DateTime.now()
            .subtract(const Duration(days: 11))
            .toIso8601String(),
        'amount': 15000.00,
        'cryptoAmount': 0.160,
        'type': 'credit',
      },
      {
        'id': '20',
        'alias': 'Cardano',
        'ticker': 'ADA',
        'date': DateTime.now()
            .subtract(const Duration(days: 12))
            .toIso8601String(),
        'amount': 890.00,
        'cryptoAmount': 1112.5,
        'type': 'debit',
      },
      {
        'id': '21',
        'alias': 'Polkadot',
        'ticker': 'DOT',
        'date': DateTime.now()
            .subtract(const Duration(days: 13))
            .toIso8601String(),
        'amount': 1200.00,
        'cryptoAmount': 171.43,
        'type': 'credit',
      },
      {
        'id': '22',
        'alias': 'Chainlink',
        'ticker': 'LINK',
        'date': DateTime.now()
            .subtract(const Duration(days: 14))
            .toIso8601String(),
        'amount': 1750.00,
        'cryptoAmount': 125.0,
        'type': 'debit',
      },
      {
        'id': '23',
        'alias': 'Litecoin',
        'ticker': 'LTC',
        'date': DateTime.now()
            .subtract(const Duration(days: 15))
            .toIso8601String(),
        'amount': 980.00,
        'cryptoAmount': 10.89,
        'type': 'credit',
      },
      {
        'id': '24',
        'alias': 'Stellar',
        'ticker': 'XLM',
        'date': DateTime.now()
            .subtract(const Duration(days: 16))
            .toIso8601String(),
        'amount': 1500.00,
        'cryptoAmount': 15000.0,
        'type': 'debit',
      },
      {
        'id': '25',
        'alias': 'Uniswap',
        'ticker': 'UNI',
        'date': DateTime.now()
            .subtract(const Duration(days: 17))
            .toIso8601String(),
        'amount': 1100.00,
        'cryptoAmount': 110.0,
        'type': 'credit',
      },
      {
        'id': '26',
        'alias': 'Avalanche',
        'ticker': 'AVAX',
        'date': DateTime.now()
            .subtract(const Duration(days: 18))
            .toIso8601String(),
        'amount': 2700.00,
        'cryptoAmount': 77.14,
        'type': 'debit',
      },
      {
        'id': '27',
        'alias': 'Polygon',
        'ticker': 'MATIC',
        'date': DateTime.now()
            .subtract(const Duration(days: 19))
            .toIso8601String(),
        'amount': 950.00,
        'cryptoAmount': 1187.5,
        'type': 'credit',
      },
      {
        'id': '28',
        'alias': 'Cosmos',
        'ticker': 'ATOM',
        'date': DateTime.now()
            .subtract(const Duration(days: 20))
            .toIso8601String(),
        'amount': 2200.00,
        'cryptoAmount': 220.0,
        'type': 'debit',
      },
      {
        'id': '29',
        'alias': 'Dogecoin',
        'ticker': 'DOGE',
        'date': DateTime.now()
            .subtract(const Duration(days: 21))
            .toIso8601String(),
        'amount': 7500.00,
        'cryptoAmount': 4347.83,
        'type': 'credit',
      },
      {
        'id': '30',
        'alias': 'Ripple',
        'ticker': 'XRP',
        'date': DateTime.now()
            .subtract(const Duration(days: 22))
            .toIso8601String(),
        'amount': 1800.00,
        'cryptoAmount': 235.71,
        'type': 'debit',
      },
      {
        'id': '31',
        'alias': 'Ethereum',
        'ticker': 'ETH',
        'date': DateTime.now()
            .subtract(const Duration(days: 23))
            .toIso8601String(),
        'amount': 6200.00,
        'cryptoAmount': 0.210,
        'type': 'credit',
      },
      {
        'id': '32',
        'alias': 'Solana',
        'ticker': 'SOL',
        'date': DateTime.now()
            .subtract(const Duration(days: 24))
            .toIso8601String(),
        'amount': 3100.00,
        'cryptoAmount': 1.968,
        'type': 'debit',
      },
      {
        'id': '33',
        'alias': 'Bitcoin',
        'ticker': 'BTC',
        'date': DateTime.now()
            .subtract(const Duration(days: 25))
            .toIso8601String(),
        'amount': 18500.00,
        'cryptoAmount': 0.197,
        'type': 'credit',
      },
      {
        'id': '34',
        'alias': 'Cardano',
        'ticker': 'ADA',
        'date': DateTime.now()
            .subtract(const Duration(days: 26))
            .toIso8601String(),
        'amount': 1050.00,
        'cryptoAmount': 1312.5,
        'type': 'debit',
      },
      {
        'id': '35',
        'alias': 'Polkadot',
        'ticker': 'DOT',
        'date': DateTime.now()
            .subtract(const Duration(days: 27))
            .toIso8601String(),
        'amount': 1400.00,
        'cryptoAmount': 200.0,
        'type': 'credit',
      },
      {
        'id': '36',
        'alias': 'Chainlink',
        'ticker': 'LINK',
        'date': DateTime.now()
            .subtract(const Duration(days: 28))
            .toIso8601String(),
        'amount': 1950.00,
        'cryptoAmount': 139.29,
        'type': 'debit',
      },
      {
        'id': '37',
        'alias': 'Litecoin',
        'ticker': 'LTC',
        'date': DateTime.now()
            .subtract(const Duration(days: 29))
            .toIso8601String(),
        'amount': 1100.00,
        'cryptoAmount': 12.22,
        'type': 'credit',
      },
      {
        'id': '38',
        'alias': 'Stellar',
        'ticker': 'XLM',
        'date': DateTime.now()
            .subtract(const Duration(days: 30))
            .toIso8601String(),
        'amount': 1700.00,
        'cryptoAmount': 17000.0,
        'type': 'debit',
      },
      {
        'id': '39',
        'alias': 'Uniswap',
        'ticker': 'UNI',
        'date': DateTime.now()
            .subtract(const Duration(days: 31))
            .toIso8601String(),
        'amount': 1250.00,
        'cryptoAmount': 125.0,
        'type': 'credit',
      },
      {
        'id': '40',
        'alias': 'Avalanche',
        'ticker': 'AVAX',
        'date': DateTime.now()
            .subtract(const Duration(days: 32))
            .toIso8601String(),
        'amount': 2900.00,
        'cryptoAmount': 82.86,
        'type': 'debit',
      },
      {
        'id': '41',
        'alias': 'Polygon',
        'ticker': 'MATIC',
        'date': DateTime.now()
            .subtract(const Duration(days: 33))
            .toIso8601String(),
        'amount': 1050.00,
        'cryptoAmount': 1312.5,
        'type': 'credit',
      },
      {
        'id': '42',
        'alias': 'Cosmos',
        'ticker': 'ATOM',
        'date': DateTime.now()
            .subtract(const Duration(days: 34))
            .toIso8601String(),
        'amount': 2400.00,
        'cryptoAmount': 240.0,
        'type': 'debit',
      },
      {
        'id': '43',
        'alias': 'Algorand',
        'ticker': 'ALGO',
        'date': DateTime.now()
            .subtract(const Duration(days: 35))
            .toIso8601String(),
        'amount': 750.00,
        'cryptoAmount': 3750.0,
        'type': 'credit',
      },
      {
        'id': '44',
        'alias': 'Dogecoin',
        'ticker': 'DOGE',
        'date': DateTime.now()
            .subtract(const Duration(days: 36))
            .toIso8601String(),
        'amount': 8000.00,
        'cryptoAmount': 4651.16,
        'type': 'debit',
      },
      {
        'id': '45',
        'alias': 'Ripple',
        'ticker': 'XRP',
        'date': DateTime.now()
            .subtract(const Duration(days: 37))
            .toIso8601String(),
        'amount': 2000.00,
        'cryptoAmount': 261.78,
        'type': 'credit',
      },
      {
        'id': '46',
        'alias': 'Ethereum',
        'ticker': 'ETH',
        'date': DateTime.now()
            .subtract(const Duration(days: 38))
            .toIso8601String(),
        'amount': 6800.00,
        'cryptoAmount': 0.230,
        'type': 'debit',
      },
      {
        'id': '47',
        'alias': 'Bitcoin',
        'ticker': 'BTC',
        'date': DateTime.now()
            .subtract(const Duration(days: 39))
            .toIso8601String(),
        'amount': 20000.00,
        'cryptoAmount': 0.213,
        'type': 'credit',
      },
    ];

    final endIndex = (startIndex + take).clamp(0, mockTransactions.length);

    if (startIndex >= mockTransactions.length) {
      return [];
    }

    return mockTransactions.sublist(startIndex, endIndex);
  }
}
