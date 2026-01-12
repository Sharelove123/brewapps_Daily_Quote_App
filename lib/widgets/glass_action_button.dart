import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Reusable glass action button with blur effect
class GlassActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;
  final bool isLarge;
  final bool isLoading;

  const GlassActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
    this.isLarge = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = isLarge ? 72.0 : 56.0;
    final iconSize = isLarge ? 32.0 : 24.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isActive
        ? AppTheme.primaryPurple.withValues(alpha: 0.3)
        : (isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05));

    final borderColor = isActive
        ? AppTheme.primaryPurple
        : (isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.1));

    final iconColor = isActive
        ? AppTheme.favorite
        : (isDark ? Colors.white : AppTheme.textSecondaryLight);

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: isActive ? 2 : 1),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(icon, color: iconColor, size: iconSize),
            ),
          ),
        ),
      ),
    );
  }
}
