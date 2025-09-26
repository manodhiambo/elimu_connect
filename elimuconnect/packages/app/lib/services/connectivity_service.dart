// File: packages/app/lib/src/services/connectivity_service.dart

import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

enum ConnectionQuality {
  none,
  poor,
  moderate,
  good,
  excellent,
}

enum ConnectionType {
  none,
  wifi,
  mobile,
  ethernet,
  bluetooth,
  vpn,
  other,
}

class ConnectionStatus {
  final bool isConnected;
  final ConnectionType type;
  final ConnectionQuality quality;
  final String? networkName;
  final double? speedMbps;
  final DateTime timestamp;

  const ConnectionStatus({
    required this.isConnected,
    required this.type,
    required this.quality,
    this.networkName,
    this.speedMbps,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'ConnectionStatus(connected: $isConnected, type: $type, quality: $quality, speed: ${speedMbps?.toStringAsFixed(1) ?? 'unknown'} Mbps)';
  }
}

class ConnectivityService {
  final Connectivity _connectivity;
  late StreamController<ConnectionStatus> _connectionController;
  ConnectionStatus? _lastStatus;
  Timer? _speedTestTimer;
  Timer? _connectionCheckTimer;

  ConnectivityService(this._connectivity) {
    _connectionController = StreamController<ConnectionStatus>.broadcast();
    _initializeConnectivityListener();
  }

  /// Get stream of connectivity status changes
  Stream<ConnectionStatus> get onConnectivityChanged => _connectionController.stream;

  /// Get current connectivity status
  Future<ConnectionStatus> getCurrentStatus() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final status = await _buildConnectionStatus(connectivityResult);
    _lastStatus = status;
    return status;
  }

  /// Check if device has internet connection
  Future<bool> hasConnection() async {
    final status = await getCurrentStatus();
    return status.isConnected;
  }

