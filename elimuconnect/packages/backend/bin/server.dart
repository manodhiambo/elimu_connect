import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
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
    // Create the router
    final router = Router();
    
    // Health check endpoint
    router.get('/health', (Request request) {
      return Response.ok('ElimuConnect API is running');
    });
    
    // API v1 routes
    router.get('/api/v1/status', (Request request) {
      return Response.ok('{"status": "ok", "message": "ElimuConnect API v1"}');
    });

    // Add middleware
    final handler = Pipeline()
        .addMiddleware(corsHeaders())
        .addMiddleware(logRequests())
        .addHandler(router);

    // Start the server
    final server = await serve(
      handler,
      InternetAddress.anyIPv4,
      8080,
    );

    logger.info('Server listening on port ${server.port}');
    logger.info('Health check: http://localhost:${server.port}/health');
    logger.info('API status: http://localhost:${server.port}/api/v1/status');
    
    // Handle graceful shutdown
    ProcessSignal.sigterm.watch().listen((signal) async {
      logger.info('Received SIGTERM, shutting down gracefully...');
      await server.close();
      exit(0);
    });

  } catch (e, stackTrace) {
    logger.severe('Failed to start server', e, stackTrace);
    exit(1);
  }
}
