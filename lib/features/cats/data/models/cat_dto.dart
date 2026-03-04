import '../../domain/entities/cat.dart';
import 'cat_breed_dto.dart';

class CatDto {
  final String id;
  final String url;
  final List<CatBreedDto> breeds;

  const CatDto({required this.id, required this.url, required this.breeds});

  factory CatDto.fromJson(Map<String, dynamic> json) {
    final rawBreeds = json['breeds'];
    final breedsList = rawBreeds is List ? rawBreeds : const [];

    return CatDto(
      id: (json['id'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
      breeds: breedsList
          .whereType<Map<String, dynamic>>()
          .map(CatBreedDto.fromJson)
          .toList(),
    );
  }

  factory CatDto.fromStorageJson(Map<String, dynamic> json) {
    final rawBreeds = json['breeds'];
    final breedsList = rawBreeds is List ? rawBreeds : const [];

    return CatDto(
      id: (json['id'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
      breeds: breedsList
          .whereType<Map<String, dynamic>>()
          .map(CatBreedDto.fromStorageJson)
          .toList(),
    );
  }

  Cat toEntity() {
    return Cat(
      id: id,
      url: url,
      breeds: breeds.map((breed) => breed.toEntity()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'breeds': breeds.map((breed) => breed.toJson()).toList(),
    };
  }

  factory CatDto.fromEntity(Cat cat) {
    return CatDto(
      id: cat.id,
      url: cat.url,
      breeds: cat.breeds.map(CatBreedDto.fromEntity).toList(),
    );
  }
}
