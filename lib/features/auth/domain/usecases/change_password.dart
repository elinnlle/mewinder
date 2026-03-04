import '../../../../core/failures.dart';
import '../../../../core/result.dart';
import '../../../../core/validators.dart';
import '../repositories/auth_repository.dart';

class ChangePassword {
  final AuthRepository _repository;

  const ChangePassword(this._repository);

  Future<Result<void>> call({
    required String currentPassword,
    required String newPassword,
  }) {
    if (currentPassword.isEmpty) {
      return Future.value(
        const FailureResult<void>(
          ValidationFailure('current_password_required'),
        ),
      );
    }

    final validation = Validators.validatePassword(newPassword, minLength: 6);
    final failure = validation.failureOrNull;
    if (failure != null) {
      return Future.value(FailureResult<void>(failure.failure));
    }

    if (currentPassword == newPassword) {
      return Future.value(
        const FailureResult<void>(ValidationFailure('password_same_as_old')),
      );
    }

    final validatedPassword = validation.successOrNull?.value;
    if (validatedPassword == null) {
      return Future.value(
        const FailureResult<void>(ValidationFailure('invalid_password_value')),
      );
    }

    return _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: validatedPassword,
    );
  }
}
