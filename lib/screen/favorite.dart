import 'package:blog_posts/provider/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteScreen extends ConsumerStatefulWidget {
  const FavoriteScreen({super.key});

  @override
  ConsumerState<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends ConsumerState<FavoriteScreen> {
  @override
  void initState() {
    super.initState();
    final blogViewModel = ref.read(blogViewModelProvider);
    blogViewModel.fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final blogViewModel = ref.watch(blogViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Favorite Posts'),
      ),
      body: blogViewModel.favoritePosts.isEmpty
          ? const Center(child: Text('No favorite posts yet.'))
          : ListView.builder(
              itemCount: blogViewModel.favoritePosts.length,
              itemBuilder: (context, index) {
                final post = blogViewModel.favoritePosts[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
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
                        blogViewModel.toggleFavorite(post);
                      },
                      icon: Icon(
                        blogViewModel.favoritePosts.contains(post)
                            ? Icons.delete
                            : Icons.favorite_border,
                        color: blogViewModel.favoritePosts.contains(post)
                            ? Colors.red
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
