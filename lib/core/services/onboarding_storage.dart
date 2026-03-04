import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingStorage {
  Future<bool> isCompleted();
  Future<void> setCompleted(bool value);
}

class OnboardingStorageImpl implements OnboardingStorage {
  static const _onboardingCompletedKey = 'onboarding_completed';

  final SharedPreferences _preferences;

  const OnboardingStorageImpl(this._preferences);

  @override
  Future<bool> isCompleted() async {
    return _preferences.getBool(_onboardingCompletedKey) ?? false;
  }

  @override
  Future<void> setCompleted(bool value) async {
    await _preferences.setBool(_onboardingCompletedKey, value);
  }
}
