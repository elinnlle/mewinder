import '../../../../../core/failures.dart';
import '../../../../../core/result.dart';
import '../../../../../core/services/secure_key_value_store.dart';

abstract class AuthLocalDataSource {
  Future<Result<void>> saveCredentials(String email, String password);
  Future<Result<Map<String, String?>>> readCredentials();
  Future<Result<void>> saveUsername(String username);
  Future<Result<void>> updatePassword(String password);
  Future<Result<void>> setAuthorized(bool value);
  Future<Result<bool>> isAuthorized();
  Future<Result<void>> clearAuthorization();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _emailKey = 'auth_email';
  static const _passwordKey = 'auth_password';
  static const _usernameKey = 'auth_username';
  static const _authorizedKey = 'auth_authorized';

  final SecureKeyValueStore _storage;

  const AuthLocalDataSourceImpl(this._storage);

  @override
  Future<Result<void>> saveCredentials(String email, String password) async {
    try {
      await _storage.write(key: _emailKey, value: email);
      await _storage.write(key: _passwordKey, value: password);
      return const Success<void>(null);
    } catch (_) {
      return const FailureResult<void>(
        StorageFailure('secure_storage_write_failed'),
      );
    }
  }

  @override
  Future<Result<Map<String, String?>>> readCredentials() async {
    try {
      final email = await _storage.read(key: _emailKey);
      final password = await _storage.read(key: _passwordKey);
      final username = await _storage.read(key: _usernameKey);
      return Success<Map<String, String?>>({
        _emailKey: email,
        _passwordKey: password,
        _usernameKey: username,
      });
    } catch (_) {
      return const FailureResult<Map<String, String?>>(
        StorageFailure('secure_storage_read_failed'),
      );
    }
  }

  @override
  Future<Result<void>> saveUsername(String username) async {
    try {
      await _storage.write(key: _usernameKey, value: username);
      return const Success<void>(null);
    } catch (_) {
      return const FailureResult<void>(
        StorageFailure('secure_storage_write_failed'),
      );
    }
  }

  @override
  Future<Result<void>> updatePassword(String password) async {
    try {
      await _storage.write(key: _passwordKey, value: password);
      return const Success<void>(null);
    } catch (_) {
      return const FailureResult<void>(
        StorageFailure('secure_storage_write_failed'),
      );
    }
  }

  @override
  Future<Result<void>> setAuthorized(bool value) async {
    try {
      await _storage.write(
        key: _authorizedKey,
        value: value ? 'true' : 'false',
      );
      return const Success<void>(null);
    } catch (_) {
      return const FailureResult<void>(
        StorageFailure('secure_storage_write_failed'),
      );
    }
  }

  @override
  Future<Result<bool>> isAuthorized() async {
    try {
      final raw = await _storage.read(key: _authorizedKey);
      return Success<bool>(raw == 'true');
    } catch (_) {
      return const FailureResult<bool>(
        StorageFailure('secure_storage_read_failed'),
      );
    }
  }

  @override
  Future<Result<void>> clearAuthorization() async {
    try {
      await _storage.write(key: _authorizedKey, value: 'false');
      return const Success<void>(null);
    } catch (_) {
      return const FailureResult<void>(
        StorageFailure('secure_storage_write_failed'),
      );
    }
  }
}
