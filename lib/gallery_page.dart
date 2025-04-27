import 'package:flutter/material.dart';

class GalleryPage extends StatelessWidget {
  final List<Map<String, String>> memes;
  final Function(int) onDelete;

  const GalleryPage({required this.memes, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Galeria zapisanych memów'),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          memes.isEmpty
              ? Center(child: Text('Brak zapisanych memów 😢'))
              : ListView.builder(
                itemCount: memes.length,
                itemBuilder: (context, index) {
                  final meme = memes[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(meme['url']!),
                        ),
                        ListTile(
                          title: Text(meme['title'] ?? ''),
                          subtitle: Text(
                            'Autor: ${meme['author']} • r/${meme['subreddit']}',
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              onDelete(index);
                              Navigator.pop(
                                context,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
