import '../entities/meta.dart';

class MetaModel extends Meta {
  const MetaModel({
    required super.page,
    required super.take,
    required super.totalCount,
    required super.hasNextPage,
  });

  factory MetaModel.fromMap(Map<String, dynamic> map) {
    return MetaModel(
      page: map['page'] as int,
      take: map['take'] as int,
      totalCount: map['totalCount'] as int,
      hasNextPage: map['hasNextPage'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'page': page,
      'take': take,
      'totalCount': totalCount,
      'hasNextPage': hasNextPage,
    };
  }
}
