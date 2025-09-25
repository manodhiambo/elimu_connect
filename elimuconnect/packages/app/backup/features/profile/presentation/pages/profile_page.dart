// packages/app/lib/src/features/profile/presentation/pages/profile_page.dart
class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editProfile(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(user: user),
            const SizedBox(height: 24),
            _buildProfileSections(context, ref, user),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileSections(BuildContext context, WidgetRef ref, User? user) {
    switch (user?.role) {
      case UserRole.student:
        return StudentProfileContent(student: user as Student);
      case UserRole.teacher:
        return TeacherProfileContent(teacher: user as Teacher);
      case UserRole.parent:
        return ParentProfileContent(parent: user as Parent);
      case UserRole.admin:
        return AdminProfileContent(admin: user as Admin);
      default:
        return const SizedBox.shrink();
    }
  }
}
