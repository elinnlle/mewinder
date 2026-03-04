import '../../../../../core/failures.dart';
import '../../../../../core/result.dart';
import '../../../../../common/services/api/cat_api_client.dart';
import '../../models/cat_breed_dto.dart';
import '../../models/cat_dto.dart';

abstract class CatsRemoteDataSource {
  Future<Result<CatDto>> fetchRandomCat();
  Future<Result<List<CatBreedDto>>> fetchBreeds();
}

class CatsRemoteDataSourceImpl implements CatsRemoteDataSource {
  final CatApiClient _apiClient;

  const CatsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Result<CatDto>> fetchRandomCat() async {
    final response = await _apiClient.fetchRandomCat();

    return response.fold(
      onSuccess: (items) {
        if (items.isEmpty) {
          return const FailureResult<CatDto>(
            UnknownFailure('The service returned an empty cats list'),
          );
        }

        final raw = items.first;
        if (raw is! Map<String, dynamic>) {
          return const FailureResult<CatDto>(
            UnknownFailure('Unexpected cat payload format'),
          );
        }

        return Success<CatDto>(CatDto.fromJson(raw));
      },
      onFailure: FailureResult<CatDto>.new,
    );
  }

  @override
  Future<Result<List<CatBreedDto>>> fetchBreeds() async {
    final response = await _apiClient.fetchBreeds();

    return response.fold(
      onSuccess: (items) {
        final breeds = items
            .whereType<Map<String, dynamic>>()
            .map(CatBreedDto.fromJson)
            .toList();
        return Success<List<CatBreedDto>>(breeds);
      },
      onFailure: FailureResult<List<CatBreedDto>>.new,
    );
  }
}
