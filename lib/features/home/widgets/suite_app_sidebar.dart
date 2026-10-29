import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/models/nexora_app.dart';
import '../../../core/theme/app_theme.dart';

/// Sidebar listing every ecosystem app as square icon cards,
/// mirroring Harmony's sidebar grid (single column).
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
      return const Center(
        child: Text(
          'Sin resultados',
          style: TextStyle(color: NexoraColors.muted, fontSize: 12),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final app = list[index];
              return _gridTile(
                assetPath: app.iconAsset,
                selected: app.id == selectedId,
                onTap: () => onSelected(app.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _gridTile({
    String? assetPath,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, selected ? -3 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: NexoraColors.surface,
              border: Border.all(color: NexoraColors.border),
            ),
            child: assetPath != null
                ? SizedBox.expand(
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: FaIcon(FontAwesomeIcons.image,
                            color: NexoraColors.muted),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}