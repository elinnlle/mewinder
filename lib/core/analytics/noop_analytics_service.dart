import 'analytics.dart';

class NoopAnalyticsService implements Analytics {
  const NoopAnalyticsService();

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> params = const {},
  }) async {}
}
