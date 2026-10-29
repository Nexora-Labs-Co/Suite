import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart' as kit;

import '../../../core/models/nexora_app.dart';
import '../../../core/theme/app_theme.dart';

class NexoraActionBar extends StatelessWidget {
  const NexoraActionBar({
    super.key,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.onRefresh,
    required this.isRefreshing,
    this.hasPendingUpdates = false,
    this.onInstallAll,
    this.onToggleLeftSidebar,
    this.onToggleRightSidebar,
    this.leftSidebarVisible = true,
    this.rightSidebarVisible = false,
  });

  final AppViewMode viewMode;
  final ValueChanged<AppViewMode> onViewModeChanged;
  final VoidCallback onRefresh;
  final bool isRefreshing;
  final bool hasPendingUpdates;
  final VoidCallback? onInstallAll;
  final VoidCallback? onToggleLeftSidebar;
  final VoidCallback? onToggleRightSidebar;
  final bool leftSidebarVisible;
  final bool rightSidebarVisible;

  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    return kit.NexoraActionBar(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      left: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            iconSize: _iconSize,
            padding: const EdgeInsets.all(8),
            icon: FaIcon(
              leftSidebarVisible
                  ? FontAwesomeIcons.chevronLeft
                  : FontAwesomeIcons.chevronRight,
              color: NexoraColors.foreground,
            ),
            onPressed: onToggleLeftSidebar,
          ),
          isRefreshing
              ? const SizedBox(
                  width: _iconSize,
                  height: _iconSize,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  iconSize: _iconSize,
                  padding: const EdgeInsets.all(8),
                  icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
                  color: NexoraColors.foreground,
                  onPressed: isRefreshing ? null : onRefresh,
                ),
          if (hasPendingUpdates && onInstallAll != null) ...[
            const SizedBox(width: 8),
            SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: onInstallAll,
                icon: const FaIcon(FontAwesomeIcons.download, size: 13),
                label: const Text('Instalar todo'),
              ),
            ),
          ],
        ],
      ),
      center: null,
      right: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            iconSize: _iconSize,
            padding: const EdgeInsets.all(8),
            icon: FaIcon(
              rightSidebarVisible
                  ? FontAwesomeIcons.chevronRight
                  : FontAwesomeIcons.chevronLeft,
              color: NexoraColors.foreground,
            ),
            onPressed: onToggleRightSidebar,
          ),
          IconButton(
            iconSize: _iconSize,
            padding: const EdgeInsets.all(8),
            icon: FaIcon(
              FontAwesomeIcons.user,
              color: NexoraColors.muted,
            ),
            onPressed: null,
          ),
        ],
      ),
    );
  }
}