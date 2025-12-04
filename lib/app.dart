import 'package:flutter/material.dart';
import 'features/cat_swipe/presentation/cat_swipe_page.dart';

class MewinderApp extends StatelessWidget {
  const MewinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mewinder',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.orange,
      ),
      home: const CatSwipePage(),
    );
  }
}
