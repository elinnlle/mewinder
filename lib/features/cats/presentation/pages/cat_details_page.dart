import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/cat.dart';
import '../../domain/entities/cat_breed.dart';

class CatDetailsPage extends StatelessWidget {
  final Cat cat;

  const CatDetailsPage({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    final breed = cat.breeds.isNotEmpty ? cat.breeds.first : null;

    return Scaffold(
      appBar: AppBar(title: Text(breed?.name ?? 'Cat'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImage(),
            const SizedBox(height: 16),
            if (breed != null)
              _BreedInfo(breed: breed)
            else
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'Breed information is not available 🙈',
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: CachedNetworkImage(
          imageUrl: cat.url,
          fit: BoxFit.cover,
          placeholder: (_, _) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (_, _, _) => const Center(child: Icon(Icons.error)),
        ),
      ),
    );
  }
}

class _BreedInfo extends StatelessWidget {
  final CatBreed breed;

  const _BreedInfo({required this.breed});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          breed.name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if ((breed.origin ?? '').isNotEmpty) _buildOrigin(context),
        if ((breed.origin ?? '').isNotEmpty) const SizedBox(height: 16),
        if ((breed.description ?? '').isNotEmpty) _buildDescription(context),
      ],
    );
  }

  Widget _buildOrigin(BuildContext context) {
    final origin = breed.origin;
    if (origin == null || origin.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Country of origin:',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          origin,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.3),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    final description = breed.description;
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description:',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.3),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}
