import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';

class NexoraApp extends StatelessWidget {
  const NexoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexora Suite',
      debugShowCheckedModeBanner: false,
      theme: NexoraTheme.dark(),
      home: const HomeScreen(),
    );
  }
}
