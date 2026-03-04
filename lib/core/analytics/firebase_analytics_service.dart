import 'package:firebase_analytics/firebase_analytics.dart';

import 'analytics.dart';

class FirebaseAnalyticsService implements Analytics {
  final FirebaseAnalytics _analytics;

  const FirebaseAnalyticsService(this._analytics);

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> params = const {},
  }) async {
    final safeParams = <String, Object>{};
    params.forEach((key, value) {
      if (value != null) {
        safeParams[key] = value;
      }
    });

    await _analytics.logEvent(
      name: name,
      parameters: safeParams.isEmpty ? null : safeParams,
    );
  }
}
