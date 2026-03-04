import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/di.dart';
import 'core/services/onboarding_storage.dart';
import 'features/auth/presentation/pages/auth_gate.dart';
import 'features/auth/presentation/pages/account_page.dart';
import 'features/cats/presentation/pages/breeds_page.dart';
import 'features/cats/presentation/pages/cat_swipe_page.dart';
import 'features/onboarding/presentation/onboarding_page.dart';

class MewinderApp extends StatelessWidget {
  const MewinderApp({super.key});

  bool get _isMobile {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mewinder',
      theme: _buildTheme(),
      home: _AppEntryGate(authorizedChild: _buildMainFlow()),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(useMaterial3: true, colorSchemeSeed: Colors.orange);
  }

  Widget _buildMainFlow() =>
      _isMobile ? const _MobileTabs() : _buildDesktopTabs();

  Widget _buildDesktopTabs() {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: _buildDesktopAppBar(),
        body: _buildDesktopTabBody(),
      ),
    );
  }

  AppBar _buildDesktopAppBar() {
    return AppBar(
      toolbarHeight: 0,
      bottom: const TabBar(
        tabs: [
          Tab(icon: Icon(Icons.pets), text: 'Swipes'),
          Tab(icon: Icon(Icons.list), text: 'Breeds'),
          Tab(icon: Icon(Icons.person), text: 'Account'),
        ],
      ),
    );
  }

  Widget _buildDesktopTabBody() {
    return const TabBarView(
      children: [CatSwipePage(), BreedsPage(), AccountPage()],
    );
  }
}

class _AppEntryGate extends StatefulWidget {
  final Widget authorizedChild;

  const _AppEntryGate({required this.authorizedChild});

  @override
  State<_AppEntryGate> createState() => _AppEntryGateState();
}

class _AppEntryGateState extends State<_AppEntryGate> {
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

class _MobileTabs extends StatefulWidget {
  const _MobileTabs();

  @override
  State<_MobileTabs> createState() => _MobileTabsState();
}

class _MobileTabsState extends State<_MobileTabs> {
  int _index = 0;

  final _screens = const [CatSwipePage(), BreedsPage(), AccountPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: _onTabSelected,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.pets), label: 'Swipes'),
        NavigationDestination(icon: Icon(Icons.list), label: 'Breeds'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Account'),
      ],
    );
  }

  void _onTabSelected(int i) {
    setState(() => _index = i);
  }
}
