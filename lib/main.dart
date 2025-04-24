import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import your screens
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/role_selector_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/teacher_dashboard.dart';
import 'screens/student_dashboard.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/books_screen.dart';
import 'screens/past_papers_screen.dart';
import 'screens/revision_screen.dart';
import 'screens/upload_book_screen.dart';
import 'screens/upload_paper_screen.dart';
import 'screens/question_forum_screen.dart';
import 'screens/manage_teachers_screen.dart';
import 'screens/manage_students_screen.dart';
import 'screens/app_settings_screen.dart';
import 'screens/admin_profile_screen.dart';
import 'screens/student_inbox_screen.dart';
import 'screens/chat_screen.dart';

// Import your app theme
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ElimuConnectApp());
}

class ElimuConnectApp extends StatelessWidget {
  const ElimuConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ElimuConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/selectRole': (context) => RoleSelectorScreen(),
        '/adminDashboard': (context) => AdminDashboard(),
        '/teacherDashboard': (context) => TeacherDashboard(),
        '/studentDashboard': (context) => StudentDashboard(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/books': (context) => BooksScreen(),
        '/pastPapers': (context) => PastPapersScreen(),
        '/revision': (context) => RevisionScreen(),
        '/uploadBook': (context) => UploadBookScreen(),
        '/uploadPaper': (context) => UploadPaperScreen(),
        '/forum': (context) => QuestionForumScreen(),
        '/manageTeachers': (context) => ManageTeachersScreen(),
        '/manageStudents': (context) => ManageStudentsScreen(),
        '/settings': (context) => AppSettingsScreen(),
        '/adminProfile': (context) => AdminProfileScreen(),
        '/studentInbox': (context) => StudentInboxScreen(),
      },
      // Dynamic route handler for chat
      onGenerateRoute: (settings) {
        if (settings.name == '/chat') {
          final args = settings.arguments as Map<String, dynamic>?;

          if (args != null &&
              args.containsKey('userId') &&
              args.containsKey('userName') &&
              args.containsKey('threadId')) {
            return MaterialPageRoute(
              builder: (context) => ChatScreen(
                userId: args['userId'],
                userName: args['userName'],
                threadId: args['threadId'], // Add threadId here
              ),
            );
          }

          // Fallback for missing args
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(
                child: Text('Chat screen requires userId, userName, and threadId arguments.'),
              ),
            ),
          );
        }

        return null; // Default fallback (could be a 404 screen)
      },
    );
  }
}
