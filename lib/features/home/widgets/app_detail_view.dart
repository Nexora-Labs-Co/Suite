import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/nexora_app.dart';
import '../../../core/theme/app_theme.dart';

class AppDetailView extends StatefulWidget {
  const AppDetailView({
    super.key,
    required this.app,
    required this.onOpen,
    required this.onInstall,
    required this.onRefresh,
  });

  final NexoraApp app;
  final VoidCallback onOpen;
  final VoidCallback onInstall;
  final VoidCallback onRefresh;

  @override
  State<AppDetailView> createState() => _AppDetailViewState();
}

class _AppDetailViewState extends State<AppDetailView> {
  bool _expanded = false;

  List<String> get _changes {
    final body = widget.app.latestReleaseBody;
    if (body == null || body.trim().isEmpty) return const [];
    final lines = body.split('\n');
    final out = <String>[];
    for (final raw in lines) {
      final line = raw.trim();
      if (line.startsWith('- ') || line.startsWith('* ')) {
        out.add(line.substring(2).trim());
      } else if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        out.add(line.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim());
      }
    }
    return out;
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '—';
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(0)} MB';
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final changes = _changes;
    final visibleChanges = _expanded || changes.length <= 6
        ? changes
        : changes.take(6).toList();

    final primaryLabel = app.installed
        ? (app.hasUpdate
              ? 'ACTUALIZAR A ${app.latestVersion ?? ''}'.trim()
              : 'ABRIR')
        : 'INSTALAR';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: NexoraColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: NexoraColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: app.iconAsset != null
                      ? Image.asset(
                          app.iconAsset!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.apps,
                            color: NexoraColors.muted,
                            size: 48,
                          ),
                        )
                      : Icon(Icons.apps, color: NexoraColors.muted, size: 48),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Gliker',
                        color: NexoraColors.foreground,
                        fontWeight: FontWeight.w700,
                        fontSize: 26,
                      ),
                    ),
                    if (app.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        app.subtitle!,
                        style: TextStyle(
                          color: NexoraColors.muted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      app.hasUpdate
                          ? '${app.installedVersion ?? '—'}'
                                '  ->  ${app.latestVersion ?? '—'} released'
                                '  ·  ${_formatDate(app.lastUpdated)}'
                          : '${app.installed ? (app.installedVersion ?? app.latestVersion ?? '—') : (app.latestVersion ?? '—')}'
                                '  ·  ${_formatDate(app.lastUpdated)}',
                      style: TextStyle(
                        color: NexoraColors.mutedStrong,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: app.installed
                        ? (app.hasUpdate ? widget.onInstall : widget.onOpen)
                        : widget.onInstall,
                    child: Text(primaryLabel),
                  ),
                  const SizedBox(height: 6),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_horiz,
                      color: NexoraColors.mutedStrong,
                    ),
                    onSelected: (v) {
                      if (v == 'refresh') widget.onRefresh();
                      if (v == 'github') _openUrl(app.resolvedGithubUrl);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'refresh',
                        child: Text('Comprobar actualizaciones'),
                      ),
                      PopupMenuItem(
                        value: 'github',
                        child: Text('Ver en GitHub'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 24),

          // Metadata cards
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetaCard(label: 'VERSION', value: app.latestVersion ?? '—'),
              _MetaCard(label: 'RELEASED', value: _formatDate(app.lastUpdated)),
              _MetaCard(
                label: 'DOWNLOAD',
                value: _formatBytes(app.latestReleaseSize ?? 0),
              ),
              _MetaCard(label: 'PLATFORMS', value: app.platforms),
            ],
          ),
          const SizedBox(height: 24),

          // Changelog
          Text(
            '¿Que Cambio?',
            style: const TextStyle(
              color: NexoraColors.foreground,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          if (changes.isEmpty)
            Text(
              'Sin notas de versión.',
              style: TextStyle(color: NexoraColors.muted, fontSize: 13),
            )
          else ...[
            for (final c in visibleChanges)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '•  ',
                      style: TextStyle(color: NexoraColors.mutedStrong),
                    ),
                    Expanded(
                      child: Text(
                        c,
                        style: TextStyle(
                          color: NexoraColors.foreground,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (changes.length > 6)
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? 'Show less' : 'Show more changes',
                  style: TextStyle(color: NexoraColors.mutedStrong),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NexoraColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexoraColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: NexoraColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: NexoraColors.foreground,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