  /// Check internet connectivity by trying to reach a reliable server
  Future<bool> hasInternetConnection() async {
    if (!await hasConnection()) {
      return false;
    }

    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('Internet connectivity check failed: $e');
      }
      return false;
    }
  }

  /// Test connection speed
  Future<double?> testConnectionSpeed() async {
    if (!await hasConnection()) {
      return null;
    }

    try {
      // Simple speed test by downloading a small file
      final stopwatch = Stopwatch()..start();
      
      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('https://httpbin.org/bytes/1024'), // 1KB test
      );
      request.headers.add('Cache-Control', 'no-cache');
      
      final response = await request.close().timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final bytes = await response.fold<List<int>>(
          <int>[],
          (previous, element) => previous..addAll(element),
        );
        
        stopwatch.stop();
        final timeInSeconds = stopwatch.elapsedMilliseconds / 1000.0;
        final speedMbps = (bytes.length * 8) / (timeInSeconds * 1000000); // Convert to Mbps
        
        client.close();
        return speedMbps;
      }
      
      client.close();
      return null;
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('Speed test failed: $e');
      }
      return null;
    }
  }

  /// Get connection quality based on speed
  ConnectionQuality _getQualityFromSpeed(double? speedMbps) {
    if (speedMbps == null) return ConnectionQuality.poor;
    
    if (speedMbps >= 25) return ConnectionQuality.excellent;
    if (speedMbps >= 10) return ConnectionQuality.good;
    if (speedMbps >= 3) return ConnectionQuality.moderate;
    if (speedMbps >= 0.5) return ConnectionQuality.poor;
    return ConnectionQuality.none;
  }

  /// Start monitoring connection quality
  void startQualityMonitoring({Duration interval = const Duration(minutes: 5)}) {
    _speedTestTimer?.cancel();
    _speedTestTimer = Timer.periodic(interval, (timer) async {
      if (await hasConnection()) {
        final speed = await testConnectionSpeed();
        final connectivityResult = await _connectivity.checkConnectivity();
        final status = await _buildConnectionStatus(connectivityResult, speedMbps: speed);
        
        if (_shouldNotifyStatusChange(status)) {
          _lastStatus = status;
          _connectionController.add(status);
        }
      }
    });
  }

  /// Stop monitoring connection quality
  void stopQualityMonitoring() {
    _speedTestTimer?.cancel();
    _speedTestTimer = null;
  }

  /// Start periodic connection checks
  void startConnectionMonitoring({Duration interval = const Duration(seconds: 30)}) {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = Timer.periodic(interval, (timer) async {
      final status = await getCurrentStatus();
      
      if (_shouldNotifyStatusChange(status)) {
        _lastStatus = status;
        _connectionController.add(status);
      }
    });
  }

  /// Stop periodic connection checks
  void stopConnectionMonitoring() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = null;
  }

  /// Check if device is on WiFi
  Future<bool> isWiFiConnected() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult == ConnectivityResult.wifi;
  }

  /// Check if device is on mobile data
  Future<bool> isMobileConnected() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult == ConnectivityResult.mobile;
  }

  /// Check if connection is metered (mobile data or limited WiFi)
  Future<bool> isConnectionMetered() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    
    // Mobile connections are typically metered
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    }
    
    // For WiFi, we can't easily determine if it's metered
    // In a production app, you might check network info or user settings
    return false;
  }

  /// Get WiFi network name (SSID) - Android only
  Future<String?> getWiFiName() async {
    try {
      if (!await isWiFiConnected()) return null;
      
      // Note: Getting WiFi SSID requires additional permissions on Android
      // This is a simplified version - in production, you'd use wifi_info_flutter package
      return 'WiFi Network'; // Placeholder
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('Failed to get WiFi name: $e');
      }
      return null;
    }
  }

  /// Get estimated data usage for different quality levels
  Map<String, double> getEstimatedDataUsage({
    Duration duration = const Duration(hours: 1),
  }) {
    // Estimated data usage in MB per hour for different content types
    return {
      'text_browsing': 5.0,
      'image_browsing': 25.0,
      'video_low_quality': 150.0,
      'video_standard_quality': 300.0,
      'video_high_quality': 750.0,
      'video_4k_quality': 2250.0,
      'file_downloads': 50.0,
      'voice_calls': 0.5,
      'video_calls': 150.0,
    };
  }

  /// Get recommended quality settings based on connection
  Future<Map<String, dynamic>> getRecommendedSettings() async {
    final status = _lastStatus;
    if (status == null) {
      return {
        'video_quality': 'auto',
        'image_quality': 'medium',
        'auto_download': false,
        'background_sync': false,
      };
    }

    final isMetered = await isConnectionMetered();

    switch (status.quality) {
      case ConnectionQuality.excellent:
        return {
          'video_quality': 'high',
          'image_quality': 'high',
          'auto_download': true,
          'background_sync': true,
          'preload_content': true,
        };
      case ConnectionQuality.good:
        return {
          'video_quality': 'medium',
          'image_quality': 'high',
          'auto_download': !isMetered,
          'background_sync': true,
          'preload_content': false,
        };
      case ConnectionQuality.moderate:
        return {
          'video_quality': 'low',
          'image_quality': 'medium',
          'auto_download': false,
          'background_sync': false,
          'preload_content': false,
        };
      case ConnectionQuality.poor:
        return {
          'video_quality': 'disabled',
          'image_quality': 'low',
          'auto_download': false,
          'background_sync': false,
          'preload_content': false,
          'offline_mode_suggested': true,
        };
      case ConnectionQuality.none:
        return {
          'video_quality': 'disabled',
          'image_quality': 'cached_only',
          'auto_download': false,
          'background_sync': false,
          'offline_mode': true,
        };
    }
  }

  /// Dispose resources
  void dispose() {
    _speedTestTimer?.cancel();
    _connectionCheckTimer?.cancel();
    _connectionController.close();
  }

  // Private methods

  void _initializeConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) async {
      final status = await _buildConnectionStatus(result);
      
      if (_shouldNotifyStatusChange(status)) {
        _lastStatus = status;
        _connectionController.add(status);
        
        if (AppConfig.isDebugMode) {
          print('🌐 Connectivity changed: $status');
        }
      }
    });
  }

  Future<ConnectionStatus> _buildConnectionStatus(
    ConnectivityResult result, {
    double? speedMbps,
  }) async {
    final type = _mapConnectivityResult(result);
    final isConnected = type != ConnectionType.none;
    
    // If speed is not provided and we're connected, try to get it
    double? speed = speedMbps;
    if (isConnected && speed == null) {
      // Only test speed occasionally to avoid excessive network usage
      if (_shouldTestSpeed()) {
        speed = await testConnectionSpeed();
      }
    }
    
    final quality = isConnected ? _getQualityFromSpeed(speed) : ConnectionQuality.none;
    
    String? networkName;
    if (type == ConnectionType.wifi) {
      networkName = await getWiFiName();
    }

    return ConnectionStatus(
      isConnected: isConnected,
      type: type,
      quality: quality,
      networkName: networkName,
      speedMbps: speed,
      timestamp: DateTime.now(),
    );
  }

  ConnectionType _mapConnectivityResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectionType.wifi;
      case ConnectivityResult.mobile:
        return ConnectionType.mobile;
      case ConnectivityResult.ethernet:
        return ConnectionType.ethernet;
      case ConnectivityResult.bluetooth:
        return ConnectionType.bluetooth;
      case ConnectivityResult.vpn:
        return ConnectionType.vpn;
      case ConnectivityResult.other:
        return ConnectionType.other;
      case ConnectivityResult.none:
        return ConnectionType.none;
    }
  }

  bool _shouldNotifyStatusChange(ConnectionStatus newStatus) {
    if (_lastStatus == null) return true;
    
    final lastStatus = _lastStatus!;
    
    // Notify if connection state changed
    if (lastStatus.isConnected != newStatus.isConnected) return true;
    
    // Notify if connection type changed
    if (lastStatus.type != newStatus.type) return true;
    
    // Notify if quality changed significantly
    if (_getQualityLevel(lastStatus.quality) != _getQualityLevel(newStatus.quality)) {
      return true;
    }
    
    return false;
  }

  int _getQualityLevel(ConnectionQuality quality) {
    switch (quality) {
      case ConnectionQuality.none:
        return 0;
      case ConnectionQuality.poor:
        return 1;
      case ConnectionQuality.moderate:
        return 2;
      case ConnectionQuality.good:
        return 3;
      case ConnectionQuality.excellent:
        return 4;
    }
  }

  bool _shouldTestSpeed() {
    if (_lastStatus == null) return true;
    
    final timeSinceLastTest = DateTime.now().difference(_lastStatus!.timestamp);
    return timeSinceLastTest.inMinutes >= 5; // Test speed every 5 minutes max
  }
}

