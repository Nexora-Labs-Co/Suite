import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// One-time startup maintenance: purge stale installer payloads and refresh
/// cached assets, while preserving user data and settings.
class StartupCleanup {
  StartupCleanup._();

  static const _installerExtensions = <String>{
    '.deb',
    '.rpm',
    '.appimage',
    '.exe',
    '.msi',
    '.zip',
    '.tar',
    '.tar.gz',
    '.tgz',
  };

  /// Runs cleanup and memory tuning. Safe to call before [runApp].
  static Future<void> run() async {
    // Tune image cache to keep the desktop footprint within 100-150 MB.
    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSize = 100;
    cache.maximumSizeBytes = 50 * 1024 * 1024;

    // Drop stale decoded images so freshly bundled assets are re-indexed.
    cache.clear();
    cache.clearLiveImages();

    // Purge legacy update archives / installer payloads from the temp dir.
    // User data, preferences and state databases live in the app support
    // directory and are intentionally left untouched.
    try {
      final temp = await getTemporaryDirectory();
      if (temp.existsSync()) {
        for (final entity in temp.listSync(followLinks: false)) {
          if (entity is! File) continue;
          final name = p.basename(entity.path).toLowerCase();
          if (_installerExtensions.any(name.endsWith)) {
            try {
              entity.deleteSync();
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
  }
}