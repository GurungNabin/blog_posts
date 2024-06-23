import 'package:blog_posts/model/blog_model.dart';
import 'package:blog_posts/model/view_model.dart';
import 'package:blog_posts/provider/fetch_post.dart';
import 'package:blog_posts/repository/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final blogApiProvider = Provider<ApiProvider>((ref) => ApiProvider());

final fetchPostsProvider = Provider<FetchPosts>((ref) {
  final api = ref.watch(blogApiProvider);
  return FetchPosts(apiProvider: api);
});

final blogViewModelProvider = ChangeNotifierProvider<BlogViewModel>((ref) {
  final fetchPosts = ref.watch(fetchPostsProvider);
  return BlogViewModel(
      fetchPosts: fetchPosts, apiProvider: fetchPosts.apiProvider);
});

final blogDataProvider = FutureProvider<List<Post>>((ref) async {
  final blogViewModel = ref.read(blogViewModelProvider);
  await blogViewModel.fetchPosts();
  return blogViewModel.posts;
});
