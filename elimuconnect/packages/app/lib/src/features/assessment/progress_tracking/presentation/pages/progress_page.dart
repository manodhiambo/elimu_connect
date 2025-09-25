// packages/app/lib/src/features/assessment/progress_tracking/presentation/pages/progress_page.dart
class ProgressPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(studentProgressProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
      ),
      body: progress.when(
        data: (progressData) => SingleChildScrollView(
          child: Column(
            children: [
              OverallProgressCard(progress: progressData.overall),
              SubjectProgressList(subjects: progressData.subjects),
              RecentAchievements(achievements: progressData.achievements),
              LearningStreakCard(streak: progressData.streak),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorWidget.withDetails(message: error.toString()),
      ),
    );
  }
}
