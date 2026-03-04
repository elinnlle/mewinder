import '../../../../core/result.dart';
import '../entities/cat.dart';
import '../repositories/cats_repository.dart';

class DislikeCat {
  final CatsRepository _repository;

  const DislikeCat(this._repository);

  Future<Result<void>> call(Cat cat) => _repository.dislikeCat(cat);
}
