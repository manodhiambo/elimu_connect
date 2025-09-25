import 'package:mongo_dart/mongo_dart.dart';
import 'package:redis/redis.dart';
import 'package:logging/logging.dart';
import '../config/app_config.dart';

class DatabaseConnection {
  static final _logger = Logger('DatabaseConnection');
  static late Db _mongoDb;
  static late Command _redisCommand;
  
  static Db get mongo => _mongoDb;
  static Command get redis => _redisCommand;
  
  static Future<void> initialize() async {
    await _initializeMongo();
    await _initializeRedis();
  }
  
  static Future<void> _initializeMongo() async {
    try {
      _mongoDb = await Db.create(AppConfig.databaseUrl);
      await _mongoDb.open();
      _logger.info('MongoDB connection established');
      
      // Create indexes
      await _createIndexes();
    } catch (e) {
      _logger.severe('Failed to connect to MongoDB: $e');
      rethrow;
    }
  }
  
  static Future<void> _initializeRedis() async {
    try {
      final conn = RedisConnection();
      _redisCommand = await conn.connect(
        AppConfig.redisUrl.split('://')[1].split('@').last.split(':')[0],
        int.parse(AppConfig.redisUrl.split(':').last),
      );
      _logger.info('Redis connection established');
    } catch (e) {
      _logger.severe('Failed to connect to Redis: $e');
      rethrow;
    }
  }
  
  static Future<void> _createIndexes() async {
    // Users collection indexes
    final usersCollection = _mongoDb.collection('users');
    await usersCollection.createIndex(key: 'email', unique: true);
    await usersCollection.createIndex(key: 'role');
    await usersCollection.createIndex(key: 'isActive');
    
    // Schools collection indexes
    final schoolsCollection = _mongoDb.collection('schools');
    await schoolsCollection.createIndex(key: 'nemisCode', unique: true);
    await schoolsCollection.createIndex(key: 'county');
    await schoolsCollection.createIndex(key: 'schoolType');
    
    // Content collection indexes
    final contentCollection = _mongoDb.collection('content');
    await contentCollection.createIndex(key: 'subject');
    await contentCollection.createIndex(key: 'gradeLevel');
    await contentCollection.createIndex(key: 'contentType');
    await contentCollection.createIndex(key: 'isPublished');
    
    // Messages collection indexes
    final messagesCollection = _mongoDb.collection('messages');
    await messagesCollection.createIndex(key: 'conversationId');
    await messagesCollection.createIndex(key: 'senderId');
    await messagesCollection.createIndex(key: 'timestamp');
    
    _logger.info('Database indexes created');
  }
  
  static Future<void> close() async {
    await _mongoDb.close();
    _logger.info('Database connections closed');
  }
}
