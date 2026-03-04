import 'package:flutter_test/flutter_test.dart';

import 'package:mewinder/core/services/secure_key_value_store.dart';
import 'package:mewinder/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:mewinder/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mewinder/features/auth/domain/usecases/get_auth_status.dart';
import 'package:mewinder/features/auth/domain/usecases/login.dart';
import 'package:mewinder/features/auth/domain/usecases/logout.dart';
import 'package:mewinder/features/auth/domain/usecases/sign_up.dart';

class _InMemorySecureStore implements SecureKeyValueStore {
  final Map<String, String> _data = <String, String>{};

  @override
  Future<String?> read({required String key}) async {
    return _data[key];
  }

  @override
  Future<void> write({required String key, required String value}) async {
    _data[key] = value;
  }

  String? getValue(String key) => _data[key];
}

void main() {
  late _InMemorySecureStore secureStore;
  late AuthRepositoryImpl repository;
  late SignUp signUp;
  late Login login;
  late Logout logout;
  late GetAuthStatus getAuthStatus;

  setUp(() {
    secureStore = _InMemorySecureStore();
    final localDataSource = AuthLocalDataSourceImpl(secureStore);
    repository = AuthRepositoryImpl(localDataSource);
    signUp = SignUp(repository);
    login = Login(repository);
    logout = Logout(repository);
    getAuthStatus = GetAuthStatus(repository);
  });

  test('signUp stores credentials and sets authorized=true', () async {
    final result = await signUp('user@example.com', 'passw0rd');
    final status = await getAuthStatus();

    expect(result.isSuccess, isTrue);
    expect(secureStore.getValue('auth_email'), 'user@example.com');
    expect(secureStore.getValue('auth_password'), 'passw0rd');
    expect(secureStore.getValue('auth_authorized'), 'true');
    expect(status.isSuccess, isTrue);
    expect(status.successOrNull?.value.isAuthorized, isTrue);
    expect(status.successOrNull?.value.email, 'user@example.com');
    expect(await repository.isAuthorized(), isTrue);
    expect(await repository.currentEmail(), 'user@example.com');
    expect(await repository.currentUsername(), 'user');
  });

  test('login with wrong password returns failure and does not authorize', () async {
    await signUp('user@example.com', 'passw0rd');
    await logout();

    final result = await login('user@example.com', 'wrong1');
    final status = await getAuthStatus();

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.failure.message, 'invalid_credentials');
    expect(status.isSuccess, isTrue);
    expect(status.successOrNull?.value.isAuthorized, isFalse);
    expect(secureStore.getValue('auth_authorized'), 'false');
  });

  test('signUp returns user_exists for duplicate email', () async {
    await signUp('user@example.com', 'passw0rd');

    final result = await signUp('user@example.com', 'passw0rd');

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.failure.message, 'user_exists');
  });

  test('login returns user_not_found when account does not exist', () async {
    final result = await login('user@example.com', 'passw0rd');

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.failure.message, 'user_not_found');
  });

  test('logout resets authorization state', () async {
    await signUp('user@example.com', 'passw0rd');

    final result = await logout();

    expect(result.isSuccess, isTrue);
    expect(await repository.isAuthorized(), isFalse);
  });
}
