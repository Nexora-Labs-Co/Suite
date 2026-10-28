import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/nexora_app.dart';
import 'github_service.dart';

enum InstallStatus { idle, downloading, installing, done, error }

class InstallResult {
  const InstallResult({required this.ok, this.message, this.path});
  final bool ok;
  final String? message;
  final String? path;
}

class InstallerService {
  InstallerService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<InstallResult> install(NexoraApp app, GithubRelease release) async {
    final asset = release.assetForPlatform();
    if (asset == null) {
      return const InstallResult(ok: false, message: 'No compatible asset found.');
    }

    try {
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, asset.name));
      final req = http.Request('GET', Uri.parse(asset.downloadUrl));
      final res = await _client.send(req);
      if (res.statusCode != 200) {
        return InstallResult(ok: false, message: 'Download failed (${res.statusCode}).');
      }
      final sink = file.openWrite();
      await res.stream.pipe(sink);
      await sink.close();

      if (Platform.isLinux) {
        return await _installLinux(file);
      }
      if (Platform.isWindows) {
        return await _installWindows(file);
      }
      return const InstallResult(ok: false, message: 'Unsupported platform.');
    } catch (e) {
      return InstallResult(ok: false, message: e.toString());
    }
  }

  Future<InstallResult> _installLinux(File file) async {
    final name = file.path.toLowerCase();
    if (name.endsWith('.deb')) {
      final result = await Process.run('pkexec', ['dpkg', '-i', file.path]);
      if (result.exitCode == 0) {
        return InstallResult(ok: true, path: file.path, message: 'Installed via dpkg.');
      }
      return InstallResult(
        ok: false,
        message: 'dpkg failed: ${result.stderr}'.trim(),
      );
    }
    // AppImage / binary: place in ~/.local/bin
    final home = Platform.environment['HOME'];
    if (home == null) {
      return const InstallResult(ok: false, message: 'HOME not set.');
    }
    final binDir = Directory('$home/.local/bin');
    if (!binDir.existsSync()) binDir.createSync(recursive: true);
    final target = File('${binDir.path}/${p.basename(file.path)}');
    await file.copy(target.path);
    await Process.run('chmod', ['+x', target.path]);
    return InstallResult(ok: true, path: target.path, message: 'Installed to ${target.path}.');
  }

  Future<InstallResult> _installWindows(File file) async {
    final name = file.path.toLowerCase();
    if (name.endsWith('.msi')) {
      final result = await Process.run('msiexec', ['/i', file.path, '/qn']);
      return result.exitCode == 0
          ? InstallResult(ok: true, path: file.path, message: 'Installed via msiexec.')
          : InstallResult(ok: false, message: '${result.stderr}'.trim());
    }
    // .exe installer: run silently with common flags
    final result = await Process.run(file.path, ['/S', '/silent', '/VERYSILENT']);
    return result.exitCode == 0
        ? InstallResult(ok: true, path: file.path, message: 'Installer finished.')
        : InstallResult(ok: false, message: 'Installer failed: ${result.stderr}'.trim());
  }

  void dispose() => _client.close();
}
