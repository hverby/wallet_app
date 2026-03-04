import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;
  final dynamic response;

  const ServerFailure({
    required super.message,
    this.statusCode,
    this.response,
  });

  @override
  List<Object?> get props => [message, statusCode, response];
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}
