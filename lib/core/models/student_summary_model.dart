class StudentSummary {
  final String id;
  final String studentId;
  final String? delegateId;
  final String subject;
  final String? doctor;
  final String? note;
  final String? fileUrl;
  final DateTime createdAt;
  final String? groupId; // بناءً على الخطأ المتكرر The named parameter 'groupId' isn't defined

  StudentSummary({
    required this.id,
    required this.studentId,
    this.delegateId,
    required this.subject,
    this.doctor,
    this.note,
    this.fileUrl,
    required this.createdAt,
    this.groupId,
  });

  factory StudentSummary.fromJson(Map<String, dynamic> json) {
    return StudentSummary(
      id: json['id'],
      studentId: json['student_id'] ?? '',
      delegateId: json['delegate_id'],
      subject: json['subject'] ?? '',
      doctor: json['doctor'],
      note: json['note'],
      fileUrl: json['file_url'],
      createdAt: DateTime.parse(json['created_at']),
      groupId: json['group_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'delegate_id': delegateId,
      'subject': subject,
      'doctor': doctor,
      'note': note,
      'file_url': fileUrl,
      'created_at': createdAt.toIso8601String(),
      'group_id': groupId,
    };
  }
}
