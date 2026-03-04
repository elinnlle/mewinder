import 'package:equatable/equatable.dart';

import 'cat_breed.dart';

class Cat extends Equatable {
  final String id;
  final String url;
  final List<CatBreed> breeds;

  const Cat({required this.id, required this.url, required this.breeds});

  @override
  List<Object?> get props => [id, url, breeds];
}
