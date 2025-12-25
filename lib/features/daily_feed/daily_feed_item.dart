enum FeedItemType {
  lecture,
  assignment,
  material,
  announcement,
}

enum PressureLevel {
  high,
  medium,
  low,
}

class DailyFeedItem {
  final String id;
  final String subject;
  final String description;
  final DateTime dueDate;
  final FeedItemType type;
  final bool hasSubmission;
  final int openedCount;

  const DailyFeedItem({
    required this.id,
    required this.subject,
    required this.description,
    required this.dueDate,
    required this.type,
    this.hasSubmission = false,
    this.openedCount = 0,
  });

  bool get isLecture => type == FeedItemType.lecture;

  bool get isTomorrow {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return dueDate.year == tomorrow.year &&
        dueDate.month == tomorrow.month &&
        dueDate.day == tomorrow.day;
  }

  int get hoursLeft => dueDate.difference(DateTime.now()).inHours;
}