import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/failures.dart';
import '../../../../../core/result.dart';
import '../../models/cat_dto.dart';

abstract class LikedCatsLocalDataSource {
  Future<Result<List<CatDto>>> getLikedCats();
  Future<Result<void>> saveLikedCats(List<CatDto> cats);
}

class LikedCatsLocalDataSourceImpl implements LikedCatsLocalDataSource {
  static const _likedCatsKey = 'likedCats';
  static const _likesKey = 'likes';

  final SharedPreferences _preferences;

  const LikedCatsLocalDataSourceImpl(this._preferences);

  @override
  Future<Result<List<CatDto>>> getLikedCats() async {
    try {
      final stored = _preferences.getStringList(_likedCatsKey) ?? [];
      final cats = stored
          .map((item) => jsonDecode(item))
          .whereType<Map<String, dynamic>>()
          .map(CatDto.fromStorageJson)
          .toList();
      return Success<List<CatDto>>(cats);
    } catch (_) {
      return const FailureResult<List<CatDto>>(
        StorageFailure('Failed to read liked cats from local storage'),
      );
    }
  }

  @override
  Future<Result<void>> saveLikedCats(List<CatDto> cats) async {
    try {
      final encoded = cats.map((cat) => jsonEncode(cat.toJson())).toList();
      final saved = await _preferences.setStringList(_likedCatsKey, encoded);
      if (!saved) {
        return const FailureResult<void>(
          StorageFailure('Failed to persist liked cats'),
        );
      }
      await _preferences.setInt(_likesKey, cats.length);
      return const Success<void>(null);
    } catch (_) {
      return const FailureResult<void>(
        StorageFailure('Failed to persist liked cats'),
      );
    }
  }
}
