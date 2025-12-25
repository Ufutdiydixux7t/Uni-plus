import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'daily_feed_state.dart';
import 'daily_feed_item.dart';

final dailyFeedControllerProvider =
StateNotifierProvider<DailyFeedController, DailyFeedState>(
      (ref) => DailyFeedController()..loadDailyFeed(),
);

class DailyFeedController extends StateNotifier<DailyFeedState> {
  DailyFeedController() : super(const DailyFeedState());

  Future<void> loadDailyFeed() async {
    state = DailyFeedState.loading();

    await Future.delayed(const Duration(seconds: 1));

    final items = <DailyFeedItem>[
      DailyFeedItem(
        id: '1',
        subject: 'Data Structures',
        description: 'Assignment due today',
        dueDate: DateTime.now().add(const Duration(hours: 5)),
        type: FeedItemType.assignment,
        hasSubmission: true,
        openedCount: 0,
      ),
      DailyFeedItem(
        id: '2',
        subject: 'Calculus',
        description: 'Lecture at 10:00 AM',
        dueDate: DateTime.now().add(const Duration(hours: 3)),
        type: FeedItemType.lecture,
        openedCount: 2,
      ),
      DailyFeedItem(
        id: '3',
        subject: 'Operating Systems',
        description: 'Assignment due in 2 days',
        dueDate: DateTime.now().add(const Duration(hours: 48)),
        type: FeedItemType.assignment,
        hasSubmission: true,
        openedCount: 1,
      ),
    ];

    state = state.copyWith(
      items: items,
      isLoading: false,
    );
  }
}