import '../../../../core/result.dart';
import '../entities/cat.dart';
import '../entities/cat_breed.dart';

abstract class CatsRepository {
  Stream<List<Cat>> watchLikedCats();

  Future<Result<Cat>> fetchRandomCat();
  Future<Result<List<CatBreed>>> fetchBreeds();
  Future<Result<List<Cat>>> getLikedCats();
  Future<Result<void>> likeCat(Cat cat);
  Future<Result<void>> dislikeCat(Cat cat);
  Future<Result<void>> removeLikedCatAt(int index);
}
