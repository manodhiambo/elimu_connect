// packages/app/lib/src/features/library/offline_sync/presentation/pages/offline_sync_page.dart
class OfflineSyncPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(offlineSyncProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Content'),
      ),
      body: Column(
        children: [
          SyncStatusCard(status: syncStatus),
          _buildStorageInfo(context, ref),
          _buildDownloadQueue(context, ref),
          _buildOfflineContent(context, ref),
        ],
      ),
    );
  }
}
