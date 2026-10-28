import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';

class NexoraFooter extends StatelessWidget {
  const NexoraFooter({
    super.key,
    required this.syncStatus,
  });

  final String syncStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: NexoraColors.surface,
        border: Border(top: BorderSide(color: NexoraColors.border)),
      ),
      child: Row(
        children: [
          Icon(Icons.sync, size: 13, color: NexoraColors.muted),
          const SizedBox(width: 6),
          Text(
            syncStatus,
            style: const TextStyle(color: NexoraColors.muted, fontSize: 11.5),
          ),
          const Spacer(),
          _FooterLink(label: 'Nexora API', url: 'https://api.nexora.dev'),
          const SizedBox(width: 16),
          _FooterLink(label: 'GitHub', url: 'https://github.com/Nexora-Labs-Co'),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Text(
        label,
        style: const TextStyle(
          color: NexoraColors.mutedStrong,
          fontSize: 11.5,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
