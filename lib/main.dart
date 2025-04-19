import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

// Screens
import 'screens/splash_screen.dart';
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
import 'screens/question_forum_screen.dart';
import 'screens/upload_book_screen.dart';
import 'screens/upload_paper_screen.dart';
import 'screens/manage_teachers_screen.dart';
import 'screens/manage_students_screen.dart';
import 'screens/app_settings_screen.dart';
import 'screens/admin_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/selectRole': (context) => const RoleSelectorScreen(),
        '/adminDashboard': (context) => const AdminDashboard(),
        '/teacherDashboard': (context) => const TeacherDashboard(),
        '/studentDashboard': (context) => const StudentDashboard(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        // Remove const from BooksScreen route
        '/books': (context) => BooksScreen(),
        '/pastPapers': (context) => PastPapersScreen(),
        '/revision': (context) => const RevisionScreen(),
        '/uploadBook': (context) => const UploadBookScreen(),
        '/uploadPaper': (context) => const UploadPaperScreen(),
        '/forum': (context) => const QuestionForumScreen(),
        '/manageTeachers': (context) => const ManageTeachersScreen(),
        '/manageStudents': (context) => const ManageStudentsScreen(),
        '/settings': (context) => const AppSettingsScreen(),
        '/adminProfile': (context) => const AdminProfileScreen(),
      },
    );
  }
}
