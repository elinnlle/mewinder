import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../common/ui/animated_background.dart';
import '../../../../common/ui/error_dialog.dart';
import '../../../../common/ui/like_burst.dart';
import '../../../../core/di.dart';
import '../state/cat_swipe_controller.dart';
import 'cat_details_page.dart';
import 'liked_cats_page.dart';

class CatSwipePage extends StatefulWidget {
  const CatSwipePage({super.key});

  @override
  State<CatSwipePage> createState() => _CatSwipePageState();
}

class _CatSwipePageState extends State<CatSwipePage>
    with SingleTickerProviderStateMixin {
  late final CatSwipeController _controller;

  late final AnimationController _swipeController;
  late final Animation<double> _swipeAnimation;

  double _swipeOffset = 0;
  double _swipeAngle = 0;
  bool _isAnimating = false;
  bool _showLikeBurst = false;

  @override
  void initState() {
    super.initState();
    _controller = sl<CatSwipeController>();
    _controller.addListener(_onStateChanged);

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

    _initialize();
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    _swipeController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initialize() async {
    final failure = await _controller.initialize();
    if (!mounted || failure == null) return;
    await showErrorDialog(context, failure.message);
  }

  void _triggerLikeBurst() {
    setState(() => _showLikeBurst = true);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() => _showLikeBurst = false);
      }
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

    await _swipeController.forward();

    final failure = toRight
        ? await _controller.likeCurrentCat()
        : await _controller.dislikeCurrentCat();

    if (!mounted || failure == null) return;
    await showErrorDialog(context, failure.message);
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

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final currentCat = _controller.currentCat;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: _openLikedCats,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  const Text('❤️', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 4),
                  Text(
                    '${_controller.likesCount}',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
        title: const Text('Mewinder'),
      ),
      body: AnimatedPawsBackground(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: _controller.loading || currentCat == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAnimatedSwipeCard(primary),
                        const SizedBox(height: 16),
                        Text(
                          currentCat.breeds.isNotEmpty
                              ? currentCat.breeds.first.name
                              : 'Unknown breed',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 20),
                        Row(
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
                              icon: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                              onPressed: () => _animateSwipe(toRight: true),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
            if (_showLikeBurst)
              const Positioned(
                child: LikeBurst(color: Colors.red, onFinished: _noop),
              ),
          ],
        ),
      ),
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
    final currentCat = _controller.currentCat;
    if (currentCat == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CatDetailsPage(cat: currentCat)),
        );
      },
      onPanEnd: _handleSwipe,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 300,
          height: 300,
          child: CachedNetworkImage(
            imageUrl: currentCat.url,
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

  Future<void> _openLikedCats() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LikedCatsPage()));

    final failure = await _controller.refreshLikedCats();
    if (!mounted || failure == null) return;
    await showErrorDialog(context, failure.message);
  }
}

void _noop() {}

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
            border: Border.all(color: Colors.red, width: 4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isRight ? 'LIKE ❤️' : 'NOPE ❌',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
