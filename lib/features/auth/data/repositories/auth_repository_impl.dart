import '../../../../core/failures.dart';
import '../../../../core/result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const _emailKey = 'auth_email';
  static const _passwordKey = 'auth_password';
  static const _usernameKey = 'auth_username';

  final AuthLocalDataSource _localDataSource;

  const AuthRepositoryImpl(this._localDataSource);

  @override
  Future<Result<void>> signUp(String email, String password) async {
    final credentialsResult = await _localDataSource.readCredentials();

    final existingFailure = credentialsResult.failureOrNull;
    if (existingFailure != null) {
      return FailureResult<void>(existingFailure.failure);
    }

    final credentials = credentialsResult.successOrNull?.value;
    if (credentials == null) {
      return const FailureResult<void>(
        UnknownFailure('unexpected_credentials_state'),
      );
    }

    final existingEmail = credentials[_emailKey];
    if (existingEmail != null &&
        existingEmail.isNotEmpty &&
        existingEmail == email) {
      return const FailureResult<void>(ValidationFailure('user_exists'));
    }

    final saveCredentialsResult = await _localDataSource.saveCredentials(
      email,
      password,
    );
    final saveFailure = saveCredentialsResult.failureOrNull;
    if (saveFailure != null) {
      return FailureResult<void>(saveFailure.failure);
    }

    final defaultUsername = email.split('@').first;
    final saveUsernameResult = await _localDataSource.saveUsername(
      defaultUsername,
    );
    final usernameFailure = saveUsernameResult.failureOrNull;
    if (usernameFailure != null) {
      return FailureResult<void>(usernameFailure.failure);
    }

    final setAuthorizedResult = await _localDataSource.setAuthorized(true);
    final authFailure = setAuthorizedResult.failureOrNull;
    if (authFailure != null) {
      return FailureResult<void>(authFailure.failure);
    }

    return const Success<void>(null);
  }

  @override
  Future<Result<void>> login(String email, String password) async {
    final credentialsResult = await _localDataSource.readCredentials();

    final credentialsFailure = credentialsResult.failureOrNull;
    if (credentialsFailure != null) {
      return FailureResult<void>(credentialsFailure.failure);
    }

    final credentials = credentialsResult.successOrNull?.value;
    if (credentials == null) {
      return const FailureResult<void>(
        UnknownFailure('unexpected_credentials_state'),
      );
    }

    final savedEmail = credentials[_emailKey];
    final savedPassword = credentials[_passwordKey];

    if (savedEmail == null || savedPassword == null) {
      return const FailureResult<void>(ValidationFailure('user_not_found'));
    }

    if (savedEmail != email || savedPassword != password) {
      return const FailureResult<void>(
        ValidationFailure('invalid_credentials'),
      );
    }

    final setAuthorizedResult = await _localDataSource.setAuthorized(true);
    final authFailure = setAuthorizedResult.failureOrNull;
    if (authFailure != null) {
      return FailureResult<void>(authFailure.failure);
    }

    return const Success<void>(null);
  }

  @override
  Future<Result<void>> logout() async {
    final result = await _localDataSource.clearAuthorization();
    final failure = result.failureOrNull;
    if (failure != null) {
      return FailureResult<void>(failure.failure);
    }

    return const Success<void>(null);
  }

  @override
  Future<Result<void>> updateUsername(String username) async {
    final credentialsResult = await _localDataSource.readCredentials();
    final credentialsFailure = credentialsResult.failureOrNull;
    if (credentialsFailure != null) {
      return FailureResult<void>(credentialsFailure.failure);
    }

    final credentials = credentialsResult.successOrNull?.value;
    final email = credentials?[_emailKey];
    if (email == null || email.isEmpty) {
      return const FailureResult<void>(ValidationFailure('user_not_found'));
    }

    final saveResult = await _localDataSource.saveUsername(username);
    final saveFailure = saveResult.failureOrNull;
    if (saveFailure != null) {
      return FailureResult<void>(saveFailure.failure);
    }

    return const Success<void>(null);
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final credentialsResult = await _localDataSource.readCredentials();
    final credentialsFailure = credentialsResult.failureOrNull;
    if (credentialsFailure != null) {
      return FailureResult<void>(credentialsFailure.failure);
    }

    final credentials = credentialsResult.successOrNull?.value;
    if (credentials == null) {
      return const FailureResult<void>(
        UnknownFailure('unexpected_credentials_state'),
      );
    }

    final savedPassword = credentials[_passwordKey];
    if (savedPassword == null) {
      return const FailureResult<void>(ValidationFailure('user_not_found'));
    }

    if (savedPassword != currentPassword) {
      return const FailureResult<void>(
        ValidationFailure('invalid_current_password'),
      );
    }

    final updateResult = await _localDataSource.updatePassword(newPassword);
    final updateFailure = updateResult.failureOrNull;
    if (updateFailure != null) {
      return FailureResult<void>(updateFailure.failure);
    }

    return const Success<void>(null);
  }

  @override
  Future<bool> isAuthorized() async {
    final result = await _localDataSource.isAuthorized();
    return result.successOrNull?.value ?? false;
  }

  @override
  Future<String?> currentEmail() async {
    final result = await _localDataSource.readCredentials();
    return result.successOrNull?.value[_emailKey];
  }

  @override
  Future<String?> currentUsername() async {
    final result = await _localDataSource.readCredentials();
    return result.successOrNull?.value[_usernameKey];
  }
}
