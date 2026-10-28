import 'package:flutter/material.dart';

/// Strictly monochrome palette for Nexora Suite.
class NexoraColors {
  NexoraColors._();

  static const Color background = Color(0xFF090C02);
  static const Color foreground = Color(0xFFEBF5EE);

  static const Color surface = Color(0xFF090C02);
  static const Color surfaceAlt = Color(0xFF1A1A1A);
  static const Color surfaceHover = Color(0xFF2A2A2A);

  static const Color border = Color(0xFF3A3A3A);
  static const Color borderStrong = Color(0xFF6B6B6B);

  static const Color muted = Color(0xFF6B6B6B);
  static const Color mutedStrong = Color(0xFFB0B0B0);

  static const Color danger = Color(0xFFB0B0B0); // kept neutral
  static const Color accent = Color(0xFFA50021);
}

class NexoraTheme {
  NexoraTheme._();

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final scheme = const ColorScheme.dark(
      primary: NexoraColors.foreground,
      onPrimary: NexoraColors.background,
      secondary: NexoraColors.mutedStrong,
      onSecondary: NexoraColors.background,
      surface: NexoraColors.surface,
      onSurface: NexoraColors.foreground,
      error: NexoraColors.foreground,
      onError: NexoraColors.background,
      outline: NexoraColors.border,
      surfaceContainerHighest: NexoraColors.surfaceAlt,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: NexoraColors.background,
      canvasColor: NexoraColors.background,
      dividerColor: NexoraColors.border,
      cardColor: NexoraColors.surface,
      textTheme: base.textTheme.apply(
        bodyColor: NexoraColors.foreground,
        displayColor: NexoraColors.foreground,
        fontFamily: 'monospace',
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: NexoraColors.background,
        foregroundColor: NexoraColors.foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NexoraColors.surfaceAlt,
        hintStyle: const TextStyle(color: NexoraColors.muted),
        labelStyle: const TextStyle(color: NexoraColors.mutedStrong),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: NexoraColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: NexoraColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: NexoraColors.foreground),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NexoraColors.foreground,
          foregroundColor: NexoraColors.background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NexoraColors.foreground,
          side: const BorderSide(color: NexoraColors.borderStrong),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: NexoraColors.foreground,
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: NexoraColors.foreground,
          hoverColor: NexoraColors.surfaceHover,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: NexoraColors.surfaceAlt,
        textStyle: const TextStyle(color: NexoraColors.foreground, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: NexoraColors.border),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: NexoraColors.surfaceAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: NexoraColors.border),
          ),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: NexoraColors.surfaceAlt,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: NexoraColors.border),
        ),
        textStyle: const TextStyle(color: NexoraColors.foreground, fontSize: 12),
      ),
    );
  }
}
