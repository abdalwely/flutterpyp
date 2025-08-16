import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final double height;
  final bool showLabels;
  final bool enableHapticFeedback;
  final Duration animationDuration;
  final Curve animationCurve;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.height = 70,
    this.showLabels = true,
    this.enableHapticFeedback = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOutCubic,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _fadeAnimations;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Initialize animation controllers for each item
    _animationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      ),
    );

    // Initialize scale animations
    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: widget.animationCurve),
      );
    }).toList();

    // Initialize fade animations
    _fadeAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: widget.animationCurve),
      );
    }).toList();

    // Background animation controller
    _backgroundController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeOut),
    );

    // Start initial animation
    _backgroundController.forward();
    _animationControllers[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animateToIndex(oldWidget.currentIndex, widget.currentIndex);
    }
  }

  void _animateToIndex(int oldIndex, int newIndex) {
    // Animate out old item
    _animationControllers[oldIndex].reverse();
    
    // Animate in new item
    _animationControllers[newIndex].forward();
  }

  void _onItemTapped(int index) {
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onTap(index);
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.scaffoldBackgroundColor;
    final selectedColor = widget.selectedColor ?? AppTheme.primaryColor;
    final unselectedColor = widget.unselectedColor ?? AppTheme.textSecondary;

    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _backgroundAnimation.value) * widget.height),
          child: Container(
            height: widget.height + MediaQuery.of(context).padding.bottom,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
                BoxShadow(
                  color: selectedColor.withOpacity(0.05),
                  blurRadius: 30,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Stack(
                children: [
                  // Animated background indicator
                  AnimatedPositioned(
                    duration: widget.animationDuration,
                    curve: widget.animationCurve,
                    left: (MediaQuery.of(context).size.width / widget.items.length) * 
                          widget.currentIndex,
                    top: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width / widget.items.length,
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            selectedColor,
                            selectedColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(2),
                          bottomRight: Radius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  
                  // Navigation items
                  Padding(
                    padding: EdgeInsets.only(
                      top: 8,
                      bottom: MediaQuery.of(context).padding.bottom,
                    ),
                    child: Row(
                      children: widget.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isSelected = index == widget.currentIndex;

                        return Expanded(
                          child: _buildNavItem(
                            item: item,
                            isSelected: isSelected,
                            selectedColor: selectedColor,
                            unselectedColor: unselectedColor,
                            animation: _scaleAnimations[index],
                            fadeAnimation: _fadeAnimations[index],
                            onTap: () => _onItemTapped(index),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required BottomNavItem item,
    required bool isSelected,
    required Color selectedColor,
    required Color unselectedColor,
    required Animation<double> animation,
    required Animation<double> fadeAnimation,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([animation, fadeAnimation]),
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.translucent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with background circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle for selected item
                    if (isSelected)
                      Transform.scale(
                        scale: animation.value,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: selectedColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    
                    // Icon
                    Transform.scale(
                      scale: isSelected ? animation.value : 1.0,
                      child: AnimatedContainer(
                        duration: widget.animationDuration,
                        curve: widget.animationCurve,
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected 
                              ? selectedColor 
                              : unselectedColor.withOpacity(fadeAnimation.value),
                          size: 24,
                        ),
                      ),
                    ),
                    
                    // Badge
                    if (item.badge != null && item.badge! > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Transform.scale(
                          scale: isSelected ? animation.value : 1.0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                width: 1,
                              ),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              item.badge! > 99 ? '99+' : item.badge.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                // Label
                if (widget.showLabels)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: AnimatedDefaultTextStyle(
                      duration: widget.animationDuration,
                      curve: widget.animationCurve,
                      style: TextStyle(
                        color: isSelected 
                            ? selectedColor 
                            : unselectedColor.withOpacity(fadeAnimation.value),
                        fontSize: isSelected ? 12 : 11,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontFamily: 'Cairo',
                      ),
                      child: Text(
                        item.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final int? badge;
  final Widget? customIcon;

  BottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badge,
    this.customIcon,
  });
}

// Enhanced Bottom Navigation Bar with floating action button
class FloatingBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? fabLocation;

  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.floatingActionButton,
    this.fabLocation,
  });

  @override
  State<FloatingBottomNavBar> createState() => _FloatingBottomNavBarState();
}

class _FloatingBottomNavBarState extends State<FloatingBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabRotationAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    
    _fabRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
    
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.floatingActionButton != null 
          ? Stack(
              children: [
                // Main content
                Container(),
                
                // Floating Action Button
                if (widget.floatingActionButton != null)
                  Positioned(
                    bottom: 90,
                    left: MediaQuery.of(context).size.width / 2 - 28,
                    child: AnimatedBuilder(
                      animation: _fabScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _fabScaleAnimation.value,
                          child: Transform.rotate(
                            angle: _fabRotationAnimation.value * 0.1,
                            child: widget.floatingActionButton,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            )
          : Container(),
      
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onTap,
        items: widget.items,
      ),
    );
  }
}
