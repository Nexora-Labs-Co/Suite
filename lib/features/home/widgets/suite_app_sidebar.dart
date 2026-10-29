import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/models/nexora_app.dart';
import '../../../core/theme/app_theme.dart';

/// Sidebar listing every ecosystem app with selection state.
class SuiteAppSidebar extends StatelessWidget {
  const SuiteAppSidebar({
    super.key,
    required this.apps,
    required this.searchQuery,
    required this.selectedId,
    required this.onSelected,
  });

  final List<NexoraApp> apps;
  final String searchQuery;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  List<NexoraApp> get _filtered {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return apps;
    return apps.where((a) {
      return a.name.toLowerCase().contains(q) ||
          (a.subtitle?.toLowerCase().contains(q) ?? false) ||
          a.description.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Sin resultados',
          style: TextStyle(color: NexoraColors.muted, fontSize: 13),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final app in list)
          _SidebarItem(
            app: app,
            selected: app.id == selectedId,
            onTap: () => onSelected(app.id),
          ),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.app,
    required this.selected,
    required this.onTap,
  });

  final NexoraApp app;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? NexoraColors.surfaceHover : NexoraColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? NexoraColors.foreground : NexoraColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: NexoraColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: NexoraColors.border),
                ),
                child: app.iconAsset != null
                    ? SvgPicture.asset(app.iconAsset!, width: 22, height: 22)
                    : Text(
                        app.name.isNotEmpty ? app.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: NexoraColors.foreground,
                          fontWeight: FontWeight.w700,
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
                      style: TextStyle(
                        color: NexoraColors.foreground,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (app.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        app.subtitle!,
                        style: TextStyle(color: NexoraColors.muted, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (app.installed)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF43A047),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}