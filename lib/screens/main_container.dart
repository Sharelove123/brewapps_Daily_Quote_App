import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'browse_screen.dart';
import 'favorites_screen.dart';
import 'collections_screen.dart';
import 'settings_screen.dart';

class MainContainer extends ConsumerStatefulWidget {
  const MainContainer({super.key});

  @override
  ConsumerState<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends ConsumerState<MainContainer> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    BrowseScreen(),
    FavoritesScreen(),
    CollectionsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Sync settings when profile loads/updates
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated &&
          next.profile != null &&
          previous?.profile != next.profile) {
        ref.read(themeProvider.notifier).syncFromProfile(next.profile!);
      }
    });

    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get the appropriate gradient based on theme
    final gradient = isDark
        ? AppTheme.backgroundGradient
        : AppTheme.lightBackgroundGradient;

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: IndexedStack(index: _currentIndex, children: _screens),
        ),
        bottomNavigationBar: _buildGlassBottomNavBar(
          isDark,
          themeState.accentColor,
        ),
      ),
    );
  }

  Widget _buildGlassBottomNavBar(bool isDark, Color accentColor) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: accentColor,
            unselectedItemColor: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.5),
            selectedLabelStyle: AppTheme.navigationLabelStyle,
            unselectedLabelStyle: AppTheme.navigationLabelStyle,
            items: [
              _buildNavItem(
                Icons.home_rounded,
                Icons.home_outlined,
                AppStrings.home,
                0,
                accentColor,
              ),
              _buildNavItem(
                Icons.explore_rounded,
                Icons.explore_outlined,
                AppStrings.browse,
                1,
                accentColor,
              ),
              _buildNavItem(
                Icons.favorite_rounded,
                Icons.favorite_border_rounded,
                AppStrings.favorites,
                2,
                accentColor,
              ),
              _buildNavItem(
                Icons.folder_rounded,
                Icons.folder_outlined,
                AppStrings.collections,
                3,
                accentColor,
              ),
              _buildNavItem(
                Icons.person_rounded,
                Icons.person_outline_rounded,
                AppStrings.profile,
                4,
                accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    int index,
    Color accentColor,
  ) {
    final isSelected = _currentIndex == index;

    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Icon(isSelected ? activeIcon : inactiveIcon, size: 24),
      ),
      label: label,
    );
  }
}
