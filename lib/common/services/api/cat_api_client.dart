import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/cat_image.dart';
import '../../../secrets.dart';

class CatApiClient {
  static const _baseUrl = 'https://api.thecatapi.com/v1';

  String get _apiKey => catApiKey;

  // Получение случайного изображения кота
  Future<CatImage> fetchRandomCat() async {
    final url = Uri.parse(
      '$_baseUrl/images/search?mime_types=jpg,png&has_breeds=1',
    );

    final response = await http.get(
      url,
      headers: {
        'x-api-key': _apiKey,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка загрузки котика: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    if (data.isEmpty) {
      throw Exception('API вернул пустой список');
    }

    // ignore: avoid_print
    print('🐱 API response: ${response.body}');

    return CatImage.fromJson(data.first);
  }
}
