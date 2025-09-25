class ClassModel {
  final String id;
  final String name;
  final String schoolId;
  final String teacherId;
  final List<String> studentIds;
  
  const ClassModel({
    required this.id,
    required this.name,
    required this.schoolId,
    required this.teacherId,
    required this.studentIds,
  });
}
