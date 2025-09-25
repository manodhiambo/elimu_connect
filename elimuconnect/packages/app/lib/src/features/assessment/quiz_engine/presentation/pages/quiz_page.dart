// packages/app/lib/src/features/assessment/quiz_engine/presentation/pages/quiz_page.dart
class QuizPage extends ConsumerWidget {
  final String quizId;
  
  const QuizPage({Key? key, required this.quizId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider(quizId));
    
    return quizState.when(
      data: (quiz) => Scaffold(
        appBar: AppBar(
          title: Text(quiz.title),
          actions: [
            TimerWidget(
              duration: quiz.timeLimit,
              onTimeUp: () => _submitQuiz(ref, quizId),
            ),
          ],
        ),
        body: PageView.builder(
          controller: ref.watch(quizPageControllerProvider),
          itemCount: quiz.questions.length,
          itemBuilder: (context, index) => QuestionCard(
            question: quiz.questions[index],
            onAnswerSelected: (answer) => _selectAnswer(ref, index, answer),
            selectedAnswer: ref.watch(selectedAnswersProvider)[index],
          ),
        ),
        bottomNavigationBar: QuizNavigation(
          currentQuestion: ref.watch(currentQuestionProvider),
          totalQuestions: quiz.questions.length,
          onPrevious: () => _previousQuestion(ref),
          onNext: () => _nextQuestion(ref),
          onSubmit: () => _submitQuiz(ref, quizId),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorWidget.withDetails(message: error.toString()),
    );
  }
}
