import 'package:get_it/get_it.dart';
import 'features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'features/wallet/data/repositories/wallet_repository_impl.dart';
import 'features/wallet/domain/repositories/wallet_repository.dart';
import 'features/wallet/domain/usecases/get_transactions_usecase.dart';
import 'features/wallet/domain/usecases/get_wallet_overview_usecase.dart';
import 'features/wallet/presentation/cubit/wallet_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Wallet Feature
  // Cubit
  sl.registerFactory(
    () => WalletCubit(
      getWalletOverviewUseCase: sl(),
      getTransactionsUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetWalletOverviewUseCase(sl()));
  sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(mode: MockMode.success),
  );
}
