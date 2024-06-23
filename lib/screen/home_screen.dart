import 'package:blog_posts/model/blog_model.dart';
import 'package:blog_posts/provider/data_provider.dart';
import 'package:blog_posts/screen/favorite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Post> _filteredPosts = [];

  @override
  void initState() {
    super.initState();
    final blogViewModel = ref.read(blogViewModelProvider);
    blogViewModel.fetchPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPosts(String query) {
    final blogViewModel = ref.read(blogViewModelProvider);
    setState(() {
      _filteredPosts = blogViewModel.filterPosts(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final blogViewModel = ref.watch(blogViewModelProvider);
    final blog = ref.watch(blogDataProvider);

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
                      builder: (context) => const FavoriteScreen(),
                    ),
                  );
                  await blogViewModel.fetchFavorites();
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
                    blogViewModel.favoritePosts.length.toString(),
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
              onChanged: _filterPosts,
            ),
          ),
          blog.when(
            data: (blogPosts) {
              if (_filteredPosts.isEmpty) {
                _filteredPosts = blogPosts;
              }
              return Expanded(
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
                                  blogViewModel.toggleFavorite(post);
                                },
                                icon: Icon(
                                  blogViewModel.favoritePosts.contains(post)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      blogViewModel.favoritePosts.contains(post)
                                          ? Colors.red
                                          : null,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              );
            },
            error: (e, s) => Text(e.toString()),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
