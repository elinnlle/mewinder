import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'features/cat_swipe/presentation/cat_swipe_page.dart';
import 'features/breeds/presentation/breeds_page.dart';

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
      home: _isMobile ? _buildMobileTabs() : _buildDesktopTabs(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(useMaterial3: true, colorSchemeSeed: Colors.orange);
  }

  Widget _buildMobileTabs() => const _MobileTabs();

  Widget _buildDesktopTabs() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _buildDesktopAppBar(),
        body: _buildDesktopTabBody(),
      ),
    );
  }

  AppBar _buildDesktopAppBar() {
    return AppBar(
      title: const Text('Mewinder'),
      bottom: const TabBar(
        tabs: [
          Tab(icon: Icon(Icons.pets), text: 'Swipes'),
          Tab(icon: Icon(Icons.list), text: 'Breeds'),
        ],
      ),
    );
  }

  Widget _buildDesktopTabBody() {
    return const TabBarView(children: [CatSwipePage(), BreedsPage()]);
  }
}

class _MobileTabs extends StatefulWidget {
  const _MobileTabs();

  @override
  State<_MobileTabs> createState() => _MobileTabsState();
}

class _MobileTabsState extends State<_MobileTabs> {
  int _index = 0;

  final _screens = const [CatSwipePage(), BreedsPage()];

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
      ],
    );
  }

  void _onTabSelected(int i) {
    setState(() => _index = i);
  }
}
