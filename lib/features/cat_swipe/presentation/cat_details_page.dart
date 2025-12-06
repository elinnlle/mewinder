import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../common/models/cat_image.dart';

class CatDetailsPage extends StatelessWidget {
  final CatImage cat;

  const CatDetailsPage({
    super.key,
    required this.cat,
  });

  @override
  Widget build(BuildContext context) {
    final breed = cat.breeds.isNotEmpty ? cat.breeds.first : null;

    return Scaffold(
      appBar: _buildAppBar(breed?.name),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildContent(context, breed),
      ),
    );
  }

  AppBar _buildAppBar(String? title) {
    return AppBar(
      title: Text(title ?? 'Котик'),
      centerTitle: true,
    );
  }

  Widget _buildContent(BuildContext context, CatBreed? breed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildImage(),
        const SizedBox(height: 16),
        if (breed != null)
          _buildBreedInfo(context, breed)
        else
          _buildEmptyBreedInfo(),
      ],
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
          placeholder: (_, __) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (_, __, ___) =>
              const Center(child: Icon(Icons.error)),
        ),
      ),
    );
  }

  Widget _buildBreedInfo(BuildContext context, CatBreed breed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          breed.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),

        if (breed.origin != null && breed.origin!.isNotEmpty) ...[
          Text(
            'Country of origin:',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 4),
          Text(
            breed.origin!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
        ],

        if (breed.description != null && breed.description!.isNotEmpty) ...[
          Text(
            'Description',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 4),
          Text(
            breed.description!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.3,
                ),
            textAlign: TextAlign.justify,
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyBreedInfo() {
    return const Text(
      'Breed information is not available 🙈',
      textAlign: TextAlign.center,
    );
  }
}
