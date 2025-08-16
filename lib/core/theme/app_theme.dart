import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Main Colors
  static const Color primaryColor = Color(0xFF7609D0);
  static const Color primaryLightColor = Color(0xFF2E4F73);
  static const Color primaryDarkColor = Color(0xFF0F1E36);

  static const Color secondaryColor = Color(0xFF2E7D9A);
  static const Color secondaryLightColor = Color(0xFF4A96B3);
  static const Color secondaryDarkColor = Color(0xFF1E5F7A);
  
  static const Color accentColor = Color(0xFFFF6B35);
  static const Color accentLightColor = Color(0xFFFF8A5B);
  static const Color accentDarkColor = Color(0xFFE55A2B);
  
  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color successLightColor = Color(0xFF6BBF6F);
  static const Color successDarkColor = Color(0xFF3D8B40);
  
  static const Color warningColor = Color(0xFFFF9800);
  static const Color warningLightColor = Color(0xFFFFAB40);
  static const Color warningDarkColor = Color(0xFFE68900);
  
  static const Color errorColor = Color(0xFFF44336);
  static const Color errorLightColor = Color(0xFFF66356);
  static const Color errorDarkColor = Color(0xFFD32F2F);
  
  static const Color infoColor = Color(0xFF2196F3);
  static const Color infoLightColor = Color(0xFF4FC3F7);
  static const Color infoDarkColor = Color(0xFF1976D2);
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color sheetColor = Color(0xFFFAFAFA);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textHint = Color(0xFFAF9CA0);
  static const Color textDisabled = Color(0xFFC01459);
  static const Color textOnPrimary = Color(0xFF14E0C1);
  static const Color textOnSecondary = Color(0xFF12E0D8);
  
  // Border Colors
  static const Color borderColor = Color(0xFFE9ECEF);
  static const Color borderLightColor = Color(0xFFF8F9FA);
  static const Color borderDarkColor = Color(0xFFCED4DA);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, primaryLightColor],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryColor, secondaryLightColor],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentColor, accentLightColor],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successColor, successLightColor],
  );
  
  // Shadows
  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get heavyShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryColor.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
  ];
  
  // Border Radius
  static const BorderRadius smallRadius = BorderRadius.all(Radius.circular(8));
  static const BorderRadius mediumRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius largeRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius extraLargeRadius = BorderRadius.all(Radius.circular(24));
  
  // Spacing
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double space2XL = 48.0;
  static const double space3XL = 64.0;
  
  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;
  static const double icon2XL = 64.0;
  
  // Font Sizes
  static const double fontXS = 10.0;
  static const double fontSM = 12.0;
  static const double fontMD = 14.0;
  static const double fontLG = 16.0;
  static const double fontXL = 18.0;
  static const double font2XL = 20.0;
  static const double font3XL = 24.0;
  static const double font4XL = 32.0;
  static const double font5XL = 48.0;
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationSlower = Duration(milliseconds: 800);
  
  // Main Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Cairo',
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: textOnPrimary,
        secondary: secondaryColor,
        onSecondary: textOnSecondary,
        surface: surfaceColor,
        onSurface: textPrimary,
        background: backgroundColor,
        onBackground: textPrimary,
        error: errorColor,
        onError: textOnPrimary,
      ),
      
      // Primary Swatch
      primarySwatch: createMaterialColor(primaryColor),
      
      // Scaffold
      scaffoldBackgroundColor: backgroundColor,
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: font2XL,
          fontWeight: FontWeight.w600,
          color: textOnPrimary,
        ),
        iconTheme: IconThemeData(
          color: textOnPrimary,
          size: iconMD,
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: mediumRadius,
        ),
        margin: const EdgeInsets.all(spaceSM),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textOnPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLG,
            vertical: spaceMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: mediumRadius,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: fontLG,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLG,
            vertical: spaceMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: mediumRadius,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: fontLG,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLG,
            vertical: spaceMD,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: fontLG,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: mediumRadius,
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: mediumRadius,
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: mediumRadius,
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: mediumRadius,
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMD,
          vertical: spaceMD,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontMD,
          color: textSecondary,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontMD,
          color: textHint,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: iconMD,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Cairo',
          fontSize: font5XL,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Cairo',
          fontSize: font4XL,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Cairo',
          fontSize: font3XL,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Cairo',
          fontSize: font3XL,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Cairo',
          fontSize: font2XL,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontXL,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontXL,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontLG,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontMD,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontLG,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontMD,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontSM,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontMD,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontSM,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontXS,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontSM,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontSM,
          fontWeight: FontWeight.normal,
        ),
      ),
      
      // Tab Bar Theme
      tabBarTheme: const TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: textSecondary,
        indicatorColor: primaryColor,
        labelStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontMD,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontMD,
          fontWeight: FontWeight.normal,
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: surfaceColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: largeRadius,
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontXL,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontMD,
          color: textPrimary,
        ),
      ),
      
      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontMD,
          color: textOnPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: mediumRadius,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: borderColor,
        circularTrackColor: borderColor,
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return textSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.3);
          }
          return borderColor;
        }),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(textOnPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return textSecondary;
        }),
      ),
    );
  }
  
  // Helper function to create MaterialColor
  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

// Custom Colors Extension
extension CustomColors on ThemeData {
  Color get primaryGradientStart => AppTheme.primaryColor;
  Color get primaryGradientEnd => AppTheme.primaryLightColor;
  Color get successColor => AppTheme.successColor;
  Color get warningColor => AppTheme.warningColor;
  Color get infoColor => AppTheme.infoColor;
  Color get borderColor => AppTheme.borderColor;
  Color get textHint => AppTheme.textHint;
}
