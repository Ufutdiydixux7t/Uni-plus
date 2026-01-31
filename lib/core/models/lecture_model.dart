import 'package:freezed_annotation/freezed_annotation.dart';

part 'lecture_model.freezed.dart';
part 'lecture_model.g.dart';

@freezed
class Lecture with _$Lecture {
  const factory Lecture({
    required String id,
    required String subject,
    String? doctor,
    String? note,
    @JsonKey(name: 'file_url') String? fileUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'delegate_id') String? delegateId,
    @JsonKey(name: 'student_id') String? studentId,
  }) = _Lecture;

  factory Lecture.fromJson(Map<String, dynamic> json) => _$LectureFromJson(json);
}
