import 'package:flutter_test/flutter_test.dart';
import 'package:mewinder/core/validators.dart';

void main() {
  group('Validators.validateEmail', () {
    test('returns failure for empty email', () {
      final result = Validators.validateEmail('');

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.failure.message, 'Email is required');
    });

    test('returns normalized email for valid input', () {
      final result = Validators.validateEmail('  user@example.com  ');

      expect(result.isSuccess, isTrue);
      expect(result.successOrNull?.value, 'user@example.com');
    });
  });

  group('Validators.validatePassword', () {
    test('returns failure for password without digits', () {
      final result = Validators.validatePassword('abcdef', minLength: 6);

      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull?.failure.message,
        'Password must contain letters and numbers',
      );
    });

    test('returns success for valid password', () {
      final result = Validators.validatePassword('abc123', minLength: 6);

      expect(result.isSuccess, isTrue);
      expect(result.successOrNull?.value, 'abc123');
    });
  });
}
