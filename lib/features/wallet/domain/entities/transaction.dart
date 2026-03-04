import 'package:equatable/equatable.dart';

enum TransactionType { credit, debit }

class Transaction extends Equatable {
  final String id;
  final String alias;
  final DateTime date;
  final double amount;
  final TransactionType type;

  const Transaction({
    required this.id,
    required this.alias,
    required this.date,
    required this.amount,
    required this.type,
  });

  @override
  List<Object?> get props => [id, alias, date, amount, type];
}
