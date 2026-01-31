import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'daily_feed_state.dart';
import 'daily_feed_item.dart';
import '../../core/pressure/pressure_engine.dart';

final dailyFeedControllerProvider =
StateNotifierProvider<DailyFeedController, DailyFeedState>(
      (ref) => DailyFeedController()..loadDailyFeed(),
);

class DailyFeedController extends StateNotifier<DailyFeedState> {
  DailyFeedController() : super(DailyFeedState.loading());

  Future<void> loadDailyFeed() async {
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
        hasSubmission: false,
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

    final high = <DailyFeedItem>[];
    final medium = <DailyFeedItem>[];
    final low = <DailyFeedItem>[];
    final tomorrow = <DailyFeedItem>[];

    for (final item in items) {
      if (item.isLecture && item.isTomorrow) {
        tomorrow.add(item);
      }

      switch (PressureEngine.calculate(item)) {
        case PressureLevel.high:
          high.add(item);
          break;
        case PressureLevel.medium:
          medium.add(item);
          break;
        case PressureLevel.low:
          low.add(item);
          break;
      }
    }

    state = DailyFeedState.data(
      high: high,
      medium: medium,
      low: low,
      tomorrowLectures: tomorrow,
    );
  }
}