import 'package:flutter/material.dart';

import '../../../../core/di.dart';
import '../../../../common/ui/error_dialog.dart';
import '../state/breeds_controller.dart';
import 'breed_details_page.dart';

class BreedsPage extends StatefulWidget {
  const BreedsPage({super.key});

  @override
  State<BreedsPage> createState() => _BreedsPageState();
}

class _BreedsPageState extends State<BreedsPage> {
  late final BreedsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = sl<BreedsController>();
    _controller.addListener(_onChanged);
    _load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _load() async {
    final failure = await _controller.loadBreeds();
    if (!mounted || failure == null) return;
    await showErrorDialog(context, failure.message);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.separated(
      itemCount: _controller.breeds.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final breed = _controller.breeds[index];
        final origin = breed.origin;

        return ListTile(
          title: Text(breed.name),
          subtitle: (origin == null || origin.isEmpty) ? null : Text(origin),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BreedDetailsPage(breed: breed)),
            );
          },
        );
      },
    );
  }
}
