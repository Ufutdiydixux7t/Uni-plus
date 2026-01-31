import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/auth/user_role.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/daily_report_provider.dart';
import '../../core/models/daily_report_model.dart';
import 'add_daily_report_dialog.dart';

class DailyReportListScreen extends ConsumerStatefulWidget {
  final UserRole userRole;
  const DailyReportListScreen({super.key, required this.userRole});

  @override
  ConsumerState<DailyReportListScreen> createState() => _DailyReportListScreenState();
}

class _DailyReportListScreenState extends ConsumerState<DailyReportListScreen> {
  final currentUserId = Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _fetchDailyReports();
  }

  Future<void> _fetchDailyReports() async {
    ref.read(dailyReportProvider.notifier).fetchDailyReports();
  }

  void _showAddDailyReportDialog() {
    showDialog(
      context: context,
      builder: (_) => const AddDailyReportDialog(),
    );
  }

  void _confirmDelete(BuildContext context, String contentId, String delegateId) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.confirmDelete),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final errorMessage = await ref.read(dailyReportProvider.notifier).deleteDailyReport(contentId, delegateId);
              if (mounted) {
                if (errorMessage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.success)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l10n.error}: $errorMessage'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(dailyReportProvider);
    final l10n = AppLocalizations.of(context);
    final isDelegate = widget.userRole == UserRole.delegate || widget.userRole == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dailyReports, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDailyReports,
          )
        ],
      ),
      body: reports.isEmpty
          ? Center(child: Text(l10n.noContent))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                final canDelete = isDelegate && report.delegateId == currentUserId;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3F51B5).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.calendar_today, color: Color(0xFF3F51B5), size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report.subject,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (report.doctor != null && report.doctor!.isNotEmpty)
                                Text(
                                  '${l10n.doctor}: ${report.doctor}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (report.room != null && report.room!.isNotEmpty)
                                Text(
                                  '${l10n.room}: ${report.room}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            if (report.fileUrl != null && report.fileUrl!.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.open_in_new, color: Color(0xFF3F51B5)),
                                onPressed: () async {
                                  final url = Uri.parse(report.fileUrl!);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  }
                                },
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                              ),
                            if (canDelete)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _confirmDelete(context, report.id, report.delegateId!),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: isDelegate
          ? FloatingActionButton.extended(
              onPressed: _showAddDailyReportDialog,
              backgroundColor: const Color(0xFF3F51B5),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(l10n.addContent, style: const TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}
