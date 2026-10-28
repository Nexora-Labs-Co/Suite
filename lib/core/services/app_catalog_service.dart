import 'package:flutter/foundation.dart';

import '../ffi/nexora_core.dart';
import '../models/nexora_app.dart';
import 'github_service.dart';

class AppCatalogService {
  AppCatalogService({
    GithubService? github,
  }) : _github = github ?? GithubService();

  final GithubService _github;

  /// Loads the static catalogue, enriches with GitHub release info and
  /// detects local installation.
  Future<List<NexoraApp>> load() async {
    final apps = List<NexoraApp>.from(kNexoraApps);
    final enriched = <NexoraApp>[];
    for (final app in apps) {
      var next = app;
      // Detect installation.
      final detected = await _isInstalled(app);
      if (detected) next = next.copyWith(installed: true);

      // Fetch latest release (best effort).
      try {
        final release = await _github.fetchLatestRelease(app.repo);
        if (release != null) {
          next = next.copyWith(
            latestVersion: release.version,
            lastUpdated: release.publishedAt,
          );
        }
      } catch (e) {
        debugPrint('GitHub fetch failed for ${app.id}: $e');
      }
      enriched.add(next);
    }
    return enriched;
  }

  Future<bool> _isInstalled(NexoraApp app) async {
    if (app.executable == null) return app.installed;
    try {
      if (NexoraCore.isOnPath(app.executable!)) return true;
    } catch (_) {}
    return app.installed;
  }

  Future<NexoraApp?> refreshOne(NexoraApp app) async {
    final release = await _github.fetchLatestRelease(app.repo);
    if (release == null) return null;
    return app.copyWith(
      latestVersion: release.version,
      lastUpdated: release.publishedAt,
    );
  }

  Future<GithubRelease?> fetchRelease(String repo) =>
      _github.fetchLatestRelease(repo);

  void dispose() => _github.dispose();
}
