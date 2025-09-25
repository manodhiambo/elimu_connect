library elimuconnect_backend;

import 'package:shelf_router/shelf_router.dart';
import 'src/handlers/auth_handler.dart';
import 'src/handlers/user_handler.dart';
import 'src/handlers/content_handler.dart';
import 'src/handlers/assessment_handler.dart';
import 'src/handlers/messaging_handler.dart';
import 'src/handlers/school_handler.dart';
import 'src/middleware/auth_middleware.dart';

Router createRouter() {
  final router = Router();

  // Health check
  router.get('/health', (request) {
    return Response.ok('ElimuConnect API is running');
  });

  // API v1 routes
  router.mount('/api/v1/auth', AuthHandler().router);
  router.mount('/api/v1/users', UserHandler().router);
  router.mount('/api/v1/schools', SchoolHandler().router);
  router.mount('/api/v1/content', ContentHandler().router);
  router.mount('/api/v1/assessments', AssessmentHandler().router);
  router.mount('/api/v1/messages', MessagingHandler().router);

  return router;
}

export 'src/config/app_config.dart';
export 'src/database/connection.dart';
export 'src/services/services.dart';
export 'src/repositories/repositories.dart';
export 'src/middleware/middleware.dart';
export 'src/utils/utils.dart';
