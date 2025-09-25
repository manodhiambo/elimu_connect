// packages/app/lib/src/features/communication/messaging/presentation/pages/messages_page.dart
class MessagesPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: conversations.when(
        data: (conversationList) => ListView.builder(
          itemCount: conversationList.length,
          itemBuilder: (context, index) => ConversationTile(
            conversation: conversationList[index],
            onTap: () => _openChat(context, conversationList[index]),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorWidget.withDetails(message: error.toString()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startNewConversation(context),
        child: const Icon(Icons.message),
      ),
    );
  }
}
