import 'package:freezed_annotation/freezed_annotation.dart';

part 'summary_model.freezed.dart';
part 'summary_model.g.dart';

@freezed
class Summary with _$Summary {
  const factory Summary({
    required String id,
    required String subject,
    String? doctor,
    String? note,
    @JsonKey(name: 'file_url') String? fileUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'delegate_id') String? delegateId,
    @JsonKey(name: 'student_id') String? studentId,
  }) = _Summary;

  factory Summary.fromJson(Map<String, dynamic> json) => _$SummaryFromJson(json);
}
