import 'package:flutter/foundation.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/cat.dart';
import '../../domain/usecases/dislike_cat.dart';
import '../../domain/usecases/get_liked_cats.dart';
import '../../domain/usecases/get_random_cat.dart';
import '../../domain/usecases/like_cat.dart';

class CatSwipeController extends ChangeNotifier {
  final GetRandomCat _getRandomCat;
  final GetLikedCats _getLikedCats;
  final LikeCat _likeCat;
  final DislikeCat _dislikeCat;

  Cat? _currentCat;
  Cat? _nextCat;
  List<Cat> _likedCats = [];
  bool _loading = false;

  CatSwipeController(
    this._getRandomCat,
    this._getLikedCats,
    this._likeCat,
    this._dislikeCat,
  );

  Cat? get currentCat => _currentCat;
  bool get loading => _loading;
  int get likesCount => _likedCats.length;
  List<Cat> get likedCats => List.unmodifiable(_likedCats);

  Future<Failure?> initialize() async {
    _setLoading(true);

    final likedFailure = await refreshLikedCats();
    if (likedFailure != null) {
      _setLoading(false);
      return likedFailure;
    }

    final currentResult = await _getRandomCat();
    final currentFailure = currentResult.fold(
      onSuccess: (cat) {
        _currentCat = cat;
        return null;
      },
      onFailure: (failure) => failure,
    );

    if (currentFailure != null) {
      _setLoading(false);
      return currentFailure;
    }

    final nextResult = await _getRandomCat();
    nextResult.fold(
      onSuccess: (cat) {
        _nextCat = cat;
      },
      onFailure: (_) {},
    );

    _setLoading(false);
    notifyListeners();
    return null;
  }

  Future<Failure?> refreshLikedCats() async {
    final likedResult = await _getLikedCats();

    return likedResult.fold(
      onSuccess: (cats) {
        _likedCats = cats;
        notifyListeners();
        return null;
      },
      onFailure: (failure) => failure,
    );
  }

  Future<Failure?> likeCurrentCat() async {
    final cat = _currentCat;
    if (cat == null) {
      return const UnknownFailure('No active cat found');
    }

    final likeResult = await _likeCat(cat);
    final likeFailure = likeResult.fold(
      onSuccess: (_) => null,
      onFailure: (failure) => failure,
    );

    if (likeFailure != null) return likeFailure;

    final likedFailure = await refreshLikedCats();
    if (likedFailure != null) return likedFailure;

    await _showNextCat();
    return null;
  }

  Future<Failure?> dislikeCurrentCat() async {
    final cat = _currentCat;
    if (cat != null) {
      final result = await _dislikeCat(cat);
      final failure = result.fold(
        onSuccess: (_) => null,
        onFailure: (value) => value,
      );
      if (failure != null) {
        return failure;
      }
    }

    await _showNextCat();
    return null;
  }

  Future<void> _showNextCat() async {
    _currentCat = _nextCat;
    notifyListeners();

    final nextResult = await _getRandomCat();
    nextResult.fold(
      onSuccess: (cat) {
        _nextCat = cat;
      },
      onFailure: (_) {},
    );

    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
