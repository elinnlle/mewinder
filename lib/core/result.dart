import 'failures.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  Success<T>? get successOrNull =>
      this is Success<T> ? this as Success<T> : null;
  FailureResult<T>? get failureOrNull =>
      this is FailureResult<T> ? this as FailureResult<T> : null;

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    final current = this;
    if (current is Success<T>) {
      return onSuccess(current.value);
    }
    if (current is FailureResult<T>) {
      return onFailure(current.failure);
    }
    return onFailure(const UnknownFailure('Unexpected result state'));
  }
}

final class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);
}

final class FailureResult<T> extends Result<T> {
  final Failure failure;

  const FailureResult(this.failure);
}
