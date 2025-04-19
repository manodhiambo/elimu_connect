import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================== BOOKS ==================

  Future<void> uploadBook({
    required String title,
    required String author,
    required String url,
  }) async {
    await _db.collection('books').add({
      'title': title,
      'author': author,
      'url': url,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getBooks() {
  return _db
      .collection('books')
      .orderBy('timestamp', descending: true)
      .snapshots();
}

  Future<void> addBook(Map<String, dynamic> bookData) async {
    await _db.collection('books').add(bookData);
  }

  // ================== PAST PAPERS ==================

  Future<void> uploadPastPaper({
    required String subject,
    required String year,
    required String url,
  }) async {
    await _db.collection('past_papers').add({
      'subject': subject,
      'year': year,
      'fileUrl': url, // Use 'fileUrl' to match UI usage
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getPastPapers() {
    return _db
        .collection('past_papers')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> addPastPaper(Map<String, dynamic> paperData) async {
    await _db.collection('past_papers').add(paperData);
  }

  // ================== QUESTIONS ==================

  Future<void> postQuestion({
    required String title,
    required String description,
    required String postedBy,
  }) async {
    await _db.collection('questions').add({
      'title': title,
      'description': description,
      'postedBy': postedBy,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getQuestions() {
    return _db
        .collection('questions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }

  // ================== REPLIES ==================

  Future<void> postReplyToQuestion({
    required String questionId,
    required String replyText,
    required String repliedBy,
  }) async {
    await _db
        .collection('questions')
        .doc(questionId)
        .collection('replies')
        .add({
      'replyText': replyText,
      'repliedBy': repliedBy,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> postReply({
    required String questionId,
    required Map<String, dynamic> replyData,
  }) async {
    await _db
        .collection('questions')
        .doc(questionId)
        .collection('replies')
        .add(replyData);
  }

  Stream<List<Map<String, dynamic>>> getReplies(String questionId) {
    return _db
        .collection('questions')
        .doc(questionId)
        .collection('replies')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }
}
