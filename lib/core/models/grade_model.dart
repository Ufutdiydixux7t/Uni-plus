class Grade {
  final String id;
  final String subject;
  final String? doctor;
  final String? note;
  final String? fileUrl;
  final DateTime createdAt;
  final String? createdBy;

  Grade({
    required this.id,
    required this.subject,
    this.doctor,
    this.note,
    this.fileUrl,
    required this.createdAt,
    this.createdBy,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'],
      subject: json['subject'] ?? '',
      doctor: json['doctor'],
      note: json['note'],
      fileUrl: json['file_url'],
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
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
      'created_by': createdBy,
    };
  }
}
