import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/entities/meta.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/balance.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/get_wallet_overview_usecase.dart';

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final GetWalletOverviewUseCase getWalletOverviewUseCase;
  final GetTransactionsUseCase getTransactionsUseCase;

  WalletCubit({
    required this.getWalletOverviewUseCase,
    required this.getTransactionsUseCase,
  }) : super(const WalletInitial());

  Future<void> getWalletOverview() async {
    emit(
      WalletLoading(
        transactions: state.transactions,
        balance: state.balance,
        meta: state.meta,
      ),
    );

    final result = await getWalletOverviewUseCase(const NoParams());

    result.fold(
      (Failure failure) => emit(
        WalletError(
          message: failure.message,
          transactions: state.transactions,
          balance: state.balance,
          meta: state.meta,
        ),
      ),
      (overview) => emit(
        WalletLoaded(
          balance: overview.balance,
          transactions: overview.transactions,
          meta: overview.meta,
        ),
      ),
    );
  }

  Future<void> loadMoreTransactions() async {
    final currentMeta = state.meta;
    if (currentMeta != null && !currentMeta.hasNextPage) return;

    int page = 0;
    emit(
      TransactionsLoading(
        transactions: state.transactions,
        balance: state.balance,
        meta: state.meta,
      ),
    );

    if (currentMeta != null) {
      if (currentMeta.hasNextPage) {
        page = currentMeta.page + 1;
      } else {
        return;
      }
    } else {
      page = 2;
    }
    final result = await getTransactionsUseCase(
      GetTransactionsParams(page: page, take: 10),
    );

    result.fold(
      (Failure failure) => emit(
        WalletError(
          message: failure.message,
          transactions: state.transactions,
          balance: state.balance,
          meta: state.meta,
        ),
      ),
      (data) {
        final (newTransactions, newMeta) = data;
        final updatedTransactions = [...state.transactions, ...newTransactions];
        emit(
          WalletLoaded(
            balance: state.balance!,
            transactions: updatedTransactions,
            meta: newMeta,
          ),
        );
      },
    );
  }

  Future<void> refresh() async {
    emit(
      WalletLoading(
        transactions: state.transactions,
        balance: state.balance,
        meta: state.meta,
      ),
    );

    final result = await getWalletOverviewUseCase(const NoParams());

    result.fold(
      (Failure failure) => emit(
        WalletError(
          message: failure.message,
          transactions: state.transactions,
          balance: state.balance,
          meta: state.meta,
        ),
      ),
      (overview) => emit(
        WalletLoaded(
          balance: overview.balance,
          transactions: overview.transactions,
          meta: overview.meta,
        ),
      ),
    );
  }

  Future<void> reset() async {
    emit(const WalletInitial());
    await getWalletOverview();
  }
}
