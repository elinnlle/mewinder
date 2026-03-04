import 'package:flutter_test/flutter_test.dart';

import 'package:mewinder/core/services/secure_key_value_store.dart';
import 'package:mewinder/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:mewinder/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mewinder/features/auth/domain/usecases/login.dart';
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
}

void main() {
  late _InMemorySecureStore secureStore;
  late AuthRepositoryImpl repository;
  late SignUp signUp;
  late Login login;

  setUp(() {
    secureStore = _InMemorySecureStore();
    final localDataSource = AuthLocalDataSourceImpl(secureStore);
    repository = AuthRepositoryImpl(localDataSource);
    signUp = SignUp(repository);
    login = Login(repository);
  });

  test('signUp stores user and sets authorized=true for valid data', () async {
    final result = await signUp('user@example.com', 'passw0rd');

    expect(result.isSuccess, isTrue);
    expect(await repository.isAuthorized(), isTrue);
    expect(await repository.currentEmail(), 'user@example.com');
    expect(await repository.currentUsername(), 'user');
  });

  test(
    'login returns invalid_credentials failure for wrong password',
    () async {
      await signUp('user@example.com', 'passw0rd');

      final result = await login('user@example.com', 'wrong1');

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.failure.message, 'invalid_credentials');
    },
  );
}
