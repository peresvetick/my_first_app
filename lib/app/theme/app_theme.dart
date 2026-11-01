import 'package:flutter/material.dart';

/// Цвета и тема NatureHub: лесной зелёный + янтарный акцент.
class AppColors {
  static const forest = Color(0xFF1B5E3B);
  static const forestMid = Color(0xFF2E7D4F);
  static const forestLight = Color(0xFF4CAF6A);
  static const amber = Color(0xFFD4A017);
  static const amberSoft = Color(0xFFF0C75E);
  static const mist = Color(0xFFF2F5F1);
  static const mistDark = Color(0xFF121A16);
  static const cardDark = Color(0xFF1E2A24);
  static const ink = Color(0xFF1A2E22);
  static const muted = Color(0xFF5C6B62);

  static const officialGradient = [Color(0xFF1B5E3B), Color(0xFF3D8B5E)];
  static const folkGradient = [Color(0xFFB45309), Color(0xFFD97706)];
}

class AppRadii {
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 28.0;
}

class AppShadows {
  static List<BoxShadow> soft(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.35 : 0.08),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ];
  }
}

/// Ключи пресетов оформления.
const kThemePresets = ['forest', 'mountains', 'ocean', 'space', 'minimal'];

const kThemePresetLabels = {
  'forest': 'Лес',
  'mountains': 'Горы',
  'ocean': 'Океан',
  'space': 'Космос',
  'minimal': 'Минимализм',
};

Color _seedForPreset(String preset) {
  switch (preset) {
    case 'mountains':
      return const Color(0xFF5D4037);
    case 'ocean':
      return const Color(0xFF0277BD);
    case 'space':
      return const Color(0xFF6A1B9A);
    case 'minimal':
      return const Color(0xFF607D8B);
    case 'forest':
    default:
      return AppColors.forest;
  }
}

ThemeData buildNatureLightTheme({String preset = 'forest'}) =>
    buildThemeForPreset(preset, dark: false);

ThemeData buildNatureDarkTheme({String preset = 'forest'}) =>
    buildThemeForPreset(preset, dark: true);

/// Тема по пресету и режиму яркости.
ThemeData buildThemeForPreset(String preset, {required bool dark}) {
  final seed = _seedForPreset(preset);
  final secondary = preset == 'ocean'
      ? const Color(0xFF26C6DA)
      : (preset == 'space' ? const Color(0xFFE040FB) : AppColors.amber);
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: dark ? Brightness.dark : Brightness.light,
    secondary: dark ? secondary.withValues(alpha: 0.9) : secondary,
  );
  final scaffold = dark
      ? (preset == 'space' ? const Color(0xFF0B001F) : AppColors.mistDark)
      : (preset == 'minimal' ? const Color(0xFFF5F5F5) : AppColors.mist);
  final base = ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: scaffold,
  );
  return base.copyWith(
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: dark ? Colors.white : AppColors.ink,
      titleTextStyle: TextStyle(
        color: dark ? Colors.white : AppColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: dark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.sm)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: scheme.primary,
      unselectedItemColor: dark ? Colors.white54 : AppColors.muted,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      backgroundColor: dark ? AppColors.cardDark : Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? AppColors.cardDark : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.sm)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        borderSide: BorderSide(color: scheme.primary.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    ),
  );
}

/// Плавный переход между экранами.
Route<T> natureRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 280),
  );
}
