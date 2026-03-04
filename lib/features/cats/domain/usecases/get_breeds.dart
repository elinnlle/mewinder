import '../../../../core/result.dart';
import '../entities/cat_breed.dart';
import '../repositories/cats_repository.dart';

class GetBreeds {
  final CatsRepository _repository;

  const GetBreeds(this._repository);

  Future<Result<List<CatBreed>>> call() => _repository.fetchBreeds();
}
