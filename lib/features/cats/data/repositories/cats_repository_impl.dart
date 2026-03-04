import 'dart:async';

import '../../../../core/failures.dart';
import '../../../../core/result.dart';
import '../../domain/entities/cat.dart';
import '../../domain/entities/cat_breed.dart';
import '../../domain/repositories/cats_repository.dart';
import '../datasources/local/liked_cats_local_data_source.dart';
import '../datasources/remote/cats_remote_data_source.dart';
import '../models/cat_dto.dart';

class CatsRepositoryImpl implements CatsRepository {
  final CatsRemoteDataSource _remoteDataSource;
  final LikedCatsLocalDataSource _localDataSource;
  final StreamController<List<Cat>> _likedCatsController;

  CatsRepositoryImpl(this._remoteDataSource, this._localDataSource)
    : _likedCatsController = StreamController<List<Cat>>.broadcast() {
    _syncLikedCatsStream();
  }

  @override
  Stream<List<Cat>> watchLikedCats() => _likedCatsController.stream;

  @override
  Future<Result<Cat>> fetchRandomCat() async {
    final response = await _remoteDataSource.fetchRandomCat();

    return response.fold(
      onSuccess: (catDto) => Success<Cat>(catDto.toEntity()),
      onFailure: FailureResult<Cat>.new,
    );
  }

  @override
  Future<Result<List<CatBreed>>> fetchBreeds() async {
    final response = await _remoteDataSource.fetchBreeds();

    return response.fold(
      onSuccess: (breedDtos) => Success<List<CatBreed>>(
        breedDtos.map((dto) => dto.toEntity()).toList(),
      ),
      onFailure: FailureResult<List<CatBreed>>.new,
    );
  }

  @override
  Future<Result<List<Cat>>> getLikedCats() async {
    final response = await _localDataSource.getLikedCats();

    return response.fold(
      onSuccess: (cats) =>
          Success<List<Cat>>(cats.map((catDto) => catDto.toEntity()).toList()),
      onFailure: FailureResult<List<Cat>>.new,
    );
  }

  @override
  Future<Result<void>> likeCat(Cat cat) async {
    final existing = await _localDataSource.getLikedCats();

    return existing.fold(
      onSuccess: (cats) async {
        final updated = List<CatDto>.from(cats)..add(CatDto.fromEntity(cat));
        final saveResult = await _localDataSource.saveLikedCats(updated);
        if (saveResult is FailureResult<void>) {
          return saveResult;
        }
        _likedCatsController.add(
          updated.map((item) => item.toEntity()).toList(),
        );
        return const Success<void>(null);
      },
      onFailure: (failure) async => FailureResult<void>(failure),
    );
  }

  @override
  Future<Result<void>> dislikeCat(Cat cat) async {
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> removeLikedCatAt(int index) async {
    final existing = await _localDataSource.getLikedCats();

    return existing.fold(
      onSuccess: (cats) async {
        if (index < 0 || index >= cats.length) {
          return const FailureResult<void>(
            ValidationFailure('Cat index is out of range'),
          );
        }

        final updated = List<CatDto>.from(cats)..removeAt(index);
        final saveResult = await _localDataSource.saveLikedCats(updated);
        if (saveResult is FailureResult<void>) {
          return saveResult;
        }

        _likedCatsController.add(
          updated.map((item) => item.toEntity()).toList(),
        );
        return const Success<void>(null);
      },
      onFailure: (failure) async => FailureResult<void>(failure),
    );
  }

  Future<void> _syncLikedCatsStream() async {
    final result = await getLikedCats();
    result.fold(onSuccess: _likedCatsController.add, onFailure: (_) {});
  }
}
