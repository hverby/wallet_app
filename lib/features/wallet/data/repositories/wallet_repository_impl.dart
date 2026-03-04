import 'package:dartz/dartz.dart';
import '../../../../core/entities/meta.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/wallet_overview.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, WalletOverview>> getWalletOverview() async {
    try {
      final result = await remoteDataSource.getWalletOverview();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        response: e.response,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Unexpected error: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, (List<Transaction>, Meta)>> getTransactions({
    required int page,
    required int take,
  }) async {
    try {
      final result = await remoteDataSource.getTransactions(
        page: page,
        take: take,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        response: e.response,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Unexpected error: ${e.toString()}',
      ));
    }
  }
}
