import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../common/ui/error_dialog.dart';
import '../../../../core/di.dart';
import '../state/liked_cats_controller.dart';
import 'cat_details_page.dart';

class LikedCatsPage extends StatefulWidget {
  const LikedCatsPage({super.key});

  @override
  State<LikedCatsPage> createState() => _LikedCatsPageState();
}

class _LikedCatsPageState extends State<LikedCatsPage> {
  late final LikedCatsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = sl<LikedCatsController>();
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
    final failure = await _controller.load();
    if (!mounted || failure == null) return;
    await showErrorDialog(context, failure.message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked cats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.cats.isEmpty) {
      return const Center(child: Text('No liked cats yet 😿'));
    }

    return ListView.separated(
      itemCount: _controller.cats.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final cat = _controller.cats[index];
        final breedName = cat.breeds.isNotEmpty
            ? cat.breeds.first.name
            : 'Unknown';

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: CachedNetworkImage(imageUrl: cat.url, fit: BoxFit.cover),
            ),
          ),
          title: Text(breedName),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(index),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CatDetailsPage(cat: cat)),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(int index) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete?'),
        content: const Text('Delete the cat from liked cats?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final failure = await _controller.removeAt(index);
              if (!mounted || failure == null) return;
              await showErrorDialog(context, failure.message);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
