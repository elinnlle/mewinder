import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/failures.dart';
import '../../../core/result.dart';
import '../../../secrets.dart';

class CatApiClient {
  static const String _baseUrl = 'https://api.thecatapi.com/v1';

  String get _apiKey => catApiKey;

  /// Получение случайного изображения кота
  Future<Result<List<dynamic>>> fetchRandomCat() {
    final url = _buildUrl('/images/search?mime_types=jpg,png&has_breeds=1');
    return _fetchList(url);
  }

  /// Получение списка пород
  Future<Result<List<dynamic>>> fetchBreeds() {
    final url = _buildUrl('/breeds');
    return _fetchList(url);
  }

  /// Формирование полного URL
  Uri _buildUrl(String path) => Uri.parse('$_baseUrl$path');

  /// Выполнение GET-запроса с API-ключом и безопасный JSON-декод списка
  Future<Result<List<dynamic>>> _fetchList(Uri url) async {
    try {
      final response = await http.get(url, headers: {'x-api-key': _apiKey});

      // Проверка HTTP-статуса
      if (response.statusCode != 200) {
        return FailureResult<List<dynamic>>(
          NetworkFailure('Request failed with status: ${response.statusCode}'),
        );
      }

      // Безопасный JSON-декод, ожидается список
      final decoded = jsonDecode(response.body);
      if (decoded is! List<dynamic>) {
        return const FailureResult<List<dynamic>>(
          UnknownFailure('Unexpected response format: expected a list'),
        );
      }

      return Success<List<dynamic>>(decoded);
    } catch (_) {
      return const FailureResult<List<dynamic>>(
        NetworkFailure('Network request failed'),
      );
    }
  }
}
