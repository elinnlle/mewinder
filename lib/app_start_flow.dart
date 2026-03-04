import 'package:flutter/material.dart';

import 'core/di.dart';
import 'core/services/onboarding_storage.dart';
import 'features/auth/presentation/pages/auth_gate.dart';
import 'features/onboarding/presentation/onboarding_page.dart';

class AppStartFlow extends StatefulWidget {
  final Widget authorizedChild;

  const AppStartFlow({super.key, required this.authorizedChild});

  @override
  State<AppStartFlow> createState() => _AppStartFlowState();
}

class _AppStartFlowState extends State<AppStartFlow> {
  final OnboardingStorage _onboardingStorage = sl<OnboardingStorage>();
  bool? _isOnboardingCompleted;

  @override
  void initState() {
    super.initState();
    _loadOnboardingStatus();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = _isOnboardingCompleted;
    if (isCompleted == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!isCompleted) {
      return OnboardingPage(onCompleted: _completeOnboarding);
    }

    return AuthGate(authorizedChild: widget.authorizedChild);
  }

  Future<void> _loadOnboardingStatus() async {
    final completed = await _onboardingStorage.isCompleted();
    if (!mounted) return;

    setState(() {
      _isOnboardingCompleted = completed;
    });
  }

  Future<void> _completeOnboarding() async {
    await _onboardingStorage.setCompleted(true);
    if (!mounted) return;

    setState(() {
      _isOnboardingCompleted = true;
    });
  }
}
