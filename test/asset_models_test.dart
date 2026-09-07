import 'package:flutter_test/flutter_test.dart';

import '../lib/core/asset_models.dart';

void main() {
  test('parses a complete storage asset row', () {
    final asset = StorageAsset.fromRow({
      'id': 'asset-1',
      'dropbox_path': '/SNES/Example.png',
      'asset_type': 'snes_sealed',
      'title': 'Example Game',
      'public_url': 'https://example.test/example.png',
      'metadata': {'width': 1920, 'height': 1080},
      'created_at': '2026-09-01T10:00:00Z',
      'updated_at': '2026-09-02T11:00:00Z',
      'is_test_asset': false,
    });

    expect(asset.id, 'asset-1');
    expect(asset.dropboxPath, '/SNES/Example.png');
    expect(asset.assetType, 'snes_sealed');
    expect(asset.title, 'Example Game');
    expect(asset.publicUrl, 'https://example.test/example.png');
    expect(asset.metadata['width'], 1920);
    expect(asset.isTestAsset, isFalse);
    expect(asset.isPublic, isTrue);
  });

  test('allows nullable title and public URL while preserving metadata', () {
    final asset = StorageAsset.fromRow({
      'id': 'asset-2',
      'dropbox_path': '/private/file.png',
      'asset_type': 'other',
      'title': null,
      'public_url': null,
      'metadata': {},
      'created_at': '2026-09-01T10:00:00Z',
      'updated_at': '2026-09-01T10:00:00Z',
      'is_test_asset': true,
    });

    expect(asset.title, isNull);
    expect(asset.publicUrl, isNull);
    expect(asset.isPublic, isFalse);
    expect(asset.isTestAsset, isTrue);
  });

  test('rejects missing required storage asset fields', () {
    expect(
      () => StorageAsset.fromRow({
        'id': 'asset-1',
        'dropbox_path': '/file.png',
        'asset_type': 'snes_sealed',
      }),
      throwsFormatException,
    );
  });

  test('rejects malformed metadata, dates, and test-asset flag', () {
    final base = {
      'id': 'asset-1',
      'dropbox_path': '/file.png',
      'asset_type': 'snes_sealed',
      'created_at': '2026-09-01T10:00:00Z',
      'updated_at': '2026-09-01T10:00:00Z',
      'is_test_asset': false,
    };

    expect(
      () => StorageAsset.fromRow({...base, 'metadata': 'bad'}),
      throwsFormatException,
    );
    expect(
      () => StorageAsset.fromRow({...base, 'metadata': {}, 'created_at': 'bad'}),
      throwsFormatException,
    );
    expect(
      () => StorageAsset.fromRow({...base, 'metadata': {}, 'is_test_asset': 'false'}),
      throwsFormatException,
    );
  });
}
