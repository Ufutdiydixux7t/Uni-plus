import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../shared/widgets/app_drawer.dart';
import '../shared/content_list_screen.dart';

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

  void _navigateToContent(String title, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentListScreen(
          category: category,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F7FB),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header(l10n)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _tomorrowLecturesSection(l10n),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildListDelegate([
                  _actionCard(Icons.menu_book, l10n.lectures, () => _navigateToContent(l10n.lectures, l10n.lectures)),
                  _actionCard(Icons.assessment_outlined, l10n.dailyReports, () => _navigateToContent(l10n.dailyReports, l10n.dailyReports)),
                  _actionCard(Icons.description, l10n.summaries, () => _navigateToContent(l10n.summaries, l10n.summaries)),
                  _actionCard(Icons.task_alt, l10n.tasks, () => _navigateToContent(l10n.tasks, l10n.tasks)),
                  _actionCard(Icons.assignment, l10n.forms, () => _navigateToContent(l10n.forms, l10n.forms)),
                  _actionCard(Icons.grade, l10n.grades, () => _navigateToContent(l10n.grades, l10n.grades)),
                ]),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _header(AppLocalizations l10n) {
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
          Row(
            children: [
              _menuButton(),
              const Spacer(),
              const Icon(Icons.school_outlined, color: Colors.white70, size: 22),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${l10n.welcome}, $studentName',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Access your academic content easily',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _tomorrowLecturesSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.tomorrowLectures,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              _lectureRow(l10n.subject, l10n.time, l10n.room, isHeader: true),
              const Divider(height: 24),
              _lectureRow('Data Structures', '09:00 AM', 'Hall A'),
              const SizedBox(height: 12),
              _lectureRow('Mathematics II', '11:00 AM', 'Lab 3'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _lectureRow(String subject, String time, String room, {bool isHeader = false}) {
    final style = TextStyle(
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      color: isHeader ? Colors.grey[700] : Colors.black87,
      fontSize: 14,
    );
    return Row(
      children: [
        Expanded(flex: 3, child: Text(subject, style: style)),
        Expanded(flex: 2, child: Text(time, style: style)),
        Expanded(flex: 1, child: Text(room, style: style, textAlign: TextAlign.end)),
      ],
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
        child: const Icon(Icons.menu, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _actionCard(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF3F51B5)),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
