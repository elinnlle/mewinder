import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mewinder/app.dart';
import 'package:mewinder/core/di.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
    await tester.pumpWidget(const MewinderApp());
    expect(find.byType(MewinderApp), findsOneWidget);
  });
}
