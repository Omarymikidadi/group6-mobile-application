import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const NewsApp());
}
class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NewsHomePage(),
    );
  }
}

/* =======================
   NEWS HOME PAGE
======================= */
class NewsHomePage extends StatefulWidget {
  const NewsHomePage({super.key});

  @override
  State<NewsHomePage> createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  late Future<List<NewsArticle>> futureNews;

  @override
  void initState() {
    super.initState();
    futureNews = fetchNews();
  }

  /* ======================= FETCH NEWS FROM API ======================= */
  Future<List<NewsArticle>> fetchNews() async {
    const String apiKey = '0d26080dcaf04ecc8302670107ccafb9';

    final url = Uri.parse(
      'https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List articles = data['articles'];

      return articles
          .map((json) => NewsArticle.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load news');
    }
  }

  /* ======================= UI ======================= */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest News'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<NewsArticle>>(
        future: futureNews,
        builder: (context, snapshot) {

          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading news.\nPlease check your internet connection.',
                textAlign: TextAlign.center,
              ),
            );
          }

          // Success state
          final newsList = snapshot.data!;
          return ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // News Image
                    if (news.imageUrl.isNotEmpty)
                      Image.network(
                        news.imageUrl,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox();
                        },
                      ),

                    // Title
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        news.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(news.description),
                    ),

                    // Source & Date
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '${news.source} • ${news.publishedAt.substring(0, 10)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/* =======================
   NEWS MODEL
======================= */
class NewsArticle {
  final String title;
  final String description;
  final String imageUrl;
  final String source;
  final String publishedAt;

  NewsArticle({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      imageUrl: json['urlToImage'] ?? '',
      source: json['source']?['name'] ?? 'Unknown',
      publishedAt: json['publishedAt'] ?? '',
    );
  }
}
