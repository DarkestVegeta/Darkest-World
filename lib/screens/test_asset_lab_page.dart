import 'package:flutter/material.dart';

import '../core/asset_models.dart';
import '../core/asset_repository.dart';

class TestAssetLabPage extends StatefulWidget {
  const TestAssetLabPage({super.key});

  @override
  State<TestAssetLabPage> createState() => _TestAssetLabPageState();
}

class _TestAssetLabPageState extends State<TestAssetLabPage> {
  final _repository = StorageAssetRepository();
  late Future<List<StorageAsset>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.getTestAssets();
  }

  void _reload() {
    setState(() {
      _future = _repository.getTestAssets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DarkestWorld Test Lab'),
        actions: [
          IconButton(
            tooltip: 'Reload test assets',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<StorageAsset>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Test assets laden mislukt: ${snapshot.error}'));
          }

          final items = snapshot.data ?? const <StorageAsset>[];
          if (items.isEmpty) {
            return const Center(child: Text('Geen test-artboxen gevonden.'));
          }

          return ListView(
            padding: const EdgeInsets.all(28),
            children: [
              Text(
                'Fixed test set: ${items.length}/10 SNES artboxes',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Deze tien bestaande artboxen zijn alleen testmateriaal voor Flutter. Ze worden niet gekopieerd, verwijderd of aangepast.',
              ),
              const SizedBox(height: 24),
              for (var index = 0; index < items.length; index++)
                _TestAssetCard(index: index + 1, asset: items[index]),
            ],
          );
        },
      ),
    );
  }
}

class _TestAssetCard extends StatelessWidget {
  final int index;
  final StorageAsset asset;

  const _TestAssetCard({required this.index, required this.asset});

  @override
  Widget build(BuildContext context) {
    final title = asset.title ?? 'Untitled';
    final url = asset.publicUrl ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 220,
        child: Row(
          children: [
            SizedBox(
              width: 150,
              child: url.isEmpty
                  ? const Center(child: Icon(Icons.image_not_supported))
                  : Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image),
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '#$index  $title',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text('${asset.assetType} • fixed test asset'),
                    const SizedBox(height: 18),
                    const Text('Basis-test: image loading, sizing, card layout en data-binding.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
