class Summary {
  final String id;
  final String subject;
  final String? doctor;
  final String? note;
  final String? fileUrl;
  final DateTime createdAt;
  final String? delegateId;
  final String? studentId;
  final String? groupId; // بناءً على الخطأ المتكرر The named parameter 'groupId' isn't defined

  Summary({
    required this.id,
    required this.subject,
    this.doctor,
    this.note,
    this.fileUrl,
    required this.createdAt,
    this.delegateId,
    this.studentId,
    this.groupId,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      id: json['id'],
      subject: json['subject'] ?? '',
      doctor: json['doctor'],
      note: json['note'],
      fileUrl: json['file_url'],
      createdAt: DateTime.parse(json['created_at']),
      delegateId: json['delegate_id'],
      studentId: json['student_id'],
      groupId: json['group_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'doctor': doctor,
      'note': note,
      'file_url': fileUrl,
      'created_at': createdAt.toIso8601String(),
      'delegate_id': delegateId,
      'student_id': studentId,
      'group_id': groupId,
    };
  }
}
