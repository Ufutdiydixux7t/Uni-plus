import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String subject,
    String? doctor,
    String? note,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
