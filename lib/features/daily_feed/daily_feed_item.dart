enum FeedItemType {
  assignment,
  lecture,
}

class DailyFeedItem {
  final String id;
  final String subject;
  final String description;
  final DateTime dueDate;

  final bool hasSubmission;
  final int openedCount;
  final FeedItemType type;

  const DailyFeedItem({
    required this.id,
    required this.subject,
    required this.description,
    required this.dueDate,
    required this.hasSubmission,
    required this.openedCount,
    required this.type,
  });

  // ================= HELPERS =================

  bool get isLecture => type == FeedItemType.lecture;

  bool get isAssignment => type == FeedItemType.assignment;

  /// عدد الساعات المتبقية
  int get hoursLeft =>
      dueDate.difference(DateTime.now()).inHours;

  bool get isTomorrow {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    return dueDate.year == tomorrow.year &&
        dueDate.month == tomorrow.month &&
        dueDate.day == tomorrow.day;
  }
}