import '../../../../core/result.dart';
import '../entities/cat.dart';
import '../repositories/cats_repository.dart';

class GetLikedCats {
  final CatsRepository _repository;

  const GetLikedCats(this._repository);

  Future<Result<List<Cat>>> call() => _repository.getLikedCats();
}
