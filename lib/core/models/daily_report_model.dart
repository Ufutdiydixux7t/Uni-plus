class DailyReport {
  final String id;
  final String subject;
  final String? doctor;
  final String? room;
  final String? day;
  final String? fileUrl;
  final DateTime createdAt;
  final String? delegateId; // بناءً على الخطأ The getter 'delegateId' isn't defined

  DailyReport({
    required this.id,
    required this.subject,
    this.doctor,
    this.room,
    this.day,
    this.fileUrl,
    required this.createdAt,
    this.delegateId,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      id: json['id'],
      subject: json['subject'] ?? '',
      doctor: json['doctor'],
      room: json['room'],
      day: json['day'],
      fileUrl: json['file_url'],
      createdAt: DateTime.parse(json['created_at']),
      delegateId: json['delegate_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'doctor': doctor,
      'room': room,
      'day': day,
      'file_url': fileUrl,
      'created_at': createdAt.toIso8601String(),
      'delegate_id': delegateId,
    };
  }
}
