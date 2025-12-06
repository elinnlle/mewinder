import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/cat_image.dart';
import '../../../secrets.dart';

class CatApiClient {
  static const _baseUrl = 'https://api.thecatapi.com/v1';

  String get _apiKey => catApiKey;

  /// Получение случайного изображения кота
  Future<CatImage> fetchRandomCat() async {
    final url = Uri.parse(
      '$_baseUrl/images/search?mime_types=jpg,png&has_breeds=1',
    );

    final response = await _get(url);
    final data = _parseList(response);

    return CatImage.fromJson(data.first);
  }

  /// Получение списка пород
  Future<List<CatBreed>> fetchBreeds() async {
    final url = _buildUrl('/breeds');

    final response = await _get(url);
    final data = _parseList(response);

    return data.map((json) => CatBreed.fromJson(json)).toList();
  }

  /// Формирование полного URL
  Uri _buildUrl(String path) => Uri.parse('$_baseUrl$path');

  /// Выполнение GET-запроса с API-ключом
  Future<http.Response> _get(Uri url) async {
    final response = await http.get(
      url,
      headers: {'x-api-key': _apiKey},
    );

    _ensureSuccess(response);
    return response;
  }

  /// Проверка HTTP-статуса
  void _ensureSuccess(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('Ошибка загрузки котика: ${response.statusCode}');
    }
  }

  /// Безопасный JSON-декод, ожидается список
  List<dynamic> _parseList(http.Response response) {
    final data = jsonDecode(response.body) as List<dynamic>;

    if (data.isEmpty) {
      throw Exception('API вернул пустой список');
    }

    return data;
  }
}
