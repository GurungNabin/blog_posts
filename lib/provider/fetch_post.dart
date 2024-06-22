
import 'package:blog_posts/model/blog_model.dart';
import 'package:blog_posts/repository/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FetchPosts {
  final ApiProvider _apiProvider = ApiProvider();

  Future<List<Post>> fetchPosts(BuildContext context) async {
    try {
      return await _apiProvider.fetchPosts();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching posts: $e');
      }
      _showErrorDialog(context);
      return [];
    }
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text('Failed to load posts. Please try again later.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
