/ packages/app/lib/src/features/dashboard/parent_dashboard/presentation/pages/parent_dashboard_page.dart  
class ParentDashboardPage extends ConsumerWidget {
  const ParentDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
      ),
      body: Column(
        children: [
          _buildChildrenProgress(context, ref),
          _buildSchoolCommunication(context, ref),
          _buildUpcomingEvents(context, ref),
        ],
      ),
    );
  }
}
