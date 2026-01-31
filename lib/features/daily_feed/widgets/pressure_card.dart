import 'package:flutter/material.dart';
import '../daily_feed_item.dart';

class PressureCard extends StatelessWidget {
  final DailyFeedItem item;
  final Color accentColor;
  final IconData icon;
  final String label;

  const PressureCard._({
    required this.item,
    required this.accentColor,
    required this.icon,
    required this.label,
  });

  /// ================= FACTORIES =================

  factory PressureCard.high(DailyFeedItem item) {
    return PressureCard._(
      item: item,
      accentColor: const Color(0xFFE53935),
      icon: Icons.warning_amber_rounded,
      label: 'High Pressure',
    );
  }

  factory PressureCard.medium(DailyFeedItem item) {
    return PressureCard._(
      item: item,
      accentColor: const Color(0xFFFFA000),
      icon: Icons.timelapse,
      label: 'Medium Pressure',
    );
  }

  factory PressureCard.low(DailyFeedItem item) {
    return PressureCard._(
      item: item,
      accentColor: const Color(0xFF43A047),
      icon: Icons.check_circle_outline,
      label: 'Low Pressure',
    );
  }

  /// ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _indicator(),
          const SizedBox(width: 14),
          Expanded(child: _content()),
        ],
      ),
    );
  }

  /// ================= PARTS =================

  Widget _indicator() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: accentColor),
    );
  }

  Widget _content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.subject,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              _dueText(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
            const Spacer(),
            _badge(),
          ],
        ),
      ],
    );
  }

  Widget _badge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: accentColor,
        ),
      ),
    );
  }

  /// ================= HELPERS =================

  String _dueText() {
    final hours = item.dueDate.difference(DateTime.now()).inHours;

    if (hours <= 0) return 'Due now';
    if (hours < 24) return 'Due in $hours h';

    final days = (hours / 24).ceil();
    return 'Due in $days days';
  }
}