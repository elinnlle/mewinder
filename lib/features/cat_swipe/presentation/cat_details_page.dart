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
      appBar: AppBar(
        title: Text(breed?.name ?? 'Котик'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Картинка котика
            ClipRRect(
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
            ),
            const SizedBox(height: 16),

            // Информация о породе
            if (breed != null) ...[
              Text(
                breed.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              if (breed.origin != null && breed.origin!.isNotEmpty) ...[
                Text(
                  'Страна происхождения:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  breed.origin!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
              ],
              if (breed.description != null &&
                  breed.description!.isNotEmpty) ...[
                Text(
                  'Описание',
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
            ] else ...[
              const Text(
                'Информация о породе недоступна 🙈',
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
