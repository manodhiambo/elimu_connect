// packages/app/lib/services/sync_service.dart
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_service.dart';
import 'storage_service.dart';

class SyncService {
  final ApiService _apiService;
  final StorageService _storageService;
  final Connectivity _connectivity = Connectivity();
  
  SyncService({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;
  
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _periodicSyncTimer;
  bool _isSyncing = false;
  
  // Stream controllers for sync events
  final StreamController<SyncEvent> _syncEventController =
      StreamController<SyncEvent>.broadcast();
  
  Stream<SyncEvent> get syncEvents => _syncEventController.stream;
  
  Future<void> initialize() async {
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        if (result != ConnectivityResult.none) {
          _onConnectivityRestored();
        }
      },
    );
    
    // Start periodic sync when online
    _startPeriodicSync();
    
    print('🔄 SyncService initialized');
  }
  
  void _startPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _performBackgroundSync(),
    );
  }
  
  Future<void> _onConnectivityRestored() async {
    await Future.delayed(const Duration(seconds: 2)); // Wait for stable connection
    await performFullSync();
  }
  
  Future<void> _performBackgroundSync() async {
    if (!await _isOnline()) return;
    await _syncPendingActions();
  }
  
  Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
  
  Future<SyncResult> performFullSync() async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        message: 'Sync already in progress',
      );
    }
    
    if (!await _isOnline()) {
      return SyncResult(
        success: false,
        message: 'No internet connection',
      );
    }
    
    _isSyncing = true;
    _syncEventController.add(SyncEvent.started());
    
    try {
      final results = <String, bool>{};
      
      // Sync user profile
      final profileResult = await _syncUserProfile();
      results['profile'] = profileResult;
      
      // Sync content
      final contentResult = await _syncContent();
      results['content'] = contentResult;
      
      // Sync pending actions (uploads, quiz answers, etc.)
      final actionsResult = await _syncPendingActions();
      results['actions'] = actionsResult;
      
      // Sync notifications
      final notificationsResult = await _syncNotifications();
      results['notifications'] = notificationsResult;
      
      // Update last sync time
      await _storageService.setLastSyncTime(DateTime.now());
      
      final allSuccessful = results.values.every((result) => result);
      
      _syncEventController.add(
        allSuccessful 
          ? SyncEvent.completed()
          : SyncEvent.failed('Some items failed to sync'),
      );
      
      return SyncResult(
        success: allSuccessful,
        message: allSuccessful 
          ? 'All data synced successfully'
          : 'Some items failed to sync',
        details: results,
      );
      
    } catch (e) {
      _syncEventController.add(SyncEvent.failed(e.toString()));
      return SyncResult(
        success: false,
        message: 'Sync failed: $e',
      );
    } finally {
      _isSyncing = false;
    }
  }
  
  Future<bool> _syncUserProfile() async {
    try {
      final response = await _apiService.getUserProfile();
      if (response.isSuccess && response.data != null) {
        await _storageService.saveUserProfile(response.data!);
        return true;
      }
      return false;
    } catch (e) {
      print('Profile sync failed: $e');
      return false;
    }
  }
  
  Future<bool> _syncContent() async {
    try {
      // Sync new content
      final response = await _apiService.getContent(limit: 50);
      if (response.isSuccess && response.data != null) {
        for (final content in response.data!) {
          final contentId = content['id'].toString();
          await _storageService.saveOfflineContent(contentId, content);
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Content sync failed: $e');
      return false;
    }
  }
  
  Future<bool> _syncPendingActions() async {
    try {
      // Get pending actions from local storage
      final pendingActions = await _storageService.getCache<List<dynamic>>('pending_actions') ?? [];
      
      final List<Map<String, dynamic>> actionsToRemove = [];
      
      for (final action in pendingActions) {
        final actionMap = action as Map<String, dynamic>;
        final success = await _executePendingAction(actionMap);
        
        if (success) {
          actionsToRemove.add(actionMap);
        }
      }
      
      // Remove successfully synced actions
      if (actionsToRemove.isNotEmpty) {
        final remainingActions = pendingActions
            .where((action) => !actionsToRemove.contains(action))
            .toList();
        await _storageService.saveCache('pending_actions', remainingActions);
      }
      
      return true;
    } catch (e) {
      print('Pending actions sync failed: $e');
      return false;
    }
  }
  
  Future<bool> _executePendingAction(Map<String, dynamic> action) async {
    try {
      final type = action['type'] as String;
      final data = action['data'] as Map<String, dynamic>;
      
      switch (type) {
        case 'quiz_answer':
          final response = await _apiService.submitQuizAnswer(
            quizId: data['quiz_id'],
            questionId: data['question_id'],
            answer: data['answer'],
          );
          return response.isSuccess;
          
        case 'profile_update':
          final response = await _apiService.updateUserProfile(data);
          return response.isSuccess;
          
        // Add more action types as needed
        default:
          print('Unknown pending action type: $type');
          return false;
      }
    } catch (e) {
      print('Failed to execute pending action: $e');
      return false;
    }
  }
  
  Future<bool> _syncNotifications() async {
    try {
      // This would typically sync with a push notification service
      // For now, we'll just mark it as successful
      return true;
    } catch (e) {
      print('Notifications sync failed: $e');
      return false;
    }
  }
  
  // Queue actions for later sync when offline
  Future<void> queueAction({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final pendingActions = await _storageService.getCache<List<dynamic>>('pending_actions') ?? [];
    
    final newAction = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    pendingActions.add(newAction);
    await _storageService.saveCache('pending_actions', pendingActions);
    
    print('🔄 Queued action for sync: $type');
    
    // Try to sync immediately if online
    if (await _isOnline()) {
      await _syncPendingActions();
    }
  }
  
  Future<List<Map<String, dynamic>>> getPendingActions() async {
    final actions = await _storageService.getCache<List<dynamic>>('pending_actions') ?? [];
    return actions.cast<Map<String, dynamic>>();
  }
  
  Future<void> clearPendingActions() async {
    await _storageService.clearCache('pending_actions');
  }
  
  Future<DateTime?> getLastSyncTime() async {
    return await _storageService.getLastSyncTime();
  }
  
  bool get isSyncing => _isSyncing;
  
  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicSyncTimer?.cancel();
    _syncEventController.close();
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
    return 'SyncResult(success: $success, message: $message, details: $details)';
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
