import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/app.dart';
import 'src/core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Initialize app configuration
  await AppConfig.initialize();
  
  runApp(
    ProviderScope(
      child: ElimuConnectApp(),
    ),
  );
}
