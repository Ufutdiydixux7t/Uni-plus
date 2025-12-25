import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/app_drawer.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/pressure/pressure_engine.dart';
import '../../../shared/widgets/typewriter_text.dart';

import 'daily_feed_controller.dart';
import 'daily_feed_item.dart';
import 'widgets/pressure_card.dart';
import 'widgets/section_title.dart';

class DailyFeedScreen extends ConsumerStatefulWidget {
  const DailyFeedScreen({super.key});

  @override
  ConsumerState<DailyFeedScreen> createState() => _DailyFeedScreenState();
}

class _DailyFeedScreenState extends ConsumerState<DailyFeedScreen> {
  String studentName = '';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final name = await SecureStorageService.getName();
    setState(() {
      studentName = name ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyFeedControllerProvider);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ================= FILTERING =================

    final high = <DailyFeedItem>[];
    final medium = <DailyFeedItem>[];
    final low = <DailyFeedItem>[];

    for (final item in state.items) {
      final level = PressureEngine.calculate(item);

      switch (level) {
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

    final tomorrowLectures = state.items.where(
          (item) => item.isLecture && item.isTomorrow,
    ).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _header()),
            SliverToBoxAdapter(
              child: _tomorrowSection(tomorrowLectures),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    if (high.isNotEmpty) ...[
                      const SectionTitle(title: 'ON YOUR PLATE'),
                      const SizedBox(height: 8),
                      ...high.map(PressureCard.high),
                      const SizedBox(height: 24),
                    ],
                    if (medium.isNotEmpty) ...[
                      const SectionTitle(title: 'COMING UP'),
                      const SizedBox(height: 8),
                      ...medium.map(PressureCard.medium),
                      const SizedBox(height: 24),
                    ],
                    if (low.isNotEmpty) ...[
                      const SectionTitle(title: 'LATER'),
                      const SizedBox(height: 8),
                      ...low.map(PressureCard.low),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF6A5AE0)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TypewriterText(
            text: 'Good Morning, $studentName',
            speed: const Duration(milliseconds: 60),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Here’s your academic pressure today',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ================= TOMORROW =================

  Widget _tomorrowSection(List<DailyFeedItem> items) {
    if (items.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tomorrow Lectures',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  width: 240,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF1FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.menu_book,
                              color: Color(0xFF3F51B5)),
                          SizedBox(width: 8),
                          Text(
                            'Lecture',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3F51B5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.subject,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Tomorrow',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}