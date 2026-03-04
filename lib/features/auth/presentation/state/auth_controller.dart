import 'package:flutter/foundation.dart';

import '../../../../core/failures.dart';
import '../../../../core/result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/get_auth_status.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/update_username.dart';

class AuthController extends ChangeNotifier {
  final SignUp _signUp;
  final Login _login;
  final Logout _logout;
  final GetAuthStatus _getAuthStatus;
  final UpdateUsername _updateUsername;
  final ChangePassword _changePassword;

  bool _isInitialized = false;
  bool _hasResolvedInitialStatus = false;
  bool _isLoading = false;
  bool _isAuthorized = false;
  String? _currentEmail;
  String? _currentUsername;
  String? _errorMessage;

  AuthController(
    this._signUp,
    this._login,
    this._logout,
    this._getAuthStatus,
    this._updateUsername,
    this._changePassword,
  );

  bool get isLoading => _isLoading;
  bool get hasResolvedInitialStatus => _hasResolvedInitialStatus;
  bool get isAuthorized => _isAuthorized;
  String? get currentEmail => _currentEmail;
  String? get currentUsername => _currentUsername;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;
    await refreshStatus();
    _hasResolvedInitialStatus = true;
    notifyListeners();
  }

  Future<void> refreshStatus() async {
    _setLoading(true);

    final result = await _getAuthStatus();
    result.fold(
      onSuccess: _applySession,
      onFailure: (failure) {
        _isAuthorized = false;
        _currentEmail = null;
        _currentUsername = null;
        _errorMessage = _mapFailure(failure);
      },
    );

    _setLoading(false);
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _login(email, password);
    final success = await _handleAuthMutationResult(result);

    _setLoading(false);
    return success;
  }

  Future<bool> signUp(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _signUp(email, password);
    final success = await _handleAuthMutationResult(result);

    _setLoading(false);
    return success;
  }

  Future<bool> logout() async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _logout();
    final failure = result.failureOrNull;

    if (failure != null) {
      _errorMessage = _mapFailure(failure.failure);
      _setLoading(false);
      return false;
    }

    _isAuthorized = false;
    _currentEmail = null;
    _currentUsername = null;
    _setLoading(false);
    return true;
  }

  Future<bool> updateUsername(String username) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _updateUsername(username);
    final success = await _handleAuthMutationResult(result);

    _setLoading(false);
    return success;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    final success = await _handleAuthMutationResult(result);
    _setLoading(false);
    return success;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _handleAuthMutationResult(Result<void> result) async {
    final failure = result.failureOrNull;
    if (failure != null) {
      _errorMessage = _mapFailure(failure.failure);
      return false;
    }

    final status = await _getAuthStatus();
    final statusFailure = status.failureOrNull;
    if (statusFailure != null) {
      _errorMessage = _mapFailure(statusFailure.failure);
      return false;
    }

    final session = status.successOrNull?.value;
    if (session == null) {
      _errorMessage = _mapFailure(
        const UnknownFailure('unexpected_auth_status_state'),
      );
      return false;
    }

    _applySession(session);
    return _isAuthorized;
  }

  void _applySession(AuthSession session) {
    _isAuthorized = session.isAuthorized;
    _currentEmail = session.email;
    _currentUsername = session.username;
    _errorMessage = null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _mapFailure(Failure failure) {
    switch (failure.message) {
      case 'user_exists':
        return 'An account with this email already exists';
      case 'user_not_found':
        return 'No account found for this email';
      case 'invalid_credentials':
        return 'Invalid email or password';
      case 'username_required':
        return 'Username is required';
      case 'username_too_short':
        return 'Username must contain at least 2 characters';
      case 'current_password_required':
        return 'Current password is required';
      case 'invalid_current_password':
        return 'Current password is incorrect';
      case 'password_same_as_old':
        return 'New password must differ from current password';
      case 'secure_storage_read_failed':
        return 'Unable to read secure storage';
      case 'secure_storage_write_failed':
        return 'Unable to write secure storage';
      default:
        return failure.message;
    }
  }
}
