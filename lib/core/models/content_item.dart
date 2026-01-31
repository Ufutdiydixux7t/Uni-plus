class ContentItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String fileName;
  final String? filePath; // Nullable as per requirements
  final String uploaderName;
  final DateTime date;

  ContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.fileName,
    this.filePath,
    required this.uploaderName,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'fileName': fileName,
      'filePath': filePath,
      'uploaderName': uploaderName,
      'date': date.toIso8601String(),
    };
  }

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      fileName: json['fileName'],
      filePath: json['filePath'],
      uploaderName: json['uploaderName'],
      date: DateTime.parse(json['date']),
    );
  }
}
