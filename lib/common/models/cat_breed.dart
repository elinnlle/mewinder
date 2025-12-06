// Модель породы
class CatBreed {
  final String id;
  final String name;
  final String? origin;
  final String? description;
  final String? temperament;
  final String? lifeSpan;
  final String? weightMetric;
  final int? energyLevel;

  CatBreed({
    required this.id,
    required this.name,
    this.origin,
    this.description,
    this.temperament,
    this.lifeSpan,
    this.weightMetric,
    this.energyLevel,
  });

  factory CatBreed.fromJson(Map<String, dynamic> json) {
    return CatBreed(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      origin: json['origin'],
      description: json['description'],
      temperament: json['temperament'],
      lifeSpan: json['life_span'],
      weightMetric: json['weight']?['metric'],
      energyLevel: json['energy_level'],
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
}
