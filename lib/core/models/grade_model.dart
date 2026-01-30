class Grade {
  final String id;
  final String? groupId;
  final String? studentId;
  final String subject;
  final String? doctor;
  final String? note;
  final String? fileUrl;
  final DateTime createdAt;
  final String? createdBy; // New field

  Grade({
    required this.id,
    this.groupId,
    this.studentId,
    required this.subject,
    this.doctor,
    this.note,
    this.fileUrl,
    required this.createdAt,
    this.createdBy, // Initialize new field
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'],
      groupId: json['group_id'],
      studentId: json['student_id'],
      subject: json['subject'] ?? '',
      doctor: json['doctor'],
      note: json['note'],
      fileUrl: json['file_url'],
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'], // Map new field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'student_id': studentId,
      'subject': subject,
      'doctor': doctor,
      'note': note,
      'file_url': fileUrl,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy, // Include new field
    };
  }
}
