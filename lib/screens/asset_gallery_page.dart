import 'package:flutter/material.dart';

import '../core/asset_models.dart';
import '../core/asset_repository.dart';

class AssetGalleryPage extends StatefulWidget {
  final String title;
  final String? assetType;

  const AssetGalleryPage({
    super.key,
    required this.title,
    this.assetType,
  });

  @override
  State<AssetGalleryPage> createState() => _AssetGalleryPageState();
}

class _AssetGalleryPageState extends State<AssetGalleryPage> {
  final _repository = StorageAssetRepository();
  final _scrollController = ScrollController();
  final _items = <StorageAsset>[];
  bool _loading = false;
  bool _hasMore = true;
  int _page = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNextPage();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.maxScrollExtent -
            _scrollController.position.pixels <
        900) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final page = await _repository.getAssetsPage(
        assetType: widget.assetType,
        page: _page,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(page);
        _page++;
        _hasMore = page.length == StorageAssetRepository.pageSize;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _items.clear();
      _page = 0;
      _hasMore = true;
      _error = null;
    });
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    await _loadNextPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Vernieuwen',
            onPressed: _loading ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Laden mislukt: $_error'),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _loadNextPage,
              child: const Text('Opnieuw'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return const Center(child: Text('Geen afbeeldingen gevonden.'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnsForWidth(constraints.maxWidth);
        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(36, 28, 36, 36),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 18,
            childAspectRatio: 1.0,
          ),
          itemCount: _items.length,
          itemBuilder: (context, index) => _AssetTile(asset: _items[index]),
        );
      },
    );
  }

  int _columnsForWidth(double width) {
    if (width >= 1800) return 8;
    if (width >= 1500) return 7;
    if (width >= 1200) return 6;
    if (width >= 900) return 5;
    return 4;
  }
}

class _AssetTile extends StatelessWidget {
  final StorageAsset asset;

  const _AssetTile({required this.asset});

  @override
  Widget build(BuildContext context) {
    final title = asset.title ?? 'Untitled';
    final imageUrl = asset.publicUrl ??
        '${asset.metadata['public_url'] ?? asset.metadata['image_url'] ?? ''}'.trim();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: imageUrl.isEmpty
                ? _Placeholder(title: title)
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _Placeholder(title: title),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String title;

  const _Placeholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
