class TomorrowLecture {
  final String id;
  final String subject;
  final String? doctor;
  final String? room;
  final String? time;
  final DateTime createdAt;
  final String? delegateId; // بناءً على نمط Grade
  final String? groupId; // بناءً على نمط Grade

  TomorrowLecture({
    required this.id,
    required this.subject,
    this.doctor,
    this.room,
    this.time,
    required this.createdAt,
    this.delegateId,
    this.groupId,
  });

  factory TomorrowLecture.fromJson(Map<String, dynamic> json) {
    return TomorrowLecture(
      id: json['id'],
      subject: json['subject'] ?? '',
      doctor: json['doctor'],
      room: json['room'],
      time: json['time'],
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
      'room': room,
      'time': time,
      'created_at': createdAt.toIso8601String(),
      'delegate_id': delegateId,
      'groupId': groupId,
    };
  }
}
