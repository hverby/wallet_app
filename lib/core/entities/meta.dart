import 'package:equatable/equatable.dart';

class Meta extends Equatable {
  final int page;
  final int take;
  final int totalCount;
  final bool hasNextPage;

  const Meta({
    required this.page,
    required this.take,
    required this.totalCount,
    required this.hasNextPage,
  });

  @override
  List<Object?> get props => [page, take, totalCount, hasNextPage];
}
