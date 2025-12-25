import 'package:flutter/material.dart';

enum PressureLevel { high, medium, low }

class PressureBadge extends StatelessWidget {
  final PressureLevel level;

  const PressureBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    late Color color;
    late String label;

    switch (level) {
      case PressureLevel.high:
        color = Colors.red;
        label = 'HIGH';
        break;
      case PressureLevel.medium:
        color = Colors.orange;
        label = 'MEDIUM';
        break;
      case PressureLevel.low:
        color = Colors.green;
        label = 'LOW';
        break;
    }

    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}