import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

// Theme modes enum
enum AppThemeMode {
  light('فاتح', Icons.light_mode),
  dark('مظلم', Icons.dark_mode),
  auto('تلقائي', Icons.brightness_auto),
  futuristic('مستقبلي', Icons.rocket_launch),
  neon('نيون', Icons.wb_incandescent),
  ocean('محيطي', Icons.waves);

  const AppThemeMode(this.name, this.icon);
  final String name;
  final IconData icon;
}

// Theme provider state
class ThemeState {
  final AppThemeMode themeMode;
  final bool isDarkMode;
  final Color primaryColor;
  final Color accentColor;

  const ThemeState({
    this.themeMode = AppThemeMode.light,
    this.isDarkMode = false,
    this.primaryColor = AppTheme.primaryColor,
    this.accentColor = AppTheme.accentColor,
  });

  ThemeState copyWith({
    AppThemeMode? themeMode,
    bool? isDarkMode,
    Color? primaryColor,
    Color? accentColor,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}

// Theme provider notifier
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState()) {
    _loadTheme();
  }

  static const String _themeKey = 'app_theme_mode';
  static const String _darkModeKey = 'app_dark_mode';
  static const String _primaryColorKey = 'app_primary_color';
  static const String _accentColorKey = 'app_accent_color';

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final themeModeIndex = prefs.getInt(_themeKey) ?? 0;
      final isDarkMode = prefs.getBool(_darkModeKey) ?? false;
      final primaryColorValue = prefs.getInt(_primaryColorKey) ?? AppTheme.primaryColor.value;
      final accentColorValue = prefs.getInt(_accentColorKey) ?? AppTheme.accentColor.value;

      state = ThemeState(
        themeMode: AppThemeMode.values[themeModeIndex],
        isDarkMode: isDarkMode,
        primaryColor: Color(primaryColorValue),
        accentColor: Color(accentColorValue),
      );
    } catch (e) {
      // Handle error silently and use default theme
      print('Error loading theme: $e');
    }
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeMode.index);

      // Auto set colors based on theme mode
      Color primaryColor = AppTheme.primaryColor;
      Color accentColor = AppTheme.accentColor;
      bool isDarkMode = state.isDarkMode;

      switch (themeMode) {
        case AppThemeMode.dark:
          isDarkMode = true;
          primaryColor = const Color(0xFF2D3748);
          accentColor = const Color(0xFF4A5568);
          break;
        case AppThemeMode.futuristic:
          primaryColor = const Color(0xFF00F5FF);
          accentColor = const Color(0xFFFF6B35);
          break;
        case AppThemeMode.neon:
          primaryColor = const Color(0xFFFF0080);
          accentColor = const Color(0xFF00FF80);
          break;
        case AppThemeMode.ocean:
          primaryColor = const Color(0xFF006994);
          accentColor = const Color(0xFF4ECDC4);
          break;
        case AppThemeMode.light:
          isDarkMode = false;
          primaryColor = AppTheme.primaryColor;
          accentColor = AppTheme.accentColor;
          break;
        case AppThemeMode.auto:
        // Will be handled by the system
          break;
      }

      state = state.copyWith(
        themeMode: themeMode,
        isDarkMode: isDarkMode,
        primaryColor: primaryColor,
        accentColor: accentColor,
      );

      await _saveColors();
    } catch (e) {
      print('Error setting theme mode: $e');
    }
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, isDarkMode);

      state = state.copyWith(isDarkMode: isDarkMode);
    } catch (e) {
      print('Error setting dark mode: $e');
    }
  }

  Future<void> setPrimaryColor(Color color) async {
    try {
      state = state.copyWith(primaryColor: color);
      await _saveColors();
    } catch (e) {
      print('Error setting primary color: $e');
    }
  }

  Future<void> setAccentColor(Color color) async {
    try {
      state = state.copyWith(accentColor: color);
      await _saveColors();
    } catch (e) {
      print('Error setting accent color: $e');
    }
  }

  Future<void> _saveColors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_primaryColorKey, state.primaryColor.value);
      await prefs.setInt(_accentColorKey, state.accentColor.value);
    } catch (e) {
      print('Error saving colors: $e');
    }
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Cairo',
      colorScheme: ColorScheme.fromSeed(
        seedColor: state.primaryColor,
        brightness: Brightness.light,
      ),
      primaryColor: state.primaryColor,
      cardTheme: AppTheme.lightTheme.cardTheme,
      elevatedButtonTheme: AppTheme.lightTheme.elevatedButtonTheme,
      inputDecorationTheme: AppTheme.lightTheme.inputDecorationTheme,
      textTheme: AppTheme.lightTheme.textTheme,
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Cairo',
      colorScheme: ColorScheme.fromSeed(
        seedColor: state.primaryColor,
        brightness: Brightness.dark,
      ),
      primaryColor: state.primaryColor,
      scaffoldBackgroundColor: const Color(0xFF1A202C),
      cardTheme: CardTheme(
        color: const Color(0xFF2D3748),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void resetToDefault() {
    state = const ThemeState();
    _saveTheme();
  }

  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, state.themeMode.index);
      await prefs.setBool(_darkModeKey, state.isDarkMode);
      await _saveColors();
    } catch (e) {
      print('Error saving theme: $e');
    }
  }
}

// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

// Current theme data provider
final currentThemeProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(themeProvider);
  final themeNotifier = ref.read(themeProvider.notifier);

  switch (themeState.themeMode) {
    case AppThemeMode.dark:
      return themeNotifier.darkTheme;
    case AppThemeMode.auto:
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark
          ? themeNotifier.darkTheme
          : themeNotifier.lightTheme;
    default:
      return themeNotifier.lightTheme;
  }
});

// Custom colors provider for futuristic theme
final customColorsProvider = Provider<Map<String, Color>>((ref) {
  final themeState = ref.watch(themeProvider);

  switch (themeState.themeMode) {
    case AppThemeMode.futuristic:
      return {
        'primary': const Color(0xFF00F5FF),
        'accent': const Color(0xFFFF6B35),
        'background': const Color(0xFF0A0A0A),
        'surface': const Color(0xFF1A1A2E),
        'textPrimary': const Color(0xFFFFFFFF),
        'textSecondary': const Color(0xFFB0B0B0),
      };
    case AppThemeMode.neon:
      return {
        'primary': const Color(0xFFFF0080),
        'accent': const Color(0xFF00FF80),
        'background': const Color(0xFF000000),
        'surface': const Color(0xFF1A0A1A),
        'textPrimary': const Color(0xFFFFFFFF),
        'textSecondary': const Color(0xFFFF80C0),
      };
    case AppThemeMode.ocean:
      return {
        'primary': const Color(0xFF006994),
        'accent': const Color(0xFF4ECDC4),
        'background': const Color(0xFF0A1A2A),
        'surface': const Color(0xFF1A2A3A),
        'textPrimary': const Color(0xFFFFFFFF),
        'textSecondary': const Color(0xFF80C0E0),
      };
    default:
      return {
        'primary': themeState.primaryColor,
        'accent': themeState.accentColor,
        'background': AppTheme.backgroundColor,
        'surface': AppTheme.surfaceColor,
        'textPrimary': AppTheme.textPrimary,
        'textSecondary': AppTheme.textSecondary,
      };
  }
});
