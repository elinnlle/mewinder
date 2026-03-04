import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mewinder/core/analytics/noop_analytics_service.dart';
import 'package:mewinder/core/failures.dart';
import 'package:mewinder/core/result.dart';
import 'package:mewinder/features/auth/domain/repositories/auth_repository.dart';
import 'package:mewinder/features/auth/domain/usecases/get_auth_status.dart';
import 'package:mewinder/features/auth/domain/usecases/login.dart';
import 'package:mewinder/features/auth/domain/usecases/logout.dart';
import 'package:mewinder/features/auth/domain/usecases/sign_up.dart';
import 'package:mewinder/features/auth/domain/usecases/update_username.dart';
import 'package:mewinder/features/auth/domain/usecases/change_password.dart';
import 'package:mewinder/features/auth/presentation/pages/auth_gate.dart';
import 'package:mewinder/features/auth/presentation/state/auth_controller.dart';

class _FakeAuthRepository implements AuthRepository {
  bool _authorized;
  String? _email;
  String? _username;
  bool failLogin;

  _FakeAuthRepository({bool authorized = false, this.failLogin = false})
    : _authorized = authorized;

  @override
  Future<Result<void>> login(String email, String password) async {
    if (failLogin) {
      return const FailureResult<void>(
        ValidationFailure('invalid_credentials'),
      );
    }
    _authorized = true;
    _email = email;
    _username = email.split('@').first;
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> logout() async {
    _authorized = false;
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> signUp(String email, String password) async {
    _authorized = true;
    _email = email;
    _username = email.split('@').first;
    return const Success<void>(null);
  }

  @override
  Future<bool> isAuthorized() async => _authorized;

  @override
  Future<String?> currentEmail() async => _email;

  @override
  Future<String?> currentUsername() async => _username;

  @override
  Future<Result<void>> updateUsername(String username) async {
    _username = username;
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return const Success<void>(null);
  }
}

Widget _buildTestApp(AuthController controller) {
  return MaterialApp(
    home: AuthGate(
      controllerOverride: controller,
      authorizedChild: const Scaffold(body: Text('MAIN_FLOW')),
    ),
  );
}

AuthController _buildController(_FakeAuthRepository repository) {
  return AuthController(
    SignUp(repository),
    Login(repository),
    Logout(repository),
    GetAuthStatus(repository),
    UpdateUsername(repository),
    ChangePassword(repository),
    const NoopAnalyticsService(),
  );
}

void main() {
  testWidgets('shows validation errors for invalid login input', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    final controller = _buildController(repository);

    await tester.pumpWidget(_buildTestApp(controller));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Email format is invalid'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('MAIN_FLOW'), findsNothing);
  });

  testWidgets('successful login switches to main flow', (tester) async {
    final repository = _FakeAuthRepository();
    final controller = _buildController(repository);

    await tester.pumpWidget(_buildTestApp(controller));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'abc123');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('MAIN_FLOW'), findsOneWidget);
  });

  testWidgets('failed login shows error and keeps auth flow', (tester) async {
    final repository = _FakeAuthRepository(failLogin: true);
    final controller = _buildController(repository);

    await tester.pumpWidget(_buildTestApp(controller));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'abc123');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid email or password'), findsAtLeastNWidgets(1));
    expect(find.text('MAIN_FLOW'), findsNothing);
  });

  testWidgets('sign up shows mismatch error for confirm password', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    final controller = _buildController(repository);

    await tester.pumpWidget(_buildTestApp(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('No account? Sign up'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'abc123');
    await tester.enterText(find.byType(TextFormField).at(2), 'abc124');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match'), findsOneWidget);
    expect(find.text('MAIN_FLOW'), findsNothing);
  });
}
