import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      // Se incrementa ligeramente el padding general para darle mayor presencia
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
                  // Cabecera: versión (con indicador de actualización)
                  Row(
                    children: [
                      if (app.installed && app.hasUpdate)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              app.installedVersion ?? '—',
                              style: const TextStyle(
                                color: Color(0xFFE53935),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '->',
                              style: TextStyle(
                                color: NexoraColors.muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              app.latestVersion ?? '—',
                              style: const TextStyle(
                                color: Color(0xFF43A047),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          version ?? '—',
                          style: const TextStyle(
                            color: NexoraColors.mutedStrong,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 10), // Espacio ligeramente mayor
                  // Sección media: icono + nombre + subtítulo
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42, // Icono un poco más grande
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: NexoraColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: NexoraColors.border),
                        ),
                        child: app.iconAsset != null
                            ? SvgPicture.asset(
                                app.iconAsset!,
                                width: 28,
                                height: 28,
                              )
                            : Text(
                                app.name.isNotEmpty
                                    ? app.name[0].toUpperCase()
                                    : '?',
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
                                fontFamily: 'Gliker',
                                color: NexoraColors.foreground,
                                fontWeight: FontWeight.w700,
                                fontSize: 16.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (app.subtitle != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                app.subtitle!,
                                style: const TextStyle(
                                  color: NexoraColors.muted,
                                  fontSize: 12,
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (app.lastUpdated != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Última actualización: ${_formatDate(app.lastUpdated!)}',
                style: const TextStyle(
                  color: NexoraColors.muted,
                  fontSize: 11.5,
                ),
              ),
            ),
          // Sección inferior: botón principal + opciones
          Row(
            children: [
              Expanded(child: _primaryButton()),
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
      return ElevatedButton(onPressed: onOpen, child: const Text('ABRIR'));
    }
    return OutlinedButton(onPressed: onInstall, child: const Text('INSTALAR'));
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
          const PopupMenuItem(
            value: 'refresh',
            child: Text('Comprobar actualizaciones'),
          ),
          const PopupMenuItem(value: 'github', child: Text('Ver en GitHub')),
          if (app.installed) ...[
            const PopupMenuItem(
              value: 'folder',
              child: Text('Abrir carpeta de instalación'),
            ),
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
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${d.day} de ${months[d.month - 1]}. de ${d.year}';
  }
}
