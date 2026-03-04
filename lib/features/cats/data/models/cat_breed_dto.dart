import '../../domain/entities/cat_breed.dart';

class CatBreedDto {
  final String id;
  final String name;
  final String? origin;
  final String? description;
  final String? temperament;
  final String? lifeSpan;
  final String? weightMetric;
  final int? energyLevel;

  const CatBreedDto({
    required this.id,
    required this.name,
    this.origin,
    this.description,
    this.temperament,
    this.lifeSpan,
    this.weightMetric,
    this.energyLevel,
  });

  factory CatBreedDto.fromJson(Map<String, dynamic> json) {
    final weight = json['weight'];
    final weightMap = weight is Map<String, dynamic> ? weight : null;

    return CatBreedDto(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      origin: json['origin'] as String?,
      description: json['description'] as String?,
      temperament: json['temperament'] as String?,
      lifeSpan: json['life_span'] as String?,
      weightMetric: weightMap?['metric'] as String?,
      energyLevel: json['energy_level'] as int?,
    );
  }

  factory CatBreedDto.fromStorageJson(Map<String, dynamic> json) {
    return CatBreedDto(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      origin: json['origin'] as String?,
      description: json['description'] as String?,
      temperament: json['temperament'] as String?,
      lifeSpan: json['life_span'] as String?,
      weightMetric: json['weight_metric'] as String?,
      energyLevel: json['energy_level'] as int?,
    );
  }

  CatBreed toEntity() {
    return CatBreed(
      id: id,
      name: name,
      origin: origin,
      description: description,
      temperament: temperament,
      lifeSpan: lifeSpan,
      weightMetric: weightMetric,
      energyLevel: energyLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'origin': origin,
      'description': description,
      'temperament': temperament,
      'life_span': lifeSpan,
      'weight_metric': weightMetric,
      'energy_level': energyLevel,
    };
  }

  factory CatBreedDto.fromEntity(CatBreed breed) {
    return CatBreedDto(
      id: breed.id,
      name: breed.name,
      origin: breed.origin,
      description: breed.description,
      temperament: breed.temperament,
      lifeSpan: breed.lifeSpan,
      weightMetric: breed.weightMetric,
      energyLevel: breed.energyLevel,
    );
  }
}
