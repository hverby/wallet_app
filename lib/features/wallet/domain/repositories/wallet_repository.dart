import 'package:dartz/dartz.dart';
import '../../../../core/entities/meta.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../entities/wallet_overview.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletOverview>> getWalletOverview();
  
  Future<Either<Failure, (List<Transaction>, Meta)>> getTransactions({
    required int page,
    required int take,
  });
}
