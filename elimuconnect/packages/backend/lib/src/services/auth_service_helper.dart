import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

// Helper function to generate unique IDs without external UUID dependency
String generateId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (i) => random.nextInt(256));
  return base64UrlEncode(bytes).replaceAll('=', '').replaceAll('-', '').replaceAll('_', '');
}

// Alternative MongoDB ObjectId-like generator
String generateObjectId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final random = Random.secure();
  final randomBytes = List<int>.generate(8, (i) => random.nextInt(256));
  final timestampBytes = [
    (timestamp >> 24) & 0xFF,
    (timestamp >> 16) & 0xFF,
    (timestamp >> 8) & 0xFF,
    timestamp & 0xFF,
  ];
  final allBytes = [...timestampBytes, ...randomBytes];
  return allBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
}
