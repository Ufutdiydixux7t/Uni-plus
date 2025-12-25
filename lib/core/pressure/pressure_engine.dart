import '../../features/daily_feed/daily_feed_item.dart';

class PressureEngine {
  static PressureLevel calculate(DailyFeedItem item) {
    final now = DateTime.now();
    final hoursLeft = item.dueDate.difference(now).inHours;

    int score = 0;

    // ⏱ عامل الوقت
    if (hoursLeft <= 6) {
      score += 5;
    } else if (hoursLeft <= 24) {
      score += 3;
    } else if (hoursLeft <= 72) {
      score += 1;
    }

    // 📌 عامل التسليم
    if (item.hasSubmission) {
      score += 3;
    }

    // 👀 عامل التجاهل
    if (item.openedCount == 0) {
      score += 2;
    } else if (item.openedCount > 3) {
      score -= 1;
    }

    // 🔥 التصنيف النهائي
    if (score >= 6) return PressureLevel.high;
    if (score >= 3) return PressureLevel.medium;
    return PressureLevel.low;
  }
}