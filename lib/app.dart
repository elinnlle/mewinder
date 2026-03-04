import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_start_flow.dart';
import 'features/auth/presentation/pages/account_page.dart';
import 'features/cats/presentation/pages/breeds_page.dart';
import 'features/cats/presentation/pages/cat_swipe_page.dart';

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
      home: AppStartFlow(authorizedChild: _buildMainFlow()),
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
        body: const TabBarView(
          children: [CatSwipePage(), BreedsPage(), AccountPage()],
        ),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.pets), label: 'Swipes'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Breeds'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }

  void _onTabSelected(int i) {
    setState(() => _index = i);
  }
}
