import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/nexora_app.dart';
import '../../../core/theme/app_theme.dart';

class NexoraAppCard extends StatelessWidget {
  const NexoraAppCard({
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
    final version = app.installed
        ? (app.installedVersion ?? app.latestVersion)
        : app.latestVersion;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NexoraColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexoraColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera: versión y enlace a GitHub
                  Row(
                    children: [
                      Text(
                        version != null ? 'v$version' : '—',
                        style: const TextStyle(
                          color: NexoraColors.mutedStrong,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _openUrl(app.resolvedGithubUrl),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'GITHUB ↗',
                          style: TextStyle(
                            color: NexoraColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Sección media: icono + nombre + subtítulo
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: NexoraColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: NexoraColors.border),
                        ),
                        child: Text(
                          app.name.isNotEmpty ? app.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: NexoraColors.foreground,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.name,
                              style: const TextStyle(
                                color: NexoraColors.foreground,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (app.subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                app.subtitle!,
                                style: const TextStyle(
                                  color: NexoraColors.muted,
                                  fontSize: 11.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    app.description,
                    style: const TextStyle(
                      color: NexoraColors.mutedStrong,
                      fontSize: 12,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (app.lastUpdated != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Última actualización: ${_formatDate(app.lastUpdated!)}',
                      style: const TextStyle(
                        color: NexoraColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  if (app.hasUpdate) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Actualización disponible: v${app.latestVersion}',
                      style: const TextStyle(
                        color: NexoraColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Sección inferior: botón principal + opciones
          Row(
            children: [
              Expanded(
                child: _primaryButton(),
              ),
              const SizedBox(width: 8),
              _optionsButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _primaryButton() {
    if (app.installed) {
      if (app.hasUpdate) {
        return ElevatedButton(
          onPressed: onInstall,
          child: const Text('ACTUALIZAR'),
        );
      }
      return ElevatedButton(
        onPressed: onOpen,
        child: const Text('ABRIR'),
      );
    }
    return OutlinedButton(
      onPressed: onInstall,
      child: const Text('INSTALAR'),
    );
  }

  Widget _optionsButton(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: NexoraColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: NexoraColors.border),
      ),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_horiz, size: 18, color: NexoraColors.muted),
        onSelected: (v) => _handleMenu(v, context),
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'refresh', child: Text('Comprobar actualizaciones')),
          const PopupMenuItem(value: 'github', child: Text('Ver en GitHub')),
          if (app.installed) ...[
            const PopupMenuItem(value: 'folder', child: Text('Abrir carpeta de instalación')),
            const PopupMenuItem(value: 'reinstall', child: Text('Reinstalar')),
            const PopupMenuItem(value: 'uninstall', child: Text('Desinstalar')),
          ],
        ],
      ),
    );
  }

  void _handleMenu(String value, BuildContext context) {
    switch (value) {
      case 'refresh':
        onRefresh();
        break;
      case 'github':
        _openUrl(app.resolvedGithubUrl);
        break;
      default:
        break;
    }
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
    return '${d.day} de ${months[d.month - 1]}. de ${d.year}';
  }
}
