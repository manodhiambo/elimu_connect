import 'dart:io';
import 'package:dotenv/dotenv.dart';

class AppConfig {
  static late DotEnv _env;
  
  static Future<void> load() async {
    _env = DotEnv(includePlatformEnvironment: true);
    
    // Try to load .env file if it exists
    final envFile = File('.env');
    if (await envFile.exists()) {
      _env.load(['.env']);
    }
  }
  
  // Server Configuration
  static int get port => int.tryParse(_env['PORT'] ?? '8080') ?? 8080;
  static String get environment => _env['APP_ENV'] ?? 'development';
  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
  static String get appUrl => _env['APP_URL'] ?? 'http://localhost:8080';
  
  // Database Configuration
  static String get databaseUrl => 
      _env['DATABASE_URL'] ?? 'mongodb://localhost:27017/elimuconnect';
  static String get redisUrl => 
      _env['REDIS_URL'] ?? 'redis://localhost:6379';
  
  // JWT Configuration
  static String get jwtSecret => 
      _env['JWT_SECRET'] ?? 'your-super-secret-jwt-key';
  static String get jwtExpiresIn => _env['JWT_EXPIRES_IN'] ?? '24h';
  static String get jwtRefreshExpiresIn => 
      _env['JWT_REFRESH_EXPIRES_IN'] ?? '7d';
  
  // File Storage Configuration
  static String get minioEndpoint => _env['MINIO_ENDPOINT'] ?? 'localhost:9000';
  static String get minioAccessKey => _env['MINIO_ACCESS_KEY'] ?? 'minioadmin';
  static String get minioSecretKey => _env['MINIO_SECRET_KEY'] ?? 'minioadmin';
  static String get minioBucketName => 
      _env['MINIO_BUCKET_NAME'] ?? 'elimuconnect-files';
  static bool get minioUseSSL => 
      _env['MINIO_USE_SSL']?.toLowerCase() == 'true';
  
  // Email Configuration
  static String get smtpHost => _env['SMTP_HOST'] ?? 'localhost';
  static int get smtpPort => int.tryParse(_env['SMTP_PORT'] ?? '1025') ?? 1025;
  static String get smtpUser => _env['SMTP_USER'] ?? '';
  static String get smtpPass => _env['SMTP_PASS'] ?? '';
  static String get fromEmail => 
      _env['FROM_EMAIL'] ?? 'noreply@elimuconnect.co.ke';
  
  // Admin Configuration
  static String get adminRegistrationCode => 
      _env['ADMIN_REGISTRATION_CODE'] ?? 'OnlyMe@2025';
  
  // Security Configuration
  static int get rateLimitRequests => 
      int.tryParse(_env['RATE_LIMIT_REQUESTS'] ?? '100') ?? 100;
  static int get rateLimitWindow => 
      int.tryParse(_env['RATE_LIMIT_WINDOW'] ?? '900') ?? 900;
  static int get bcryptRounds => 
      int.tryParse(_env['BCRYPT_ROUNDS'] ?? '12') ?? 12;
  
  // Third-party Services
  static String get agoraAppId => _env['AGORA_APP_ID'] ?? '';
  static String get agoraCertificate => _env['AGORA_APP_CERTIFICATE'] ?? '';
  static String get firebaseProjectId => _env['FIREBASE_PROJECT_ID'] ?? '';
  static String get knecApiKey => _env['KNEC_API_KEY'] ?? '';
  static String get nemisApiKey => _env['NEMIS_API_KEY'] ?? '';
}
