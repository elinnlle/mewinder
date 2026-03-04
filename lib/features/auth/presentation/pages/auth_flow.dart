import 'package:flutter/material.dart';

import '../state/auth_controller.dart';
import 'login_page.dart';
import 'sign_up_page.dart';

class AuthFlow extends StatefulWidget {
  final AuthController controller;

  const AuthFlow({super.key, required this.controller});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    if (_showLogin) {
      return LoginPage(
        controller: widget.controller,
        onOpenSignUp: () => setState(() => _showLogin = false),
      );
    }

    return SignUpPage(
      controller: widget.controller,
      onOpenLogin: () => setState(() => _showLogin = true),
    );
  }
}
