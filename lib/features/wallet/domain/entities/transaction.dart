import 'package:equatable/equatable.dart';

enum TransactionType { credit, debit }

class Transaction extends Equatable {
  final String id;
  final String alias;
  final String ticker;
  final DateTime date;
  final double amount;
  final double cryptoAmount;
  final TransactionType type;

  const Transaction({
    required this.id,
    required this.alias,
    required this.ticker,
    required this.date,
    required this.amount,
    required this.cryptoAmount,
    required this.type,
  });

  @override
  List<Object?> get props => [
    id,
    alias,
    ticker,
    date,
    amount,
    cryptoAmount,
    type,
  ];
}
