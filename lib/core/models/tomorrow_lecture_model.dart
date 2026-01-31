import 'package:freezed_annotation/freezed_annotation.dart';

part 'tomorrow_lecture_model.freezed.dart';
part 'tomorrow_lecture_model.g.dart';

@freezed
class TomorrowLecture with _$TomorrowLecture {
  const factory TomorrowLecture({
    required String id,
    required String subject,
    String? doctor,
    String? room,
    String? time,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TomorrowLecture;

  factory TomorrowLecture.fromJson(Map<String, dynamic> json) => _$TomorrowLectureFromJson(json);
}
