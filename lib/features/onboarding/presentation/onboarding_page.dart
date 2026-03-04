import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingPage extends StatefulWidget {
  final Future<void> Function() onCompleted;

  const OnboardingPage({super.key, required this.onCompleted});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();

  late final AnimationController _backgroundController;
  int _currentIndex = 0;
  bool _isSubmitting = false;

  final List<_OnboardingStep> _steps = const [
    _OnboardingStep(
      title: 'Swipe cats',
      description:
          'Swipe cards left or right to dislike or like cats. Liked cats are saved to Favorites.',
      icon: Icons.swipe,
    ),
    _OnboardingStep(
      title: 'Open breed details',
      description:
          'Tap a card to see origin, temperament and detailed breed info.',
      icon: Icons.info_outline,
    ),
    _OnboardingStep(
      title: 'Browse breeds and tabs',
      description:
          'Open the Breeds tab to view the full breed list, and switch between Swipes, Breeds and Account.',
      icon: Icons.dashboard_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_backgroundController, _pageController]),
        builder: (context, _) {
          final pageValue = _pageController.hasClients
              ? (_pageController.page ?? _currentIndex.toDouble())
              : _currentIndex.toDouble();

          return Stack(
            children: [
              _OnboardingBackground(
                animationValue: _backgroundController.value,
                pageValue: pageValue,
              ),
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _AnimatedCat(pageValue: pageValue),
                    const SizedBox(height: 20),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _steps.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final step = _steps[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 34,
                                  backgroundColor: theme.colorScheme.primary
                                      .withValues(alpha: 0.2),
                                  child: Icon(
                                    step.icon,
                                    size: 34,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  step.title,
                                  style: theme.textTheme.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  step.description,
                                  style: theme.textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _steps.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentIndex == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? theme.colorScheme.primary
                                : theme.colorScheme.primary.withValues(
                                    alpha: 0.35,
                                  ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isSubmitting
                              ? null
                              : _handlePrimaryAction,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _currentIndex == _steps.length - 1
                                      ? 'Start'
                                      : 'Next',
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handlePrimaryAction() async {
    if (_currentIndex < _steps.length - 1) {
      await _pageController.animateToPage(
        _currentIndex + 1,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await widget.onCompleted();

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });
  }
}

class _AnimatedCat extends StatelessWidget {
  final double pageValue;

  const _AnimatedCat({required this.pageValue});

  @override
  Widget build(BuildContext context) {
    final normalized = pageValue / 2;
    final x = (normalized - 0.5) * 180;
    final rotation = (normalized - 0.5) * 0.5;
    final scale = 1 + 0.12 * math.sin(pageValue * math.pi);
    final y = -16 * math.sin(pageValue * math.pi);

    return SizedBox(
      height: 140,
      child: Transform.translate(
        offset: Offset(x, y),
        child: Transform.rotate(
          angle: rotation,
          child: Transform.scale(
            scale: scale,
            child: SvgPicture.asset('assets/cat.svg', height: 120),
          ),
        ),
      ),
    );
  }
}

class _OnboardingBackground extends StatelessWidget {
  final double animationValue;
  final double pageValue;

  const _OnboardingBackground({
    required this.animationValue,
    required this.pageValue,
  });

  @override
  Widget build(BuildContext context) {
    final shift = (pageValue - 1) * 30;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2), Color(0xFFFFF8E1)],
        ),
      ),
      child: Stack(
        children: [
          _blob(
            left: -80 + shift,
            top: 60 + 40 * math.sin(animationValue * math.pi * 2),
            size: 180,
            color: const Color(0x33FF8A65),
          ),
          _blob(
            right: -60 - shift,
            top: 220 + 35 * math.cos(animationValue * math.pi * 2),
            size: 160,
            color: const Color(0x33FFB74D),
          ),
          _blob(
            left: 90 - shift,
            bottom: -40 + 45 * math.sin(animationValue * math.pi * 2),
            size: 200,
            color: const Color(0x33FF7043),
          ),
        ],
      ),
    );
  }

  Widget _blob({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double size,
    required Color color,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size),
        ),
      ),
    );
  }
}

class _OnboardingStep {
  final String title;
  final String description;
  final IconData icon;

  const _OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}
