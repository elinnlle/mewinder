abstract class Analytics {
  Future<void> logEvent(String name, {Map<String, Object?> params = const {}});
}
