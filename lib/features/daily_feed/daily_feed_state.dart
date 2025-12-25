import 'daily_feed_item.dart';

class DailyFeedState {
  final List<DailyFeedItem> items;
  final bool isLoading;

  const DailyFeedState({
    this.items = const [],
    this.isLoading = false,
  });

  factory DailyFeedState.loading() {
    return const DailyFeedState(isLoading: true);
  }

  DailyFeedState copyWith({
    List<DailyFeedItem>? items,
    bool? isLoading,
  }) {
    return DailyFeedState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isEmpty => items.isEmpty;


}