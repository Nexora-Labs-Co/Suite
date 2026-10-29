import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/nexora_app.dart';
import '../../../core/theme/app_theme.dart';

/// Main content view showing full details for a selected app.
class AppDetailView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icon + name + tagline
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: NexoraColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: NexoraColors.border),
                ),
                child: app.iconAsset != null
                    ? Image.asset(
                        app.iconAsset!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.contain,
                      )
                    : Text(
                        app.name.isNotEmpty ? app.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: NexoraColors.foreground,
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                        ),
                      ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name,
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
                        style: TextStyle(color: NexoraColors.muted, fontSize: 14),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      app.description,
                      style: TextStyle(
                        color: NexoraColors.mutedStrong,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Version status
          _SectionTitle('Estado de versión'),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Instalada',
            value: app.installed
                ? (app.installedVersion ?? 'Desconocida')
                : 'No instalada',
          ),
          _InfoRow(
            label: 'Última (GitHub)',
            value: app.latestVersion ?? 'Desconocida',
          ),
          if (app.installed && app.hasUpdate)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Hay una actualización disponible.',
                style: TextStyle(
                  color: NexoraColors.mutedStrong,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Legal & licensing
          _SectionTitle('Licencia y legal'),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Licencia',
            value: 'PolyForm Noncommercial License 1.0.0 — Nexora Labs',
          ),
          if (app.homepageUrl != null)
            _InfoRow(label: 'Sitio', value: app.homepageUrl!),
          _InfoRow(label: 'Repositorio', value: app.resolvedGithubUrl),
          const SizedBox(height: 20),

          // Executable / installation status
          _SectionTitle('Instalación en el sistema'),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Ejecutable',
            value: app.executable ?? '—',
          ),
          _InfoRow(
            label: 'Estado',
            value: app.installed ? 'Instalada' : 'No instalada',
          ),
          if (app.lastUpdated != null)
            _InfoRow(
              label: 'Última actualización',
              value: _formatDate(app.lastUpdated!),
            ),
          const SizedBox(height: 24),

          // Primary actions
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (app.installed) ...[
                ElevatedButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('ABRIR'),
                ),
                if (app.hasUpdate)
                  ElevatedButton.icon(
                    onPressed: onInstall,
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('ACTUALIZAR'),
                  ),
              ] else
                OutlinedButton.icon(
                  onPressed: onInstall,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('INSTALAR'),
                ),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Comprobar'),
              ),
              OutlinedButton.icon(
                onPressed: () => _openUrl(app.resolvedGithubUrl),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('GitHub'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: NexoraColors.foreground,
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(color: NexoraColors.muted, fontSize: 12.5),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: NexoraColors.foreground,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}