import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_summary_model.freezed.dart';
part 'student_summary_model.g.dart';

@freezed
class StudentSummary with _$StudentSummary {
  const factory StudentSummary({
    required String id,
    @JsonKey(name: 'student_id') required String studentId,
    @JsonKey(name: 'delegate_id') String? delegateId,
    required String subject,
    String? doctor,
    String? note,
    @JsonKey(name: 'file_url') String? fileUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _StudentSummary;

  factory StudentSummary.fromJson(Map<String, dynamic> json) => _$StudentSummaryFromJson(json);
}
