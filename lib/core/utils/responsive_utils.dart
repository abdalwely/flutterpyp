import 'package:flutter/material.dart';
import 'dart:math' as math;

class ResponsiveUtils {
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 900;
  static const double _desktopBreakpoint = 1200;
  
  // Device type detection
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < _mobileBreakpoint;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= _mobileBreakpoint && width < _desktopBreakpoint;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= _desktopBreakpoint;
  }
  
  static bool isLargeTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= _tabletBreakpoint && width < _desktopBreakpoint;
  }
  
  // Get device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < _mobileBreakpoint) return DeviceType.mobile;
    if (width < _tabletBreakpoint) return DeviceType.tablet;
    if (width < _desktopBreakpoint) return DeviceType.largeTablet;
    return DeviceType.desktop;
  }
  
  // Responsive values based on device type
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? largeTablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.largeTablet:
        return largeTablet ?? tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? largeTablet ?? tablet ?? mobile;
    }
  }
  
  // Font sizes
  static double fontSize(BuildContext context, {
    required double mobile,
    double? tablet,
    double? largeTablet,
    double? desktop,
  }) {
    return responsive<double>(
      context,
      mobile: mobile,
      tablet: tablet,
      largeTablet: largeTablet,
      desktop: desktop,
    );
  }
  
  // Spacing
  static double spacing(BuildContext context, {
    required double mobile,
    double? tablet,
    double? largeTablet,
    double? desktop,
  }) {
    return responsive<double>(
      context,
      mobile: mobile,
      tablet: tablet,
      largeTablet: largeTablet,
      desktop: desktop,
    );
  }
  
  // Padding
  static EdgeInsets padding(BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? largeTablet,
    EdgeInsets? desktop,
  }) {
    return responsive<EdgeInsets>(
      context,
      mobile: mobile,
      tablet: tablet,
      largeTablet: largeTablet,
      desktop: desktop,
    );
  }
  
  // Grid columns
  static int gridColumns(BuildContext context, {
    required int mobile,
    int? tablet,
    int? largeTablet,
    int? desktop,
  }) {
    return responsive<int>(
      context,
      mobile: mobile,
      tablet: tablet,
      largeTablet: largeTablet,
      desktop: desktop,
    );
  }
  
  // Icon sizes
  static double iconSize(BuildContext context, {
    required double mobile,
    double? tablet,
    double? largeTablet,
    double? desktop,
  }) {
    return responsive<double>(
      context,
      mobile: mobile,
      tablet: tablet,
      largeTablet: largeTablet,
      desktop: desktop,
    );
  }
  
  // Container sizes
  static double containerSize(BuildContext context, {
    required double mobile,
    double? tablet,
    double? largeTablet,
    double? desktop,
  }) {
    return responsive<double>(
      context,
      mobile: mobile,
      tablet: tablet,
      largeTablet: largeTablet,
      desktop: desktop,
    );
  }
  
  // Width percentages
  static double widthPercent(BuildContext context, double percent) {
    return MediaQuery.of(context).size.width * percent;
  }
  
  static double heightPercent(BuildContext context, double percent) {
    return MediaQuery.of(context).size.height * percent;
  }
  
  // Max width constraints
  static double maxWidth(BuildContext context, {double? maxWidth}) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (maxWidth == null) return screenWidth;
    return math.min(screenWidth, maxWidth);
  }
  
  // Adaptive margins based on screen size
  static EdgeInsets adaptiveMargin(BuildContext context) {
    return responsive<EdgeInsets>(
      context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      largeTablet: const EdgeInsets.all(32),
      desktop: const EdgeInsets.all(40),
    );
  }
  
  // Adaptive padding based on screen size
  static EdgeInsets adaptivePadding(BuildContext context) {
    return responsive<EdgeInsets>(
      context,
      mobile: const EdgeInsets.all(20),
      tablet: const EdgeInsets.all(28),
      largeTablet: const EdgeInsets.all(36),
      desktop: const EdgeInsets.all(44),
    );
  }
  
  // Adaptive border radius
  static double adaptiveBorderRadius(BuildContext context) {
    return responsive<double>(
      context,
      mobile: 12,
      tablet: 16,
      largeTablet: 20,
      desktop: 24,
    );
  }
  
  // Safe area adjustments
  static EdgeInsets safeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom,
      left: mediaQuery.padding.left,
      right: mediaQuery.padding.right,
    );
  }
  
  // Keyboard handling
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }
  
  static double keyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }
  
  // Orientation helpers
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
  
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  // Density-aware sizing
  static double densityAwareSize(BuildContext context, double size) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return size * devicePixelRatio;
  }
  
  // Text scale aware sizing
  static double textScaleAwareSize(BuildContext context, double size) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return size * textScaleFactor;
  }
  
  // Adaptive grid configuration
  static GridConfiguration adaptiveGrid(BuildContext context) {
    return responsive<GridConfiguration>(
      context,
      mobile: GridConfiguration(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      tablet: GridConfiguration(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      largeTablet: GridConfiguration(
        crossAxisCount: 4,
        childAspectRatio: 1.3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      desktop: GridConfiguration(
        crossAxisCount: 5,
        childAspectRatio: 1.4,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
    );
  }
  
  // Layout configuration
  static LayoutConfiguration getLayoutConfig(BuildContext context) {
    return responsive<LayoutConfiguration>(
      context,
      mobile: LayoutConfiguration(
        padding: const EdgeInsets.all(16),
        spacing: 16,
        borderRadius: 12,
        elevation: 4,
        fontSize: FontSizes.mobile(),
      ),
      tablet: LayoutConfiguration(
        padding: const EdgeInsets.all(24),
        spacing: 24,
        borderRadius: 16,
        elevation: 6,
        fontSize: FontSizes.tablet(),
      ),
      largeTablet: LayoutConfiguration(
        padding: const EdgeInsets.all(32),
        spacing: 32,
        borderRadius: 20,
        elevation: 8,
        fontSize: FontSizes.largeTablet(),
      ),
      desktop: LayoutConfiguration(
        padding: const EdgeInsets.all(40),
        spacing: 40,
        borderRadius: 24,
        elevation: 10,
        fontSize: FontSizes.desktop(),
      ),
    );
  }
}

enum DeviceType {
  mobile,
  tablet,
  largeTablet,
  desktop,
}

class GridConfiguration {
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  GridConfiguration({
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
  });
}

class LayoutConfiguration {
  final EdgeInsets padding;
  final double spacing;
  final double borderRadius;
  final double elevation;
  final FontSizes fontSize;

  LayoutConfiguration({
    required this.padding,
    required this.spacing,
    required this.borderRadius,
    required this.elevation,
    required this.fontSize,
  });
}

class FontSizes {
  final double h1;
  final double h2;
  final double h3;
  final double h4;
  final double body1;
  final double body2;
  final double caption;
  final double button;

  FontSizes({
    required this.h1,
    required this.h2,
    required this.h3,
    required this.h4,
    required this.body1,
    required this.body2,
    required this.caption,
    required this.button,
  });

  factory FontSizes.mobile() {
    return FontSizes(
      h1: 28,
      h2: 24,
      h3: 20,
      h4: 18,
      body1: 16,
      body2: 14,
      caption: 12,
      button: 16,
    );
  }

  factory FontSizes.tablet() {
    return FontSizes(
      h1: 32,
      h2: 28,
      h3: 24,
      h4: 20,
      body1: 18,
      body2: 16,
      caption: 14,
      button: 18,
    );
  }

  factory FontSizes.largeTablet() {
    return FontSizes(
      h1: 36,
      h2: 32,
      h3: 28,
      h4: 24,
      body1: 20,
      body2: 18,
      caption: 16,
      button: 20,
    );
  }

  factory FontSizes.desktop() {
    return FontSizes(
      h1: 40,
      h2: 36,
      h3: 32,
      h4: 28,
      body1: 22,
      body2: 20,
      caption: 18,
      button: 22,
    );
  }
}

// Widget extension for easy responsive usage
extension ResponsiveWidget on Widget {
  Widget responsive(BuildContext context, {
    Widget? mobile,
    Widget? tablet,
    Widget? largeTablet,
    Widget? desktop,
  }) {
    return ResponsiveUtils.responsive<Widget>(
      context,
      mobile: mobile ?? this,
      tablet: tablet,
      largeTablet: largeTablet,
      desktop: desktop,
    );
  }
}

// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    return builder(context, deviceType);
  }
}

// Responsive layout widget
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? largeTablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.largeTablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.responsive<Widget>(
      context,
      mobile: mobile,
      tablet: tablet,
      largeTablet: largeTablet,
      desktop: desktop,
    );
  }
}
