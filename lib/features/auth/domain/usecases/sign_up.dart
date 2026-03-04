import '../../../../core/failures.dart';
import '../../../../core/result.dart';
import '../../../../core/validators.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  final AuthRepository _repository;

  const SignUp(this._repository);

  Future<Result<void>> call(String email, String password) async {
    final emailValidation = Validators.validateEmail(email);
    final passwordValidation = Validators.validatePassword(password);

    final emailFailure = emailValidation.failureOrNull;
    if (emailFailure != null) {
      return FailureResult<void>(emailFailure.failure);
    }

    final passwordFailure = passwordValidation.failureOrNull;
    if (passwordFailure != null) {
      return FailureResult<void>(passwordFailure.failure);
    }

    final normalizedEmail = emailValidation.successOrNull?.value;
    final validatedPassword = passwordValidation.successOrNull?.value;

    if (normalizedEmail == null || validatedPassword == null) {
      return const FailureResult<void>(
        ValidationFailure('Invalid input values'),
      );
    }

    return _repository.signUp(normalizedEmail, validatedPassword);
  }
}
