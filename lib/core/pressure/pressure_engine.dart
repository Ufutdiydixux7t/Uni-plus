
import '../../features/daily_feed/daily_feed_item.dart';


enum PressureLevel {
  high,
  medium,
  low,
}

class PressureEngine {
  static PressureLevel calculate(DailyFeedItem item) {
    int score = 0;

    // عامل الوقت
    if (item.hoursLeft <= 6) {
      score += 5;
    } else if (item.hoursLeft <= 24) {
      score += 3;
    } else if (item.hoursLeft <= 72) {
      score += 1;
    }

    // عامل التسليم
    if (item.hasSubmission) {
      score += 3;
    }

    // عامل التجاهل
    if (item.openedCount == 0) {
      score += 2;
    } else if (item.openedCount > 3) {
      score -= 1;
    }

    if (score >= 6) return PressureLevel.high;
    if (score >= 3) return PressureLevel.medium;
    return PressureLevel.low;
  }
}