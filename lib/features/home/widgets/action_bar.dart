import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart' as kit;

import '../../../core/theme/app_theme.dart';
import '../../../core/models/nexora_app.dart';

class NexoraActionBar extends StatelessWidget {
  const NexoraActionBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.onRefresh,
    required this.isRefreshing,
    this.hasPendingUpdates = false,
    this.onInstallAll,
  });

  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final AppViewMode viewMode;
  final ValueChanged<AppViewMode> onViewModeChanged;
  final VoidCallback onRefresh;
  final bool isRefreshing;
  final bool hasPendingUpdates;
  final VoidCallback? onInstallAll;

  static const double _height = 40;
  static const double _radius = 8;

  @override
  Widget build(BuildContext context) {
    return kit.NexoraActionBar(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      left: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isRefreshing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  iconSize: 18,
                  padding: const EdgeInsets.all(8),
                  icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
                  color: NexoraColors.foreground,
                  onPressed: isRefreshing ? null : onRefresh,
                ),
          if (hasPendingUpdates && onInstallAll != null) ...[
            const SizedBox(width: 8),
            SizedBox(
              height: _height,
              child: ElevatedButton.icon(
                onPressed: onInstallAll,
                icon: const FaIcon(FontAwesomeIcons.download, size: 13),
                label: const Text('Instalar todo'),
              ),
            ),
          ],
        ],
      ),
      center: SizedBox(
        height: _height,
        child: TextField(
          onChanged: onSearchChanged,
          style: const TextStyle(fontSize: 13, color: NexoraColors.foreground),
          decoration: InputDecoration(
            hintText: 'Buscar aplicaciones...',
            prefixIcon: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.search, size: 18, color: NexoraColors.muted),
            ),
            isDense: true,
            filled: true,
            fillColor: NexoraColors.surfaceAlt,
            hintStyle: TextStyle(color: NexoraColors.muted, fontSize: 13),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: NexoraColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: NexoraColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: NexoraColors.foreground),
            ),
          ),
        ),
      ),
      right: _ViewToggle(
        height: _height,
        radius: _radius,
        value: viewMode,
        onChanged: onViewModeChanged,
      ),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({
    required this.height,
    required this.radius,
    required this.isRefreshing,
    required this.onPressed,
  });

  final double height;
  final double radius;
  final bool isRefreshing;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: height,
      height: height,
      decoration: BoxDecoration(
        color: NexoraColors.surfaceAlt,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: NexoraColors.border),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Center(
          child: isRefreshing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const FaIcon(
                  FontAwesomeIcons.arrowsRotate,
                  size: 14,
                  color: NexoraColors.foreground,
                ),
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({
    required this.height,
    required this.radius,
    required this.value,
    required this.onChanged,
  });

  final double height;
  final double radius;
  final AppViewMode value;
  final ValueChanged<AppViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: NexoraColors.surfaceAlt,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: NexoraColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            height: height,
            radius: radius,
            icon: FontAwesomeIcons.tableCells,
            selected: value == AppViewMode.grid,
            onTap: () => onChanged(AppViewMode.grid),
          ),
          _ToggleButton(
            height: height,
            radius: radius,
            icon: FontAwesomeIcons.list,
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
    required this.height,
    required this.radius,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final double height;
  final double radius;
  final FaIconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: height,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? NexoraColors.surfaceHover : Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: FaIcon(
          icon,
          size: 14,
          color: selected ? NexoraColors.foreground : NexoraColors.muted,
        ),
      ),
    );
  }
}
