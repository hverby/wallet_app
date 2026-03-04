import 'dart:convert';
import '../../domain/entities/balance.dart';

class BalanceModel extends Balance {
  const BalanceModel({
    required super.amount,
    required super.currency,
  });

  factory BalanceModel.fromMap(Map<String, dynamic> map) {
    return BalanceModel(
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String,
    );
  }

  factory BalanceModel.fromJson(String source) =>
      BalanceModel.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'currency': currency,
    };
  }

  String toJson() => json.encode(toMap());
}
