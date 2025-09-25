class KenyaCurriculum {
  static const Map<String, List<String>> subjectsByLevel = {
    'Pre-Primary': [
      'Language Activities',
      'Mathematical Activities', 
      'Environmental Activities',
      'Psychomotor and Creative Activities',
      'Religious Education'
    ],
    'Lower Primary (Grade 1-3)': [
      'English',
      'Kiswahili',
      'Mathematics',
      'Environmental Studies',
      'Religious Education',
      'Physical Education'
    ],
    'Upper Primary (Grade 4-6)': [
      'English',
      'Kiswahili', 
      'Mathematics',
      'Science and Technology',
      'Social Studies',
      'Religious Education',
      'Creative Arts',
      'Physical Education'
    ],
    'Junior Secondary (Grade 7-9)': [
      'English',
      'Kiswahili',
      'Mathematics',
      'Integrated Science',
      'History and Government',
      'Geography',
      'Religious Education',
      'Life Skills Education',
      'Physical Education',
      'Creative Arts'
    ],
    'Senior Secondary (Grade 10-12)': [
      'English',
      'Kiswahili',
      'Mathematics',
      'Biology',
      'Chemistry',
      'Physics',
      'History',
      'Geography',
      'Religious Studies',
      'Computer Science',
      'Business Studies',
      'Agriculture'
    ]
  };
  
  static const List<String> gradeNames = [
    'Pre-Primary 1', 'Pre-Primary 2',
    'Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6',
    'Grade 7', 'Grade 8', 'Grade 9',
    'Grade 10', 'Grade 11', 'Grade 12'
  ];
  
  static List<String> getSubjectsForGrade(String grade) {
    if (grade.contains('Pre-Primary')) {
      return subjectsByLevel['Pre-Primary']!;
    } else if (['Grade 1', 'Grade 2', 'Grade 3'].contains(grade)) {
      return subjectsByLevel['Lower Primary (Grade 1-3)']!;
    } else if (['Grade 4', 'Grade 5', 'Grade 6'].contains(grade)) {
      return subjectsByLevel['Upper Primary (Grade 4-6)']!;
    } else if (['Grade 7', 'Grade 8', 'Grade 9'].contains(grade)) {
      return subjectsByLevel['Junior Secondary (Grade 7-9)']!;
    } else if (['Grade 10', 'Grade 11', 'Grade 12'].contains(grade)) {
      return subjectsByLevel['Senior Secondary (Grade 10-12)']!;
    }
    return [];
  }
}
