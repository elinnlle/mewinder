import '../../../../core/result.dart';

abstract class AuthRepository {
  Future<Result<void>> signUp(String email, String password);
  Future<Result<void>> login(String email, String password);
  Future<Result<void>> logout();
  Future<bool> isAuthorized();
  Future<String?> currentEmail();
}
