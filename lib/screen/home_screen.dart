import 'package:blog_posts/model/blog_model.dart';
import 'package:blog_posts/provider/fetch_post.dart';
import 'package:blog_posts/screen/favorite.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FetchPosts _fetchPostsInstance = FetchPosts();
  late Database _database;
  final TextEditingController _searchController = TextEditingController();
  List<Post> _posts = [];
  List<Post> _filteredPosts = [];
  List<Post> _favoritePosts = [];

  @override
  void initState() {
    super.initState();
    _openDatabase();
    _fetchPosts();
  }

  Future<void> _openDatabase() async {
    _database = await openDatabase(
      p.join(await getDatabasesPath(), 'favorites_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE favorites(id INTEGER PRIMARY KEY, title TEXT, body TEXT)',
        );
      },
      version: 1,
    );

    _fetchFavorites();
  }

  Future<void> _fetchPosts() async {
    List<Post> posts = await _fetchPostsInstance.fetchPosts(context);
    setState(() {
      _posts = posts;
      _filteredPosts = posts;
    });
  }

  Future<void> _fetchFavorites() async {
    final List<Map<String, dynamic>> favorites =
        await _database.query('favorites');
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

  void _toggleFavorite(Post post) async {
    if (_isFavorite(post)) {
      await _database
          .delete('favorites', where: 'id = ?', whereArgs: [post.id]);
      setState(() {
        _favoritePosts.removeWhere((favPost) => favPost.id == post.id);
      });
    } else {
      await _database.insert('favorites', post.toMap());
      setState(() {
        _favoritePosts.add(post);
      });
    }
  }

  bool _isFavorite(Post post) {
    return _favoritePosts.any((favPost) => favPost.id == post.id);
  }

  void _filterPosts(String query) {
    setState(() {
      _filteredPosts = _posts
          .where(
              (post) => post.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Blog List'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FavoriteScreen(
                        database: _database,
                      ),
                    ),
                  );
                  _fetchFavorites();
                },
                icon: const Icon(Icons.favorite),
              ),
              Positioned(
                top: 25,
                left: 5,
                child: CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 10.0,
                  child: Text(
                    _favoritePosts.length.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search blog...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onChanged: (value) {
                _filterPosts(value);
              },
            ),
          ),
          Expanded(
            child: _filteredPosts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = _filteredPosts[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                        ),
                        child: ListTile(
                          title: Text(
                            post.title,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            post.body,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              _toggleFavorite(post);
                            },
                            icon: Icon(
                              _isFavorite(post)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _isFavorite(post) ? Colors.red : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }
}
