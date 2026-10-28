import 'package:flutter/material.dart';

import '../../../core/models/nexora_app.dart';
import '../../../core/theme/app_theme.dart';

class NexoraActionBar extends StatelessWidget {
  const NexoraActionBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.sortMode,
    required this.onSortChanged,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.onRefresh,
    required this.isRefreshing,
  });

  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final SortMode sortMode;
  final ValueChanged<SortMode> onSortChanged;
  final AppViewMode viewMode;
  final ValueChanged<AppViewMode> onViewModeChanged;
  final VoidCallback onRefresh;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: NexoraColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Refresh / check updates',
            onPressed: isRefreshing ? null : onRefresh,
            icon: isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, size: 20),
          ),
          const SizedBox(width: 8),
          _SortDropdown(value: sortMode, onChanged: onSortChanged),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search apps...',
                prefixIcon: Icon(Icons.search, size: 18, color: NexoraColors.muted),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _ViewToggle(value: viewMode, onChanged: onViewModeChanged),
        ],
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.value, required this.onChanged});

  final SortMode value;
  final ValueChanged<SortMode> onChanged;

  String _label(SortMode m) {
    switch (m) {
      case SortMode.nameAsc:
        return 'Name A-Z';
      case SortMode.lastUpdated:
        return 'Last updated';
      case SortMode.status:
        return 'Status';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: NexoraColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NexoraColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortMode>(
          value: value,
          dropdownColor: NexoraColors.surfaceAlt,
          style: const TextStyle(color: NexoraColors.foreground, fontSize: 13),
          icon: const Icon(Icons.expand_more, size: 18, color: NexoraColors.muted),
          items: SortMode.values
              .map((m) => DropdownMenuItem(value: m, child: Text(_label(m))))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.value, required this.onChanged});

  final AppViewMode value;
  final ValueChanged<AppViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NexoraColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NexoraColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            icon: Icons.grid_view_rounded,
            selected: value == AppViewMode.grid,
            onTap: () => onChanged(AppViewMode.grid),
          ),
          _ToggleButton(
            icon: Icons.view_list_rounded,
            selected: value == AppViewMode.list,
            onTap: () => onChanged(AppViewMode.list),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? NexoraColors.surfaceHover : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: selected ? NexoraColors.foreground : NexoraColors.muted,
        ),
      ),
    );
  }
}
