import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../common/models/cat_image.dart';
import '../../../common/models/cat_breed.dart';

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
          _BreedInfo(breed: breed)
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
          errorWidget: (_, __, ___) => const Center(child: Icon(Icons.error)),
        ),
      ),
    );
  }

  Widget _buildEmptyBreedInfo() {
    return const Padding(
      padding: EdgeInsets.only(top: 20),
      child: Text(
        'Breed information is not available 🙈',
        textAlign: TextAlign.center,
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
        _buildTitle(context),
        const SizedBox(height: 12),

        if (_hasOrigin) _buildOrigin(context),
        if (_hasOrigin) const SizedBox(height: 16),

        if (_hasDescription) _buildDescription(context),
      ],
    );
  }

  bool get _hasOrigin => breed.origin != null && breed.origin!.isNotEmpty;
  bool get _hasDescription =>
      breed.description != null && breed.description!.isNotEmpty;

  Widget _buildTitle(BuildContext context) {
    return Text(
      breed.name,
      style: Theme.of(context)
          .textTheme
          .headlineSmall
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _buildOrigin(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Country of origin:',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          breed.origin!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.3),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description:',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          breed.description!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.3),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}
