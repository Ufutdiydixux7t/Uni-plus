import 'package:freezed_annotation/freezed_annotation.dart';

part 'form_model.freezed.dart';
part 'form_model.g.dart';

@freezed
class FormModel with _$FormModel {
  const factory FormModel({
    required String id,
    required String subject,
    String? doctor,
    String? note,
    @JsonKey(name: 'file_url') String? fileUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _FormModel;

  factory FormModel.fromJson(Map<String, dynamic> json) => _$FormModelFromJson(json);
}
