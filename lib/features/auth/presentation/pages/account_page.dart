import 'package:flutter/material.dart';

import '../../../../core/di.dart';
import '../../../../core/validators.dart';
import '../state/auth_controller.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late final AuthController _controller;

  final _usernameFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _newPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _showUsernameEditor = false;
  bool _showPasswordEditor = false;

  @override
  void initState() {
    super.initState();
    _controller = sl<AuthController>();
    _controller.addListener(_onChanged);
    _controller.initialize().then((_) {
      if (!mounted) return;
      _usernameController.text = _controller.currentUsername ?? '';
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;

    final currentName = _controller.currentUsername ?? '';
    if (_usernameController.text.isEmpty && currentName.isNotEmpty) {
      _usernameController.text = currentName;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _controller.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 16),
                  _buildUsernameSection(isLoading),
                  const SizedBox(height: 16),
                  _buildPasswordSection(isLoading),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : _confirmLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Log out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text('Email: ${_controller.currentEmail ?? '-'}'),
            const SizedBox(height: 6),
            Text('Username: ${_controller.currentUsername ?? '-'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameSection(bool isLoading) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() {
                              _showUsernameEditor = !_showUsernameEditor;
                            });
                          },
                    child: Text(_showUsernameEditor ? 'Cancel' : 'Edit'),
                  ),
                ],
              ),
              if (_showUsernameEditor) ...[
                const SizedBox(height: 12),
                Form(
                  key: _usernameFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _saveUsername(),
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          helperText: 'At least 2 characters',
                        ),
                        validator: (value) {
                          final normalized = value?.trim() ?? '';
                          if (normalized.isEmpty) {
                            return 'Username is required';
                          }
                          if (normalized.length < 2) {
                            return 'Username must contain at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _saveUsername,
                          child: const Text('Save username'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordSection(bool isLoading) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() {
                              _showPasswordEditor = !_showPasswordEditor;
                            });
                          },
                    child: Text(_showPasswordEditor ? 'Cancel' : 'Change'),
                  ),
                ],
              ),
              if (_showPasswordEditor) ...[
                const SizedBox(height: 12),
                Form(
                  key: _passwordFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrentPassword,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_newPasswordFocus);
                        },
                        decoration: InputDecoration(
                          labelText: 'Current password',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureCurrentPassword =
                                    !_obscureCurrentPassword;
                              });
                            },
                            icon: Icon(
                              _obscureCurrentPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            tooltip: _obscureCurrentPassword
                                ? 'Show password'
                                : 'Hide password',
                          ),
                        ),
                        validator: (value) {
                          if ((value ?? '').isEmpty) {
                            return 'Current password is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        focusNode: _newPasswordFocus,
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_confirmPasswordFocus);
                        },
                        decoration: InputDecoration(
                          labelText: 'New password',
                          helperText: 'At least 6 characters',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            tooltip: _obscureNewPassword
                                ? 'Show password'
                                : 'Hide password',
                          ),
                        ),
                        validator: (value) {
                          final result = Validators.validatePassword(
                            value,
                            minLength: 6,
                          );
                          return result.failureOrNull?.failure.message;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        focusNode: _confirmPasswordFocus,
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _changePassword(),
                        decoration: InputDecoration(
                          labelText: 'Confirm new password',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            tooltip: _obscureConfirmPassword
                                ? 'Show password'
                                : 'Hide password',
                          ),
                        ),
                        validator: (value) {
                          if ((value ?? '') != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _changePassword,
                          child: const Text('Update password'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveUsername() async {
    _controller.clearError();

    final form = _usernameFormKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final success = await _controller.updateUsername(_usernameController.text);
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    if (success) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Username updated successfully')),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(_controller.errorMessage ?? 'Unable to update username'),
      ),
    );
  }

  Future<void> _changePassword() async {
    _controller.clearError();

    final form = _passwordFormKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final success = await _controller.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    if (success) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      messenger.showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(_controller.errorMessage ?? 'Unable to update password'),
      ),
    );
  }

  Future<void> _logout() async {
    final success = await _controller.logout();
    if (!mounted || success) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage ?? 'Unable to log out'),
        ),
      );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text('Do you really want to log out of your account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;
    await _logout();
  }
}
