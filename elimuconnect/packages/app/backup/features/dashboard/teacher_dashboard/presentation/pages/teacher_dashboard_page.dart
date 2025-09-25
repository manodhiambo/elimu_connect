/ packages/app/lib/src/features/dashboard/teacher_dashboard/presentation/pages/teacher_dashboard_page.dart
class TeacherDashboardPage extends ConsumerWidget {
  const TeacherDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createAssignment(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildClassOverview(context, ref),
          _buildStudentProgress(context, ref),
          _buildRecentSubmissions(context, ref),
          _buildContentManagement(context, ref),
        ],
      ),
    );
  }
}
