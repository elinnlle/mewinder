import '../../../../core/result.dart';

abstract class AuthRepository {
  Future<Result<void>> signUp(String email, String password);
  Future<Result<void>> login(String email, String password);
  Future<Result<void>> logout();
  Future<Result<void>> updateUsername(String username);
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<bool> isAuthorized();
  Future<String?> currentEmail();
  Future<String?> currentUsername();
}
