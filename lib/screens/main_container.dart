import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;

  final List<Widget> _screens = [const HomeScreen(), const FavoritesScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          bottom: false,
          child: IndexedStack(index: _currentIndex, children: _screens),
        ),
      ),
      bottomNavigationBar: _buildGlassBottomNavBar(),
    );
  }

  Widget _buildGlassBottomNavBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD6E4FF).withValues(alpha: 0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              selectedLabelStyle: AppTheme.navigationLabelStyle.copyWith(
                color: const Color(0xFFA855F7),
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: AppTheme.navigationLabelStyle,
              items: [
                BottomNavigationBarItem(
                  icon: _buildIcon(Icons.home_rounded, 0),
                  label: 'Today',
                ),
                BottomNavigationBarItem(
                  icon: _buildIcon(Icons.favorite_rounded, 1),
                  label: 'Favorites',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: isSelected
          ? BoxDecoration(
              color: const Color(0xFFA855F7),
              borderRadius: BorderRadius.circular(20),
            )
          : null,
      child: Icon(icon),
    );
  }
}
