import 'package:dartz/dartz.dart';
import '../../../../core/entities/meta.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/wallet_repository.dart';

class GetTransactionsParams {
  final int page;
  final int take;

  GetTransactionsParams({
    required this.page,
    required this.take,
  });
}

class GetTransactionsUseCase
    extends UseCase<(List<Transaction>, Meta), GetTransactionsParams> {
  final WalletRepository repository;

  GetTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, (List<Transaction>, Meta)>> call(
      GetTransactionsParams params) async {
    return await repository.getTransactions(
      page: params.page,
      take: params.take,
    );
  }
}
