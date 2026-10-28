import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../../core/theme/app_theme.dart';

class NexoraTitleBar extends StatelessWidget {
  const NexoraTitleBar({
    super.key,
    this.onSettings,
  });

  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      color: NexoraColors.surface,
      child: Row(
        children: [
          Expanded(
            child: DragToMoveArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    _LogoMark(),
                    const SizedBox(width: 10),
                    const Text(
                      'Nexora Suite',
                      style: TextStyle(
                        color: NexoraColors.foreground,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Launcher',
                      style: TextStyle(
                        color: NexoraColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined, size: 18),
            onPressed: onSettings,
          ),
          const SizedBox(width: 4),
          WindowCaptionButton.minimize(
            brightness: Brightness.dark,
            onPressed: () => windowManager.minimize(),
          ),
          WindowCaptionButton.maximize(
            brightness: Brightness.dark,
            onPressed: () async {
              if (await windowManager.isMaximized()) {
                windowManager.unmaximize();
              } else {
                windowManager.maximize();
              }
            },
          ),
          WindowCaptionButton.close(
            brightness: Brightness.dark,
            onPressed: () => windowManager.close(),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: NexoraColors.foreground,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        'N',
        style: TextStyle(
          color: NexoraColors.background,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}
