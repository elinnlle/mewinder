import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/services/api/cat_api_client.dart';
import '../../../common/models/cat_image.dart';
import '../../../common/ui/error_dialog.dart';
import '../../../common/ui/animated_background.dart';
import '../../../common/ui/like_burst.dart';

import 'cat_details_page.dart';
import 'liked_cats_page.dart';

class CatSwipePage extends StatefulWidget {
  const CatSwipePage({super.key});

  @override
  State<CatSwipePage> createState() => _CatSwipePageState();
}

class _CatSwipePageState extends State<CatSwipePage>
    with SingleTickerProviderStateMixin {
  final _apiClient = CatApiClient();

  late SharedPreferences _prefs;

  CatImage? _currentCat;
  CatImage? _nextCat;

  bool _loading = false;

  List<CatImage> _likedCats = [];
  int _likes = 0;

  late AnimationController _swipeController;
  late Animation<double> _swipeAnimation;

  double _swipeOffset = 0;
  double _swipeAngle = 0;
  bool _isAnimating = false;
  bool _showLikeBurst = false;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _loadCat();

    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _swipeAnimation = CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOutCubic,
    );

    _swipeController.addListener(() {
      setState(() {
        _swipeOffset = _swipeAnimation.value;
      });
    });

    _swipeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _swipeController.reset();
        _swipeOffset = 0;
        _swipeAngle = 0;
        _isAnimating = false;
      }
    });
  }

  void _triggerLikeBurst() {
    setState(() => _showLikeBurst = true);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showLikeBurst = false);
    });
  }
  
  // Плавная анимация ухода карточки
  Future<void> _animateSwipe({required bool toRight}) async {
    if (_isAnimating) return;
    _isAnimating = true;

    _swipeAngle = toRight ? 0.35 : -0.35;

    if (toRight) {
      _triggerLikeBurst();
    }

    _swipeController.forward().then((_) {
      toRight ? _like() : _dislike();
    });
  }

  // Обработка свайпа
  void _handleSwipe(DragEndDetails details) {
    final dx = details.velocity.pixelsPerSecond.dx;
    if (dx > 300) {
      _animateSwipe(toRight: true);
    } else if (dx < -300) {
      _animateSwipe(toRight: false);
    }
  }
  
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    setState(() {
      _likes = _prefs.getInt('likes') ?? 0;

      _likedCats = (_prefs.getStringList('likedCats') ?? [])
          .map(
            (e) => CatImage.fromJson(Map<String, dynamic>.from(jsonDecode(e))),
          )
          .toList();
    });
  }

  Future<void> _loadCat() async {
    setState(() => _loading = true);

    try {
      final current = await _apiClient.fetchRandomCat();
      final next = await _apiClient.fetchRandomCat();

      setState(() {
        _currentCat = current;
        _nextCat = next;
      });
    } catch (e) {
      if (!mounted) return;
      await showErrorDialog(context, e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _prepareNextCat() async {
    try {
      final newCat = await _apiClient.fetchRandomCat();
      setState(() => _nextCat = newCat);
    } catch (e) {
      if (!mounted) return;
      await showErrorDialog(context, e.toString());
    }
  }

  void _showNextCat() {
    setState(() {
      _currentCat = _nextCat;
    });
    _prepareNextCat();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: _buildAppBar(),
      body: AnimatedPawsBackground(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: _loading || _currentCat == null
                  ? const CircularProgressIndicator()
                  : _buildContent(primary),
            ),

            if (_showLikeBurst)
              Positioned(
                child: LikeBurst(color: Colors.red, onFinished: () {}),
              ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: GestureDetector(
        onTap: () => _openLikedCats(context),
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                const Text("❤️", style: TextStyle(fontSize: 22)),
                const SizedBox(width: 4),
                Text("$_likes", style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
        ),
      ),
      title: const Text('Mewinder'),
    );
  }

  Widget _buildContent(Color primary) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAnimatedSwipeCard(primary),
        const SizedBox(height: 16),
        _buildBreedName(),
        const SizedBox(height: 20),
        _buildButtons(),
      ],
    );
  }

  Widget _buildAnimatedSwipeCard(Color primary) {
    return AnimatedBuilder(
      animation: _swipeController,
      builder: (_, child) {
        final offsetX = _swipeOffset * (_swipeAngle > 0 ? 500 : -500);
        final opacity = 1 - _swipeAnimation.value;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(offsetX, 0),
                child: Transform.rotate(
                  angle: _swipeAngle * _swipeAnimation.value,
                  child: child,
                ),
              ),
            ),

            _SwipeOverlay(
              progress: _swipeAnimation.value,
              direction: _swipeAngle > 0
                  ? SwipeDirection.right
                  : SwipeDirection.left,
            ),
          ],
        );
      },
      child: _buildSwipeCard(primary),
    );
  }

  Widget _buildSwipeCard(Color primary) {
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
            placeholder: (_, _) => Shimmer.fromColors(
              baseColor: primary.withValues(alpha: 0.25),
              highlightColor: primary.withValues(alpha: 0.15),
              child: Container(color: Colors.white),
            ),
            errorWidget: (_, _, _) => const Icon(Icons.error),
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
          onPressed: () => _animateSwipe(toRight: false),
        ),
        const SizedBox(width: 40),
        IconButton(
          iconSize: 48,
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () {
            _triggerLikeBurst();
            _animateSwipe(toRight: true);
          },
        ),
      ],
    );
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

    _showNextCat();
  }

  void _dislike() => _showNextCat();

  void _openCatDetails() {
    if (_currentCat == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CatDetailsPage(cat: _currentCat!)),
    );
  }

  Future<void> _openLikedCats(BuildContext context) async {
    final updatedList = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LikedCatsPage(likedCats: _likedCats)),
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

enum SwipeDirection { left, right }

class _SwipeOverlay extends StatelessWidget {
  final double progress;
  final SwipeDirection direction;

  const _SwipeOverlay({required this.progress, required this.direction});

  @override
  Widget build(BuildContext context) {
    if (progress == 0) return const SizedBox.shrink();

    final isRight = direction == SwipeDirection.right;

    return Opacity(
      opacity: (progress * 1.2).clamp(0.0, 1.0),
      child: Transform.rotate(
        angle: isRight ? -0.4 : 0.4,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isRight ? Colors.red : Colors.red,
              width: 4,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isRight ? "LIKE ❤️" : "NOPE ❌",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: isRight ? Colors.red : Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
