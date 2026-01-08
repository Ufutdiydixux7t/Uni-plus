import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/app_drawer.dart';
import '../../core/storage/secure_storage_service.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String studentName = '';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final name = await SecureStorageService.getName();
    if (!mounted) return;
    setState(() => studentName = name ?? 'Student');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyFeedControllerProvider);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F7FB),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header()),

            SliverToBoxAdapter(
              child: _tomorrowSection(state.tomorrowLectures),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    if (state.high.isNotEmpty) ...[
                      const SectionTitle(title: 'ON YOUR PLATE'),
                      const SizedBox(height: 12),
                      ...state.high.map(PressureCard.high),
                      const SizedBox(height: 28),
                    ],

                    if (state.medium.isNotEmpty) ...[
                      const SectionTitle(title: 'COMING UP'),
                      const SizedBox(height: 12),
                      ...state.medium.map(PressureCard.medium),
                      const SizedBox(height: 28),
                    ],

                    if (state.low.isNotEmpty) ...[
                      const SectionTitle(title: 'LATER'),
                      const SizedBox(height: 12),
                      ...state.low.map(PressureCard.low),
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
      padding: const EdgeInsets.fromLTRB(16, 18, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF6A5AE0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Row(
            children: [
              _menuButton(),
              const Spacer(),
              const Icon(
                Icons.school_outlined,
                color: Colors.white70,
                size: 22,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Greeting
          TypewriterText(
            text: 'Good Morning, $studentName',
            speed: const Duration(milliseconds: 50),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Here’s your academic pressure today',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _scaffoldKey.currentState?.openDrawer(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.menu,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  // ================= TOMORROW =================

  Widget _tomorrowSection(List<DailyFeedItem> items) {
    if (items.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tomorrow Lectures',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 125,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final item = items[index];

                return Container(
                  width: 250,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF1FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.menu_book_outlined,
                            color: Color(0xFF3F51B5),
                            size: 18,
                          ),
                          SizedBox(width: 6),
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
                      const SizedBox(height: 10),
                      Text(
                        item.subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                          color: Colors.black45,
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