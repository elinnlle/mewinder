import 'package:flutter/material.dart';

import '../../../common/services/api/cat_api_client.dart';
import '../../../common/models/cat_breed.dart';
import '../../../common/ui/error_dialog.dart';
import 'breed_details_page.dart';

class BreedsPage extends StatefulWidget {
  const BreedsPage({super.key});

  @override
  State<BreedsPage> createState() => _BreedsPageState();
}

class _BreedsPageState extends State<BreedsPage> {
  final _api = CatApiClient();

  List<CatBreed> _breeds = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBreeds();
  }

  Future<void> _loadBreeds() async {
    setState(() {
      _loading = true;
    });

    try {
      final breeds = await _api.fetchBreeds();
      setState(() => _breeds = breeds);
    } catch (e) {
      await showErrorDialog(context, e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoading();

    return _buildList();
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildList() {
    return ListView.separated(
      itemCount: _breeds.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) => _buildListTile(index),
    );
  }

  Widget _buildListTile(int index) {
    final breed = _breeds[index];

    return ListTile(
      title: Text(breed.name),
      subtitle: breed.origin != null ? Text(breed.origin!) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _openBreedDetails(breed),
    );
  }

  void _openBreedDetails(CatBreed breed) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BreedDetailsPage(breed: breed),
      ),
    );
  }
}
