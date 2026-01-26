class ContentItem {
  final String id;
  final String title;
  final String description;
  final String category; // lectures, materials, summaries, etc.
  final String fileName;
  final String filePath;
  final DateTime date;
  final String uploaderName;

  ContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.fileName,
    required this.filePath,
    required this.date,
    required this.uploaderName,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'fileName': fileName,
    'filePath': filePath,
    'date': date.toIso8601String(),
    'uploaderName': uploaderName,
  };

  factory ContentItem.fromJson(Map<String, dynamic> json) => ContentItem(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    category: json['category'],
    fileName: json['fileName'],
    filePath: json['filePath'],
    date: DateTime.parse(json['date']),
    uploaderName: json['uploaderName'],
  );
}
