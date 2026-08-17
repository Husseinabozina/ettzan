import 'package:flutter/material.dart';

class SoftOrb extends StatelessWidget {
  const SoftOrb({required this.size, required this.color, super.key});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: .18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .16),
            blurRadius: 45,
            spreadRadius: 12,
          ),
        ],
      ),
    );
  }
}
