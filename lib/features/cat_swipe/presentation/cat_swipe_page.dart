import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../common/services/api/cat_api_client.dart';
import '../../../common/models/cat_image.dart';

class CatSwipePage extends StatefulWidget {
  const CatSwipePage({super.key});

  @override
  State<CatSwipePage> createState() => _CatSwipePageState();
}

class _CatSwipePageState extends State<CatSwipePage> {
  final _apiClient = CatApiClient();

  CatImage? _currentCat;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCat();
  }

  /// Загрузка котика
  Future<void> _loadCat() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final cat = await _apiClient.fetchRandomCat();
      setState(() => _currentCat = cat);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mewinder')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _error != null
                ? Text(
                    'Ошибка: $_error',
                    style: const TextStyle(color: Colors.red),
                  )
                : _currentCat == null
                    ? const Text('Нет данных 🐈')
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
  borderRadius: BorderRadius.circular(12), // чуть скруглим — эстетично
  child: SizedBox(
    width: 300,
    height: 300,
    child: CachedNetworkImage(
      imageUrl: _currentCat!.url,
      fit: BoxFit.cover, // заполняет квадрат полностью
      placeholder: (_, __) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (_, __, ___) => const Icon(Icons.error),
    ),
  ),
),

                          const SizedBox(height: 16),
                          Text(
                            _currentCat!.breeds.isNotEmpty
                                ? _currentCat!.breeds.first.name
                                : 'Неизвестная порода',
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _loadCat,
                            child: const Text('Следующий котик'),
                          ),
                        ],
                      ),
      ),
    );
  }
}
