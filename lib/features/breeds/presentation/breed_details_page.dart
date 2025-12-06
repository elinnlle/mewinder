import 'package:flutter/material.dart';
import '../../../common/models/cat_breed.dart';

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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          if (breed.origin != null) _buildOrigin(context),
          if (breed.origin != null) const SizedBox(height: 16),

          _buildCharacteristics(context),
          const SizedBox(height: 16),

          if (breed.description != null) _buildDescription(context),
        ],
      ),
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
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildCharacteristics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Characteristics:',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        _buildCharacteristicRow('Temperament', breed.temperament),
        _buildCharacteristicRow('Life span', breed.lifeSpan),
        _buildCharacteristicRow('Weight (kg)', breed.weightMetric),
        _buildCharacteristicRow('Energy level', breed.energyLevel?.toString()),
      ],
    );
  }

  Widget _buildCharacteristicRow(String title, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(height: 1.3),
            ),
          ),
        ],
      ),
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
