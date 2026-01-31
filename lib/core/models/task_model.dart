class Task {
  final String id;
  final String subject;
  final String? doctor;
  final String? note;
  final DateTime createdAt;
  final String? delegateId; // بناءً على نمط الجداول الأخرى
  final String? groupId; // بناءً على الخطأ المتكرر The named parameter 'groupId' isn't defined

  Task({
    required this.id,
    required this.subject,
    this.doctor,
    this.note,
    required this.createdAt,
    this.delegateId,
    this.groupId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      subject: json['subject'] ?? '',
      doctor: json['doctor'],
      note: json['note'],
      createdAt: DateTime.parse(json['created_at']),
      delegateId: json['delegate_id'],
      groupId: json['group_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'doctor': doctor,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'delegate_id': delegateId,
      'group_id': groupId,
    };
  }
}
