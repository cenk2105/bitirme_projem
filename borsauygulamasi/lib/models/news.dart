class News {
  final String title;
  final String description;
  final DateTime pubDate;
  final String source;
  final String url;

  News({
    required this.title,
    required this.description,
    required this.pubDate,
    required this.source,
    required this.url,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      pubDate: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      source: json['source']?['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
