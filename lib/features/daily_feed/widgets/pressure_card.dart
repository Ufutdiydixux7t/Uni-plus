import 'package:flutter/material.dart';
import '../daily_feed_item.dart';

enum PressureUiType { high, medium, low }

class PressureCard extends StatelessWidget {
  final DailyFeedItem item;
  final PressureUiType type;

  const PressureCard({
    super.key,
    required this.item,
    required this.type,
  });

  /// Shortcuts
  factory PressureCard.high(DailyFeedItem item) =>
      PressureCard(item: item, type: PressureUiType.high);

  factory PressureCard.medium(DailyFeedItem item) =>
      PressureCard(item: item, type: PressureUiType.medium);

  factory PressureCard.low(DailyFeedItem item) =>
      PressureCard(item: item, type: PressureUiType.low);

  @override
  Widget build(BuildContext context) {
    final config = _config(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: config.color.withOpacity(0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Indicator =====
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: config.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),

          // ===== Content =====
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject
                Text(
                  item.subject,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),

                // Footer
                Row(
                  children: [
                    Icon(
                      config.icon,
                      size: 14,
                      color: config.color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _dueText(item),
                      style: TextStyle(
                        fontSize: 11,
                        color: config.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  _PressureConfig _config(PressureUiType type) {
    switch (type) {
      case PressureUiType.high:
        return _PressureConfig(
          color: const Color(0xFFE53935),
          icon: Icons.warning_amber_rounded,
        );
      case PressureUiType.medium:
        return _PressureConfig(
          color: const Color(0xFFFFA000),
          icon: Icons.schedule,
        );
      case PressureUiType.low:
        return _PressureConfig(
          color: const Color(0xFF43A047),
          icon: Icons.check_circle_outline,
        );
    }
  }

  String _dueText(DailyFeedItem item) {
    final hours = item.hoursLeft;

    if (hours <= 0) return 'Due now';
    if (hours < 24) return '$hours hours left';
    return '${(hours / 24).round()} days left';
  }
}

// ================= INTERNAL CONFIG =================

class _PressureConfig {
  final Color color;
  final IconData icon;

  const _PressureConfig({
    required this.color,
    required this.icon,
  });
}