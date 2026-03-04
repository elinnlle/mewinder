import '../../../../core/result.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class GetAuthStatus {
  final AuthRepository _repository;

  const GetAuthStatus(this._repository);

  Future<Result<AuthSession>> call() async {
    final authorized = await _repository.isAuthorized();
    final email = await _repository.currentEmail();
    return Success<AuthSession>(
      AuthSession(email: email, isAuthorized: authorized),
    );
  }
}
