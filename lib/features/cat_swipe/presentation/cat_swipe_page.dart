import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/services/api/cat_api_client.dart';
import '../../../common/models/cat_image.dart';
import 'cat_details_page.dart';

class CatSwipePage extends StatefulWidget {
  const CatSwipePage({super.key});

  @override
  State<CatSwipePage> createState() => _CatSwipePageState();
}

class _CatSwipePageState extends State<CatSwipePage> {
  final _apiClient = CatApiClient();

  late SharedPreferences _prefs;

  CatImage? _currentCat;
  bool _loading = false;
  String? _error;

  int _likes = 0;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _loadCat();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _likes = _prefs.getInt('likes') ?? 0;
    });
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
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: Text('❤️ $_likes', style: const TextStyle(fontSize: 18)),
          ),
        ),
        title: const Text('Mewinder'),
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _error != null
                ? Text('Ошибка: $_error',
                    style: const TextStyle(color: Colors.red))
                : _currentCat == null
                    ? const Text('Нет данных 🐈')
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              final cat = _currentCat;
                              if (cat == null) return;

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CatDetailsPage(cat: cat),
                                ),
                              );
                            },
                            onPanEnd: (details) {
                              final velocity =
                                  details.velocity.pixelsPerSecond.dx;

                              // свайп вправо = лайк
                              if (velocity > 300) {
                                setState(() {
                                  _likes++;
                                  _prefs.setInt('likes', _likes);
                                });
                                _loadCat();
                              }
                              // свайп влево = дизлайк
                              else if (velocity < -300) {
                                _loadCat();
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 300,
                                height: 300,
                                child: CachedNetworkImage(
                                  imageUrl: _currentCat!.url,
                                  fit: BoxFit.cover, // заполняет квадрат полностью
                                  placeholder: (_, __) =>
                                      const Center(child: CircularProgressIndicator()),
                                  errorWidget: (_, __, ___) =>
                                      const Icon(Icons.error),
                                ),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Дизлайк
                              IconButton(
                                iconSize: 48,
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  _loadCat(); // просто загружаем нового
                                },
                              ),
                              const SizedBox(width: 40),
                              // Лайк
                              IconButton(
                                iconSize: 48,
                                icon: const Icon(Icons.favorite,
                                    color: Colors.green),
                                onPressed: () {
                                  setState(() {
                                    _likes++;
                                    _prefs.setInt('likes', _likes);
                                  });
                                  _loadCat();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
      ),
    );
  }
}
