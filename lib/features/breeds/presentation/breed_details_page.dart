import 'package:flutter/material.dart';
import '../../../common/models/cat_image.dart';

class BreedDetailsPage extends StatelessWidget {
  final CatBreed breed;

  const BreedDetailsPage({required this.breed, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildContent(context),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(breed.name),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        if (breed.origin != null) _buildOrigin(context),
        if (breed.origin != null) const SizedBox(height: 12),
        if (breed.description != null) _buildDescription(context),
      ],
    );
  }

  Widget _buildOrigin(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Country of origin:',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Text(
          breed.origin!,
          style: Theme.of(context).textTheme.bodyLarge,
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
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Text(
          breed.description!,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(height: 1.3),
        ),
      ],
    );
  }
}
