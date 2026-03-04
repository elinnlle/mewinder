import '../../../../core/result.dart';
import '../entities/cat.dart';
import '../repositories/cats_repository.dart';

class LikeCat {
  final CatsRepository _repository;

  const LikeCat(this._repository);

  Future<Result<void>> call(Cat cat) => _repository.likeCat(cat);
}
