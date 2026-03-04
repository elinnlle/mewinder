import 'package:flutter/foundation.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/cat.dart';
import '../../domain/usecases/get_liked_cats.dart';
import '../../domain/usecases/remove_liked_cat_at.dart';

class LikedCatsController extends ChangeNotifier {
  final GetLikedCats _getLikedCats;
  final RemoveLikedCatAt _removeLikedCatAt;

  LikedCatsController(this._getLikedCats, this._removeLikedCatAt);

  List<Cat> _cats = [];
  bool _loading = false;

  List<Cat> get cats => List.unmodifiable(_cats);
  bool get loading => _loading;

  Future<Failure?> load() async {
    _loading = true;
    notifyListeners();

    final result = await _getLikedCats();

    final failure = result.fold(
      onSuccess: (value) {
        _cats = value;
        return null;
      },
      onFailure: (value) => value,
    );

    _loading = false;
    notifyListeners();
    return failure;
  }

  Future<Failure?> removeAt(int index) async {
    final result = await _removeLikedCatAt(index);

    final failure = result.fold(
      onSuccess: (_) => null,
      onFailure: (value) => value,
    );

    if (failure != null) {
      return failure;
    }

    return load();
  }
}
