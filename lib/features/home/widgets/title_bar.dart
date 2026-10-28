import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../../core/theme/app_theme.dart';

class NexoraTitleBar extends StatelessWidget {
  const NexoraTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: NexoraColors.surface,
        border: Border(bottom: BorderSide(color: NexoraColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: DragToMoveArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'NEXORA',
                      style: TextStyle(
                        fontFamily: 'Gliker',
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        letterSpacing: 1.2,
                        color: NexoraColors.foreground,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 1,
                      height: 18,
                      color: NexoraColors.borderStrong,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'SUITE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2.0,
                        color: NexoraColors.mutedStrong,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
