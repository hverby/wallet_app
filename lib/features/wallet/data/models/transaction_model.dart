import 'dart:convert';
import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.alias,
    required super.ticker,
    required super.date,
    required super.amount,
    required super.cryptoAmount,
    required super.type,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      alias: map['alias'] as String,
      ticker: map['ticker'] as String,
      date: DateTime.parse(map['date'] as String),
      amount: (map['amount'] as num).toDouble(),
      cryptoAmount: (map['cryptoAmount'] as num).toDouble(),
      type: _parseTransactionType(map['type'] as String),
    );
  }

  factory TransactionModel.fromJson(String source) =>
      TransactionModel.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alias': alias,
      'ticker': ticker,
      'date': date.toIso8601String(),
      'amount': amount,
      'cryptoAmount': cryptoAmount,
      'type': type == TransactionType.credit ? 'credit' : 'debit',
    };
  }

  String toJson() => json.encode(toMap());

  static TransactionType _parseTransactionType(String type) {
    return type.toLowerCase() == 'credit'
        ? TransactionType.credit
        : TransactionType.debit;
  }
}
