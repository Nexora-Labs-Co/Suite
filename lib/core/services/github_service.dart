import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class GithubAsset {
  const GithubAsset({
    required this.name,
    required this.downloadUrl,
    required this.size,
  });

  final String name;
  final String downloadUrl;
  final int size;
}

class GithubRelease {
  const GithubRelease({
    required this.tagName,
    required this.name,
    required this.publishedAt,
    required this.htmlUrl,
    required this.assets,
    this.body,
  });

  final String tagName;
  final String name;
  final DateTime? publishedAt;
  final String htmlUrl;
  final List<GithubAsset> assets;
  final String? body;

  int get totalSize => assets.fold<int>(0, (s, a) => s + a.size);

  String get version => tagName.replaceFirst(RegExp(r'^v'), '');

  /// Best asset for the current platform.
  GithubAsset? assetForPlatform() {
    String? pick;
    if (Platform.isLinux) {
      // prefer .deb, then appimage, then raw binary
      pick = _firstMatching(['.deb', '.appimage']);
      if (pick == null) {
        for (final a in assets) {
          if (!a.name.toLowerCase().endsWith('.sha256')) {
            pick = a.name;
            break;
          }
        }
      }
    } else if (Platform.isWindows) {
      pick = _firstMatching(['.exe', '.msi', '.zip']);
    }
    if (pick == null) return null;
    return assets.firstWhere((a) => a.name == pick);
  }

  String? _firstMatching(List<String> exts) {
    for (final ext in exts) {
      for (final a in assets) {
        if (a.name.toLowerCase().endsWith(ext)) return a.name;
      }
    }
    return null;
  }
}

class GithubService {
  GithubService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _base = 'https://api.github.com';

  Future<GithubRelease?> fetchLatestRelease(String repo) async {
    final uri = Uri.parse('$_base/repos/$repo/releases/latest');
    try {
      final res = await _client.get(
        uri,
        headers: const {
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'Nexora-Launcher',
          'X-GitHub-Api-Version': '2022-11-28',
        },
      );
      if (res.statusCode != 200) return null;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final assets = (json['assets'] as List<dynamic>? ?? [])
          .map((a) => GithubAsset(
                name: a['name'] as String,
                downloadUrl: a['browser_download_url'] as String,
                size: (a['size'] as num?)?.toInt() ?? 0,
              ))
          .toList();
      return GithubRelease(
        tagName: json['tag_name'] as String? ?? '',
        name: json['name'] as String? ?? '',
        publishedAt: json['published_at'] != null
            ? DateTime.tryParse(json['published_at'] as String)
            : null,
        htmlUrl: json['html_url'] as String? ?? '',
        assets: assets,
        body: json['body'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  void dispose() => _client.close();
}