// Extension methods for easier usage
extension ConnectivityServiceExtensions on ConnectivityService {
  /// Check if suitable for video streaming
  Future<bool> isSuitableForVideoStreaming() async {
    final status = await getCurrentStatus();
    return status.quality == ConnectionQuality.good || 
           status.quality == ConnectionQuality.excellent;
  }

  /// Check if suitable for large file downloads
  Future<bool> isSuitableForLargeDownloads() async {
    final status = await getCurrentStatus();
    final isMetered = await isConnectionMetered();
    
    return !isMetered && (
      status.quality == ConnectionQuality.good || 
      status.quality == ConnectionQuality.excellent
    );
  }

  /// Check if should use offline mode
  Future<bool> shouldUseOfflineMode() async {
    final status = await getCurrentStatus();
    return !status.isConnected || status.quality == ConnectionQuality.poor;
  }

  /// Get user-friendly connection description
  Future<String> getConnectionDescription() async {
    final status = await getCurrentStatus();
    
    if (!status.isConnected) {
      return 'No internet connection';
    }
    
    String typeStr;
    switch (status.type) {
      case ConnectionType.wifi:
        typeStr = status.networkName != null ? 'WiFi (${status.networkName})' : 'WiFi';
        break;
      case ConnectionType.mobile:
        typeStr = 'Mobile data';
        break;
      case ConnectionType.ethernet:
        typeStr = 'Ethernet';
        break;
      default:
        typeStr = 'Internet';
    }
    
    String qualityStr;
    switch (status.quality) {
      case ConnectionQuality.excellent:
        qualityStr = 'Excellent';
        break;
      case ConnectionQuality.good:
        qualityStr = 'Good';
        break;
      case ConnectionQuality.moderate:
        qualityStr = 'Moderate';
        break;
      case ConnectionQuality.poor:
        qualityStr = 'Poor';
        break;
      case ConnectionQuality.none:
        qualityStr = 'No connection';
        break;
    }
    
    if (status.speedMbps != null) {
      return '$typeStr • $qualityStr (${status.speedMbps!.toStringAsFixed(1)} Mbps)';
    } else {
      return '$typeStr • $qualityStr';
    }
  }
}
