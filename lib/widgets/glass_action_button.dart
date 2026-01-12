import 'dart:ui';
import 'package:flutter/material.dart';

class GlassActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLarge;
  final bool isActive;

  const GlassActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isLarge = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: isLarge ? 72 : 56,
          height: isLarge ? 72 : 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Center(
                child: Icon(
                  icon,
                  color: isActive ? Colors.redAccent : Colors.white,
                  size: isLarge ? 32 : 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
