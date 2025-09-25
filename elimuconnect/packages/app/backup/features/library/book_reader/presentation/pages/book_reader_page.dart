// packages/app/lib/src/features/library/book_reader/presentation/pages/book_reader_page.dart
class BookReaderPage extends ConsumerWidget {
  final String bookId;
  
  const BookReaderPage({Key? key, required this.bookId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(bookProvider(bookId));
    
    return book.when(
      data: (book) => Scaffold(
        appBar: AppBar(
          title: Text(book.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark),
              onPressed: () => _addBookmark(ref, bookId),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showReaderSettings(context),
            ),
          ],
        ),
        body: PdfViewer(
          filePath: book.filePath,
          onPageChanged: (page) => _updateReadingProgress(ref, bookId, page),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showTableOfContents(context, book),
          child: const Icon(Icons.list),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorWidget.withDetails(
        message: 'Failed to load book: $error',
      ),
    );
  }
}
