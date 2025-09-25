// packages/app/lib/src/features/library/content_browser/presentation/pages/content_browser_page.dart
class ContentBrowserPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(contentSearchProvider);
    final contents = ref.watch(contentListProvider(searchQuery));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              hintText: 'Search books, subjects, topics...',
              onChanged: (query) => ref.read(contentSearchProvider.notifier).state = query,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(context, ref),
          Expanded(
            child: contents.when(
              data: (contentList) => GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                ),
                itemCount: contentList.length,
                itemBuilder: (context, index) => ContentCard(
                  content: contentList[index],
                  onTap: () => _openContent(context, contentList[index]),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => ErrorWidget.withDetails(message: error.toString()),
            ),
          ),
        ],
      ),
    );
  }
}
