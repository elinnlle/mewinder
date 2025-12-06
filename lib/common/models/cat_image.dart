// Модель для изображения кота с API
class CatImage {
  final String id;
  final String url;
  final List<CatBreed> breeds;

  CatImage({
    required this.id,
    required this.url,
    required this.breeds,
  });

  /// Создание объекта из JSON
  factory CatImage.fromJson(Map<String, dynamic> json) {
    return CatImage(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      breeds: (json['breeds'] as List<dynamic>? ?? [])
          .map((b) => CatBreed.fromJson(b))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'breeds': breeds.map((b) => b.toJson()).toList(),
    };
  }
}

// Модель породы
class CatBreed {
  final String id;
  final String name;
  final String? origin;
  final String? description;

  CatBreed({
    required this.id,
    required this.name,
    this.origin,
    this.description,
  });

  factory CatBreed.fromJson(Map<String, dynamic> json) {
    return CatBreed(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      origin: json['origin'],
      description: json['description'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'origin': origin,
      'description': description,
    };
  }
}
