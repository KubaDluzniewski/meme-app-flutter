import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'gallery_page.dart';

class MemePage extends StatefulWidget {
  @override
  _MemePageState createState() => _MemePageState();
}

class _MemePageState extends State<MemePage>
    with SingleTickerProviderStateMixin {
  String? memeUrl;
  String? title;
  String? subreddit;
  String? author;
  bool isLoading = false;

  List<Map<String, String>> savedMemes = [];
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    fetchMeme();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  Future<void> fetchMeme() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse('https://meme-api.com/gimme'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['nsfw'] == false) {
        setState(() {
          memeUrl = data['url'];
          title = data['title'];
          subreddit = data['subreddit'];
          author = data['author'];
        });
        _controller.forward(from: 0);
      } else {
        fetchMeme();
      }
    } else {
      throw Exception('Nie udało się załadować mema');
    }

    setState(() {
      isLoading = false;
    });
  }

  void saveCurrentMeme() {
    if (memeUrl != null) {
      setState(() {
        savedMemes.add({
          'url': memeUrl!,
          'title': title ?? '',
          'author': author ?? '',
          'subreddit': subreddit ?? '',
        });
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Mem zapisany do galerii!')));
    }
  }

  void saveMemeToFile() async {
    if (memeUrl != null) {
      try {
        // Pobierz obrazek z internetu
        final file = await DefaultCacheManager().getSingleFile(memeUrl!);

        // Pobierz ścieżkę do katalogu w urządzeniu
        final directory = await getApplicationDocumentsDirectory();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedFile = await file.copy('${directory.path}/$fileName');

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Mem zapisany do pliku!')));

        print('Mem zapisany: ${savedFile.path}');
      } catch (e) {
        print("Błąd zapisywania mema: $e");
      }
    }
  }

  void openGallery() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => GalleryPage(
              memes: savedMemes,
              onDelete: (index) {
                setState(() {
                  savedMemes.removeAt(index);
                });
              },
            ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Losowy Meme'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(onPressed: openGallery, icon: Icon(Icons.photo_library)),
        ],
      ),
      body: Center(
        child:
            isLoading
                ? CircularProgressIndicator(color: Colors.deepPurple)
                : memeUrl == null
                ? Text('Brak mema do pokazania')
                : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title ?? '',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(memeUrl!),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Autor: ${author ?? ""}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Subreddit: r/${subreddit ?? ""}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: fetchMeme,
                        icon: Icon(Icons.refresh),
                        label: Text('Losuj nowego mema'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: saveCurrentMeme,
                        icon: Icon(Icons.favorite_border),
                        label: Text('Dodaj do ulubionych'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: saveMemeToFile,
                        icon: Icon(Icons.save_alt),
                        label: Text('Zapisz do pliku'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
