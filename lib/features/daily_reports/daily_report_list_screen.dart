import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/auth/user_role.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/daily_report_provider.dart'; // New DailyReport Provider
import '../../core/models/daily_report_model.dart'; // New DailyReport Model
import 'add_daily_report_dialog.dart'; // New DailyReport Dialog

class DailyReportListScreen extends ConsumerStatefulWidget {
  final UserRole userRole;
  const DailyReportListScreen({super.key, required this.userRole});

  @override
  ConsumerState<DailyReportListScreen> createState() => _DailyReportListScreenState();
}

class _DailyReportListScreenState extends ConsumerState<DailyReportListScreen> {
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

  void _confirmDelete(BuildContext context, String contentId) {
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
              final errorMessage = await ref.read(dailyReportProvider.notifier).deleteDailyReport(contentId);
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
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                // Assuming any delegate can delete any daily report since no created_by field was in the model
                final canDelete = isDelegate; 

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xFF3F51B5), size: 20),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (canDelete)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    onPressed: () => _confirmDelete(context, report.id),
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                                if (report.fileUrl != null && report.fileUrl!.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.open_in_new, color: Color(0xFF3F51B5), size: 20),
                                    onPressed: () async {
                                      final url = Uri.parse(report.fileUrl!);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                      }
                                    },
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.subject,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (report.doctor != null && report.doctor!.isNotEmpty)
                          Text('${l10n.doctor}: ${report.doctor}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(height: 4),
                        if (report.room != null && report.room!.isNotEmpty)
                          Text('${l10n.room}: ${report.room}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(height: 4),
                        if (report.day != null && report.day!.isNotEmpty)
                          Text('${l10n.day}: ${report.day}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text(
                          '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
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
