import 'dart:convert';
import 'package:flutter/material.dart';

class AvatarImage extends StatelessWidget {
  final String? urlOrData;
  final double radius;
  final Color? backgroundColor;
  final Color? iconColor;

  const AvatarImage({
    super.key,
    required this.urlOrData,
    this.radius = 24,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (urlOrData != null && urlOrData!.isNotEmpty) {
      if (urlOrData!.startsWith('http')) {
        imageProvider = NetworkImage(urlOrData!);
      } else {
        try {
          // Attempt to decode base64
          final bytes = base64Decode(urlOrData!);
          imageProvider = MemoryImage(bytes);
        } catch (e) {
          debugPrint('Error decoding avatar base64: $e');
        }
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey.withValues(alpha: 0.2),
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Icon(
              Icons.person,
              size:
                  radius, // Icon size usually matches radius or slightly smaller
              color: iconColor ?? Colors.grey,
            )
          : null,
    );
  }
}
