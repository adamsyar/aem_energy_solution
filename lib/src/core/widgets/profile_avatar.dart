import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.label,
    this.radius = 30,
    this.imageAsset,
  });

  final String label;
  final double radius;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: CircleAvatar(
          radius: radius,
          backgroundColor: const Color(0xFFCDD6FF),
          backgroundImage: imageAsset != null ? AssetImage(imageAsset!) : null,
          child: imageAsset == null
              ? Text(
                  label,
                  style: TextStyle(
                    fontSize: radius * 0.72,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D33B7),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
