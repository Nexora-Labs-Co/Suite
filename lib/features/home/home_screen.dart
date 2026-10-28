import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/models/nexora_app.dart';
import '../../core/services/app_catalog_service.dart';
import '../../core/services/installer_service.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/action_bar.dart';
import 'widgets/app_card.dart';
import 'widgets/footer.dart';
import 'widgets/section_header.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart' hide NexoraColors;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WindowListener {
  final AppCatalogService _catalog = AppCatalogService();
  final InstallerService _installer = InstallerService();

  List<NexoraApp> _apps = const [];
  bool _loading = true;
  bool _refreshing = false;
  String _search = '';
  final SortMode _sort = SortMode.nameAsc;
  AppViewMode _view = AppViewMode.grid;
  String _syncStatus = 'Nunca comprobado';

  bool _maximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _syncMaximized();
    _load();
  }

  Future<void> _syncMaximized() async {
    final m = await windowManager.isMaximized();
    if (mounted) setState(() => _maximized = m);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _catalog.dispose();
    _installer.dispose();
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    setState(() => _maximized = true);
  }

  @override
  void onWindowUnmaximize() {
    setState(() => _maximized = false);
  }

  @override
  void onWindowRestore() {
    _syncMaximized();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final apps = await _catalog.load();
    if (!mounted) return;
    setState(() {
      _apps = apps;
      _loading = false;
      _syncStatus = 'Comprobado ahora mismo';
    });
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    final updated = <NexoraApp>[];
    for (final app in _apps) {
      final r = await _catalog.refreshOne(app);
      updated.add(r ?? app);
    }
    if (!mounted) return;
    setState(() {
      _apps = updated;
      _refreshing = false;
      _syncStatus = 'Comprobado ahora mismo';
    });
  }

  List<NexoraApp> get _filtered {
    final q = _search.trim().toLowerCase();
    var list = _apps.where((a) {
      if (q.isEmpty) return true;
      return a.name.toLowerCase().contains(q) ||
          a.description.toLowerCase().contains(q);
    }).toList();

    switch (_sort) {
      case SortMode.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortMode.lastUpdated:
        list.sort((a, b) {
          final da = a.lastUpdated ?? DateTime.fromMillisecondsSinceEpoch(0);
          final db = b.lastUpdated ?? DateTime.fromMillisecondsSinceEpoch(0);
          return db.compareTo(da);
        });
        break;
      case SortMode.status:
        list.sort((a, b) {
          // installed first
          if (a.installed != b.installed) return a.installed ? -1 : 1;
          return a.name.compareTo(b.name);
        });
        break;
    }
    return list;
  }

  List<NexoraApp> get _installed =>
      _filtered.where((a) => a.installed).toList();
  List<NexoraApp> get _notInstalled =>
      _filtered.where((a) => !a.installed).toList();

  void _updateApp(NexoraApp updated) {
    setState(() {
      _apps = _apps.map((a) => a.id == updated.id ? updated : a).toList();
    });
  }

  Future<void> _openApp(NexoraApp app) async {
    if (app.executable == null) return;
    try {
      await Process.start(app.executable!, const [], runInShell: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir ${app.name}: $e')),
      );
    }
  }

  Future<void> _installApp(NexoraApp app) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text('Obteniendo versión de ${app.name}...')),
    );

    final release = await _catalog.fetchRelease(app.repo);
    if (release == null) {
      messenger.showSnackBar(
        SnackBar(content: Text('No se encontró una versión para ${app.name}.')),
      );
      return;
    }

    final refreshed = app.copyWith(
      latestVersion: release.version,
      lastUpdated: release.publishedAt,
    );
    _updateApp(refreshed);

    messenger.showSnackBar(
      SnackBar(content: Text('Instalando ${app.name} ${release.version}...')),
    );

    final result = await _installer.install(refreshed, release);
    if (!mounted) return;
    if (result.ok) {
      final installed = refreshed.copyWith(
        installed: true,
        installedVersion: release.version,
      );
      _updateApp(installed);
      messenger.showSnackBar(
        SnackBar(content: Text('${app.name} instalado: ${result.message}')),
      );

      // Self-update: restart the launcher after installing the new version.
      if (app.id == 'nexora_launcher') {
        await Future.delayed(const Duration(seconds: 2));
        try {
          await Process.start(
            app.executable ?? 'nexora-suite',
            const [],
            runInShell: true,
          );
        } catch (_) {}
        exit(0);
      }
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text('Error al instalar: ${result.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = _maximized ? 0.0 : 14.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Scaffold(
        body: Column(
          children: [
            const NexoraWindowHeader(subtitle: 'SUITE'),
            NexoraActionBar(
              searchQuery: _search,
              onSearchChanged: (v) => setState(() => _search = v),
              viewMode: _view,
              onViewModeChanged: (v) => setState(() => _view = v),
              onRefresh: _refreshing ? () {} : _refresh,
              isRefreshing: _refreshing,
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContent(),
            ),
            NexoraFooter(syncStatus: _syncStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final installed = _installed;
    final notInstalled = _notInstalled;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGrid(installed, installedSection: true),
          if (notInstalled.isNotEmpty)
            SectionHeader(
              title: 'No instaladas',
              subtitle: '${notInstalled.length} disponibles',
            ),
          _buildGrid(notInstalled, installedSection: false),
          if (installed.isEmpty && notInstalled.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'No hay aplicaciones que coincidan con tu búsqueda.',
                  style: TextStyle(color: NexoraColors.muted),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<NexoraApp> apps, {required bool installedSection}) {
    if (apps.isEmpty) {
      return const SizedBox.shrink();
    }
    if (_view == AppViewMode.list) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        itemCount: apps.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) => NexoraAppCard(
          app: apps[i],
          onOpen: () => _openApp(apps[i]),
          onInstall: () => _installApp(apps[i]),
          onRefresh: () => _refresh(),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final width = constraints.maxWidth;
          final cross = width > 900 ? 4 : (width > 600 ? 3 : 2);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 200,
            ),
            itemCount: apps.length,
            itemBuilder: (ctx, i) => NexoraAppCard(
              app: apps[i],
              onOpen: () => _openApp(apps[i]),
              onInstall: () => _installApp(apps[i]),
              onRefresh: () => _refresh(),
            ),
          );
        },
      ),
    );
  }
}
