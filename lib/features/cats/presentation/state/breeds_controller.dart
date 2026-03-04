import 'package:flutter/foundation.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/cat_breed.dart';
import '../../domain/usecases/get_breeds.dart';

class BreedsController extends ChangeNotifier {
  final GetBreeds _getBreeds;

  BreedsController(this._getBreeds);

  List<CatBreed> _breeds = [];
  bool _loading = false;

  List<CatBreed> get breeds => List.unmodifiable(_breeds);
  bool get loading => _loading;

  Future<Failure?> loadBreeds() async {
    _loading = true;
    notifyListeners();

    final result = await _getBreeds();

    final failure = result.fold(
      onSuccess: (value) {
        _breeds = value;
        return null;
      },
      onFailure: (value) => value,
    );

    _loading = false;
    notifyListeners();
    return failure;
  }
}
