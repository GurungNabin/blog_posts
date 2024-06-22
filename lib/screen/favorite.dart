import 'package:blog_posts/model/blog_model.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class FavoriteList extends StatefulWidget {
  final Database database;

  const FavoriteList({super.key, required this.database});

  @override
  State<FavoriteList> createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList> {
  List<Post> _favoritePosts = [];

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    final List<Map<String, dynamic>> favorites =
        await widget.database.query('favorites');
    setState(() {
      _favoritePosts = favorites
          .map((fav) => Post(
                id: fav['id'],
                title: fav['title'],
                body: fav['body'],
              ))
          .toList();
    });
  }

  Future<void> _removeFromFavorites(int index) async {
    final post = _favoritePosts[index];
    await widget.database
        .delete('favorites', where: 'id = ?', whereArgs: [post.id]);
    setState(() {
      _favoritePosts.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Blog removed'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite List'),
      ),
      body: _favoritePosts.isEmpty
          ? Center(
              child: Text(
                'No favorite posts yet.',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            )
          : ListView.builder(
              itemCount: _favoritePosts.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      _favoritePosts[index].title,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      _favoritePosts[index].body,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        _removeFromFavorites(index);
                      },
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
