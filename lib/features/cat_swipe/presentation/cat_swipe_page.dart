import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/services/api/cat_api_client.dart';
import '../../../common/models/cat_image.dart';
import '../../../common/ui/error_dialog.dart';
import 'cat_details_page.dart';
import 'liked_cats_page.dart';

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

  List<CatImage> _likedCats = [];
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

      _likedCats = (_prefs.getStringList('likedCats') ?? [])
          .map(
            (e) => CatImage.fromJson(
              Map<String, dynamic>.from(jsonDecode(e)),
            ),
          )
          .toList();
    });
  }

  Future<void> _loadCat() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final cat = await _apiClient.fetchRandomCat();
      setState(() => _currentCat = cat);
    } catch (e) {
      await showErrorDialog(context, e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _currentCat == null
                ? _buildNoData()
                : _buildContent(),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: GestureDetector(
        onTap: () => _openLikedCats(context),
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: Text('❤️ $_likes', style: const TextStyle(fontSize: 18)),
          ),
        ),
      ),
      title: const Text('Mewinder'),
    );
  }

  Widget _buildNoData() {
    return const Text('No data 🐈');
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSwipeCard(),
        const SizedBox(height: 16),
        _buildBreedName(),
        const SizedBox(height: 20),
        _buildButtons(),
      ],
    );
  }

  Widget _buildSwipeCard() {
    return GestureDetector(
      onTap: _openCatDetails,
      onPanEnd: _handleSwipe,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 300,
          height: 300,
          child: CachedNetworkImage(
            imageUrl: _currentCat!.url,
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (_, __, ___) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  Widget _buildBreedName() {
    return Text(
      _currentCat!.breeds.isNotEmpty
          ? _currentCat!.breeds.first.name
          : 'Unknown breed',
      style: const TextStyle(fontSize: 20),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 48,
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: _dislike,
        ),
        const SizedBox(width: 40),
        IconButton(
          iconSize: 48,
          icon: const Icon(Icons.favorite, color: Colors.green),
          onPressed: _like,
        ),
      ],
    );
  }

  void _handleSwipe(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;

    if (velocity > 300) {
      _like();
    } else if (velocity < -300) {
      _dislike();
    }
  }

  void _like() {
    setState(() {
      _likes++;
      _prefs.setInt('likes', _likes);

      _likedCats.add(_currentCat!);
      _prefs.setStringList(
        'likedCats',
        _likedCats.map((c) => jsonEncode(c.toJson())).toList(),
      );
    });

    _loadCat();
  }

  void _dislike() {
    _loadCat();
  }

  void _openCatDetails() {
    final cat = _currentCat;
    if (cat == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CatDetailsPage(cat: cat),
      ),
    );
  }

  Future<void> _openLikedCats(BuildContext context) async {
    final updatedList = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LikedCatsPage(likedCats: _likedCats),
      ),
    );

    if (updatedList != null) {
      setState(() {
        _likedCats = updatedList;
        _likes = _likedCats.length;
        _prefs.setInt('likes', _likes);
        _prefs.setStringList(
          'likedCats',
          _likedCats.map((c) => jsonEncode(c.toJson())).toList(),
        );
      });
    }
  }
}
