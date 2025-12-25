import 'package:flutter/material.dart';

class DailyFeedHeader extends StatelessWidget {
  final String studentName;
  final String dateText;

  const DailyFeedHeader({
    super.key,
    required this.studentName,
    required this.dateText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning, $studentName',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Today: $dateText',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}