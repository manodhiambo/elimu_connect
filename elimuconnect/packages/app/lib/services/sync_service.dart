// packages/app/lib/services/sync_service.dart
// Minimal sync service stub - no external dependencies

import 'api_service.dart';
import 'storage_service.dart';

class SyncService {
  final ApiService _apiService;
  final StorageService _storageService;
  
  SyncService({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;
  
  Future<void> initialize() async {
    print('SyncService initialized (stub version)');
  }
  
  Future<SyncResult> performFullSync() async {
    // Stub implementation - will be replaced with proper sync later
    print('Performing sync (stub)');
    
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate sync
    
    return SyncResult(
      success: true,
      message: 'Sync completed (stub version)',
    );
  }
  
  Future<void> queueAction({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    print('Queued action: $type (stub)');
  }
  
  Future<List<Map<String, dynamic>>> getPendingActions() async {
    return []; // No pending actions in stub
  }
  
  Future<void> clearPendingActions() async {
    print('Cleared pending actions (stub)');
  }
  
  Future<DateTime?> getLastSyncTime() async {
    return DateTime.now().subtract(const Duration(hours: 1)); // Stub time
  }
  
  bool get isSyncing => false;
  
  void dispose() {
    print('SyncService disposed');
  }
}

class SyncResult {
  final bool success;
  final String message;
  final Map<String, bool>? details;
  
  SyncResult({
    required this.success,
    required this.message,
    this.details,
  });
  
  @override
  String toString() {
    return 'SyncResult(success: $success, message: $message)';
  }
}

class SyncEvent {
  final SyncEventType type;
  final String? message;
  final DateTime timestamp;
  
  SyncEvent._(this.type, this.message) : timestamp = DateTime.now();
  
  factory SyncEvent.started() => SyncEvent._(SyncEventType.started, null);
  factory SyncEvent.progress(String message) => SyncEvent._(SyncEventType.progress, message);
  factory SyncEvent.completed() => SyncEvent._(SyncEventType.completed, null);
  factory SyncEvent.failed(String error) => SyncEvent._(SyncEventType.failed, error);
  
  @override
  String toString() {
    return 'SyncEvent(type: $type, message: $message, timestamp: $timestamp)';
  }
}

enum SyncEventType {
  started,
  progress,
  completed,
  failed,
}
