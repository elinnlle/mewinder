import 'package:equatable/equatable.dart';

class CatBreed extends Equatable {
  final String id;
  final String name;
  final String? origin;
  final String? description;
  final String? temperament;
  final String? lifeSpan;
  final String? weightMetric;
  final int? energyLevel;

  const CatBreed({
    required this.id,
    required this.name,
    this.origin,
    this.description,
    this.temperament,
    this.lifeSpan,
    this.weightMetric,
    this.energyLevel,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    origin,
    description,
    temperament,
    lifeSpan,
    weightMetric,
    energyLevel,
  ];
}
