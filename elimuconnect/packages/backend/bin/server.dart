import 'dart:io';
import 'package:elimuconnect_backend/backend.dart';
import 'package:elimuconnect_backend/src/config/app_config.dart';
import 'package:elimuconnect_backend/src/database/connection.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:logging/logging.dart';

Future<void> main(List<String> arguments) async {
  // Setup logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  final logger = Logger('Server');
  
  try {
    // Load configuration
    await AppConfig.load();
    logger.info('Configuration loaded');

    // Initialize database connection
    await DatabaseConnection.initialize();
    logger.info('Database connection established');

    // Create the router
    final router = createRouter();

    // Add middleware
    final handler = Pipeline()
        .addMiddleware(corsHeaders())
        .addMiddleware(logRequests())
        .addHandler(router);

    // Start the server
    final server = await serve(
      handler,
      InternetAddress.anyIPv4,
      AppConfig.port,
    );

    logger.info('Server listening on port ${server.port}');
    logger.info('Environment: ${AppConfig.environment}');
    
    // Handle graceful shutdown
    ProcessSignal.sigterm.watch().listen((signal) async {
      logger.info('Received SIGTERM, shutting down gracefully...');
      await server.close();
      await DatabaseConnection.close();
      exit(0);
    });

  } catch (e, stackTrace) {
    logger.severe('Failed to start server', e, stackTrace);
    exit(1);
  }
}
