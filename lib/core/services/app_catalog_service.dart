import 'dart:io';

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

      // Detect installed version dynamically.
      if (detected) {
        final v = await _detectInstalledVersion(app);
        if (v != null && v.isNotEmpty) {
          next = next.copyWith(installedVersion: v);
        }
      }

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

  Future<String?> _detectInstalledVersion(NexoraApp app) async {
    if (app.executable == null) return app.installedVersion;
    try {
      if (Platform.isLinux) {
        // Try dpkg (for .deb packages).
        final pkg = app.executable!;
        final r = await Process.run('dpkg-query', ['-W', '-f=\${Version}', pkg]);
        if (r.exitCode == 0) {
          final v = (r.stdout as String).trim();
          if (v.isNotEmpty) return v;
        }
        // Fallback: rpm.
        final r2 = await Process.run('rpm', ['-q', '--qf', '%{VERSION}', pkg]);
        if (r2.exitCode == 0) {
          final v = (r2.stdout as String).trim();
          if (v.isNotEmpty && v != '(none)') return v;
        }
      } else if (Platform.isWindows) {
        // Try PowerShell file version.
        final ps = '(Get-Item (Get-Command ${app.executable}).Source).VersionInfo.FileVersion';
        final r = await Process.run('powershell', ['-NoProfile', '-Command', ps]);
        if (r.exitCode == 0) {
          final v = (r.stdout as String).trim();
          if (v.isNotEmpty) return v;
        }
      }
    } catch (_) {}
    return app.installedVersion;
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
