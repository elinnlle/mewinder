import '../../../../core/result.dart';
import '../entities/cat.dart';
import '../repositories/cats_repository.dart';

class GetRandomCat {
  final CatsRepository _repository;

  const GetRandomCat(this._repository);

  Future<Result<Cat>> call() => _repository.fetchRandomCat();
}
