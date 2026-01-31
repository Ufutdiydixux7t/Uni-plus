import 'daily_feed_item.dart';

class DailyFeedState {
  final List<DailyFeedItem> high;
  final List<DailyFeedItem> medium;
  final List<DailyFeedItem> low;
  final List<DailyFeedItem> tomorrowLectures;
  final bool isLoading;

  const DailyFeedState({
    required this.high,
    required this.medium,
    required this.low,
    required this.tomorrowLectures,
    required this.isLoading,
  });

  factory DailyFeedState.loading() {
    return const DailyFeedState(
      high: [],
      medium: [],
      low: [],
      tomorrowLectures: [],
      isLoading: true,
    );
  }

  factory DailyFeedState.data({
    required List<DailyFeedItem> high,
    required List<DailyFeedItem> medium,
    required List<DailyFeedItem> low,
    required List<DailyFeedItem> tomorrowLectures,
  }) {
    return DailyFeedState(
      high: high,
      medium: medium,
      low: low,
      tomorrowLectures: tomorrowLectures,
      isLoading: false,
    );
  }
}