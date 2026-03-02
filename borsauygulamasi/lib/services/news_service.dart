import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news.dart';

class NewsService {
  final String apiKey =
      'e3d9e8f0c9b54cc6f68e92f9c8c51741'; // Buraya kendi key’in

  Future<List<News>> fetchUSBusinessNews() async {
    final url = Uri.parse(
      'https://gnews.io/api/v4/top-headlines?country=us&topic=business&lang=en&token=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch news: ${response.statusCode} - ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    final List articles = data['articles'] ?? [];

    return articles.map((item) => News.fromJson(item)).toList();
  }
}
