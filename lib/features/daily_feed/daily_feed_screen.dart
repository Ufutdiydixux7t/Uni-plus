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
                  _actionCard(Icons.menu_book, l10n.lectures, () => _navigateToContent(l10n.lectures, 'lectures')),
                  _actionCard(Icons.folder_open, l10n.materials, () => _navigateToContent(l10n.materials, 'materials')),
                  _actionCard(Icons.description, l10n.summaries, () => _navigateToContent(l10n.summaries, 'summaries')),
                  _actionCard(Icons.task_alt, l10n.tasks, () => _navigateToContent(l10n.tasks, 'tasks')),
                  _actionCard(Icons.assignment, l10n.forms, () => _navigateToContent(l10n.forms, 'forms')),
                  _actionCard(Icons.grade, l10n.grades, () => _navigateToContent(l10n.grades, 'grades')),
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
