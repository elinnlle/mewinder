import '../../../../core/result.dart';
import '../repositories/cats_repository.dart';

class RemoveLikedCatAt {
  final CatsRepository _repository;

  const RemoveLikedCatAt(this._repository);

  Future<Result<void>> call(int index) => _repository.removeLikedCatAt(index);
}
