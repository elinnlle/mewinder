import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../common/models/cat_image.dart';
import 'cat_details_page.dart';

class LikedCatsPage extends StatefulWidget {
  final List<CatImage> likedCats;

  const LikedCatsPage({required this.likedCats, super.key});

  @override
  State<LikedCatsPage> createState() => _LikedCatsPageState();
}

class _LikedCatsPageState extends State<LikedCatsPage> {
  late List<CatImage> _cats;

  @override
  void initState() {
    super.initState();
    _cats = List.from(widget.likedCats);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _cats.isEmpty ? _buildEmptyPlaceholder() : _buildListView(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Liked сats'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context, _cats);
        },
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return const Center(
      child: Text('No liked cats yet 😿'),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      itemCount: _cats.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) => _buildListTile(context, index),
    );
  }

  Widget _buildListTile(BuildContext context, int index) {
    final cat = _cats[index];
    final breed = cat.breeds.isNotEmpty ? cat.breeds.first.name : 'Неизвестно';

    return ListTile(
      leading: _buildThumbnail(cat),
      title: Text(breed),
      trailing: _buildDeleteButton(context, index),
      onTap: () => _openCatDetails(cat),
    );
  }

  Widget _buildThumbnail(CatImage cat) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 60,
        height: 60,
        child: CachedNetworkImage(
          imageUrl: cat.url,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, int index) {
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () => _showDeleteDialog(context, index),
    );
  }

  void _openCatDetails(CatImage cat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CatDetailsPage(cat: cat),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
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
            onPressed: () => _deleteCat(context, index),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCat(BuildContext context, int index) async {
    Navigator.pop(context);

    setState(() {
      _cats.removeAt(index);
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      'likedCats',
      _cats.map((c) => jsonEncode(c.toJson())).toList(),
    );
  }
}
