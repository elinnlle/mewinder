import '../../../../core/failures.dart';
import '../../../../core/result.dart';
import '../repositories/auth_repository.dart';

class UpdateUsername {
  final AuthRepository _repository;

  const UpdateUsername(this._repository);

  Future<Result<void>> call(String username) {
    final normalized = username.trim();
    if (normalized.isEmpty) {
      return Future.value(
        const FailureResult<void>(ValidationFailure('username_required')),
      );
    }

    if (normalized.length < 2) {
      return Future.value(
        const FailureResult<void>(ValidationFailure('username_too_short')),
      );
    }

    return _repository.updateUsername(normalized);
  }
}
