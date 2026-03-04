import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wallet_overview.dart';
import '../repositories/wallet_repository.dart';

class GetWalletOverviewUseCase extends UseCase<WalletOverview, NoParams> {
  final WalletRepository repository;

  GetWalletOverviewUseCase(this.repository);

  @override
  Future<Either<Failure, WalletOverview>> call(NoParams params) async {
    return await repository.getWalletOverview();
  }
}
