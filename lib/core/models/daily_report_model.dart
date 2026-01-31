import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_report_model.freezed.dart';
part 'daily_report_model.g.dart';

@freezed
class DailyReport with _$DailyReport {
  const factory DailyReport({
    required String id,
    required String subject,
    String? doctor,
    String? room,
    String? day,
    @JsonKey(name: 'file_url') String? fileUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _DailyReport;

  factory DailyReport.fromJson(Map<String, dynamic> json) => _$DailyReportFromJson(json);
}
