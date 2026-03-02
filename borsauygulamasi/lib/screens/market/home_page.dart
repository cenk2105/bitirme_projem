import 'package:borsauygulamasi/models/news.dart';
import 'package:borsauygulamasi/services/news_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final NewsService _service = NewsService();
  late Future<List<News>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = _service.fetchUSBusinessNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ABD Borsa Haberleri')),
      body: FutureBuilder<List<News>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Haber bulunamadı'));
          }

          final newsList = snapshot.data!;
          return ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(news.title),
                  subtitle: Text(
                    '${news.description}\nKaynak: ${news.source}\nTarih: ${news.pubDate.toLocal()}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () async {
                      final uri = Uri.parse(news.url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
