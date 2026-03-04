import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

final class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

final class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
