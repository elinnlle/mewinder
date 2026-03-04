import '../../../../core/result.dart';
import '../repositories/auth_repository.dart';

class Logout {
  final AuthRepository _repository;

  const Logout(this._repository);

  Future<Result<void>> call() => _repository.logout();
}
