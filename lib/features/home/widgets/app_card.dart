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
    this.compact = false,
  });

  final NexoraApp app;
  final VoidCallback onOpen;
  final VoidCallback onInstall;
  final VoidCallback onRefresh;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NexoraColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexoraColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AppIcon(app: app),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name,
                      style: const TextStyle(
                        color: NexoraColors.foreground,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app.installed
                          ? 'v${app.installedVersion ?? '-'}'
                          : 'Not installed',
                      style: TextStyle(
                        color: app.installed
                            ? NexoraColors.mutedStrong
                            : NexoraColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    if (app.hasUpdate) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Update available: v${app.latestVersion}',
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
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz, size: 18, color: NexoraColors.muted),
                onSelected: (v) => _handleMenu(v, context),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'refresh', child: Text('Check updates')),
                  const PopupMenuItem(value: 'github', child: Text('View on GitHub')),
                  if (app.installed) ...[
                    const PopupMenuItem(value: 'folder', child: Text('Open install folder')),
                    const PopupMenuItem(value: 'reinstall', child: Text('Reinstall')),
                    const PopupMenuItem(value: 'uninstall', child: Text('Uninstall')),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            app.description,
            style: const TextStyle(
              color: NexoraColors.mutedStrong,
              fontSize: 12.5,
              height: 1.35,
            ),
            maxLines: compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _MetaLink(
                icon: Icons.link,
                label: 'GitHub',
                onTap: () => _openUrl(app.resolvedGithubUrl),
              ),
              if (app.lastUpdated != null)
                _MetaText(
                  icon: Icons.update,
                  label: 'Updated ${_formatDate(app.lastUpdated!)}',
                ),
              if (app.latestVersion != null)
                _MetaText(
                  icon: Icons.new_releases_outlined,
                  label: 'Latest ${app.latestVersion}',
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (app.installed) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Open'),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onInstall,
                    icon: const Icon(Icons.download_outlined, size: 16),
                    label: const Text('Available to Install'),
                  ),
                ),
              ],
            ],
          ),
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
        // Other actions are no-ops in the base scaffold.
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
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inDays < 1) return 'today';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

class _AppIcon extends StatelessWidget {
  const _AppIcon({required this.app});

  final NexoraApp app;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
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
    );
  }
}

class _MetaLink extends StatelessWidget {
  const _MetaLink({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: NexoraColors.muted),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: NexoraColors.muted,
              fontSize: 11.5,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: NexoraColors.muted),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: NexoraColors.muted, fontSize: 11.5),
        ),
      ],
    );
  }
}
