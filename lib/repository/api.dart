import 'package:blog_posts/model/blog_model.dart';
import 'package:dio/dio.dart';

class ApiProvider {
  final Dio _dio = Dio();

  Future<List<Post>> fetchPosts() async {
    try {
      final response = await _dio.get('https://dummyjson.com/posts');
      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        List<dynamic> postsJson = data['posts'];
        List<Post> posts = postsJson.map((json) => Post.fromMap(json)).toList();
        return posts;
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception('Failed to load posts');
    }
  }
}
