import 'failures.dart';
import 'result.dart';

final class Validators {
  const Validators._();

  static final RegExp _emailPattern = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  static Result<String> validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return const FailureResult<String>(
        ValidationFailure('Email is required'),
      );
    }
    if (!_emailPattern.hasMatch(email)) {
      return const FailureResult<String>(
        ValidationFailure('Email format is invalid'),
      );
    }
    return Success<String>(email);
  }

  static Result<String> validatePassword(String? value, {int minLength = 8}) {
    final password = value ?? '';
    if (password.isEmpty) {
      return const FailureResult<String>(
        ValidationFailure('Password is required'),
      );
    }
    if (password.length < minLength) {
      return FailureResult<String>(
        ValidationFailure('Password must be at least $minLength characters'),
      );
    }
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasDigit = RegExp(r'\d').hasMatch(password);
    if (!hasLetter || !hasDigit) {
      return const FailureResult<String>(
        ValidationFailure('Password must contain letters and numbers'),
      );
    }
    return Success<String>(password);
  }
}
