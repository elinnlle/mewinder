import 'package:flutter/material.dart';

import '../../../../core/di.dart';
import '../state/auth_controller.dart';
import 'auth_flow.dart';

class AuthGate extends StatefulWidget {
  final Widget authorizedChild;

  const AuthGate({super.key, required this.authorizedChild});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = sl<AuthController>();
    _controller.addListener(_onChanged);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.hasResolvedInitialStatus) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_controller.isAuthorized) {
      return widget.authorizedChild;
    }

    return AuthFlow(controller: _controller);
  }
}
