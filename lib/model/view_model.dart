
import 'package:blog_posts/model/blog_model.dart';
import 'package:blog_posts/model/database_helper.dart';
import 'package:blog_posts/provider/fetch_post.dart';
import 'package:blog_posts/repository/api.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class BlogViewModel extends ChangeNotifier {
  final ApiProvider _apiProvider;
  late Database _database;
  List<Post> _posts = [];
  List<Post> get posts => _posts;
  final List<Post> _favoritePosts = [];
  List<Post> get favoritePosts => _favoritePosts;

  BlogViewModel({
    required FetchPosts fetchPosts,
    required ApiProvider apiProvider,
  }) : _apiProvider = apiProvider {
    _initializeDatabase();
  }

  Database get database => _database;

  Future<void> _initializeDatabase() async {
    _database = await DatabaseHelper.initializeDatabase();
    await fetchFavorites();
  }

  Future<void> fetchPosts() async {
    try {
      List<Post> posts = await _apiProvider.fetchPosts();
      _posts = posts;
      notifyListeners();
    } catch (e) {
      _handleError('fetching posts', e);
    }
  }

  Future<void> toggleFavorite(Post post) async {
    try {
      if (_isFavorite(post)) {
        await _database.delete(
          'favorites',
          where: 'id = ?',
          whereArgs: [post.id],
        );
        _favoritePosts.removeWhere((favPost) => favPost.id == post.id);
      } else {
        await _database.insert('favorites', post.toMap());
        _favoritePosts.add(post);
      }
      notifyListeners();
    } catch (e) {
      _handleError('toggling favorite status', e);
    }
  }

  bool _isFavorite(Post post) {
    return _favoritePosts.any((favPost) => favPost.id == post.id);
  }

  Future<void> fetchFavorites() async {
    try {
      final List<Map<String, dynamic>> favorites = await _database.query('favorites');
      _favoritePosts.clear();
      _favoritePosts.addAll(favorites.map((fav) => Post.fromMap(fav)).toList());
      notifyListeners();
    } catch (e) {
      _handleError('fetching favorites', e);
    }
  }

  void _handleError(String action, Object e) {
    if (kDebugMode) {
      print('Error $action: $e');
    }
  }

  List<Post> filterPosts(String query) {
    return _posts
        .where((post) => post.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
