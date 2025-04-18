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
    return _db.collection('books').orderBy('timestamp', descending: true).snapshots();
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
      'url': url,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getPastPapers() {
    return _db.collection('past_papers').orderBy('timestamp', descending: true).snapshots();
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

  Stream<QuerySnapshot> getQuestions() {
    return _db.collection('questions').orderBy('timestamp', descending: true).snapshots();
  }

  // Method to add a book
  Future<void> addBook(Map<String, dynamic> bookData) async {
    await _db.collection('books').add(bookData);
  }

  // Method to add a past paper
  Future<void> addPastPaper(Map<String, dynamic> paperData) async {
    await _db.collection('past_papers').add(paperData);
  }

  // Post a reply to a specific question
  Future<void> postReplyToQuestion({
    required String questionId,
    required String replyText,
    required String repliedBy,
  }) async {
    await _db.collection('questions').doc(questionId).collection('replies').add({
      'replyText': replyText,
      'repliedBy': repliedBy,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get replies for a specific question
  Stream<QuerySnapshot> getRepliesForQuestion(String questionId) {
    return _db
        .collection('questions')
        .doc(questionId)
        .collection('replies')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Post a reply with a custom data map
  Future<void> postReply({
    required String questionId,
    required Map<String, dynamic> replyData,
  }) async {
    await _db.collection('questions').doc(questionId).collection('replies').add(replyData);
  }

  // Fetch replies with a custom data map
  Stream<QuerySnapshot> getReplies(String questionId) {
    return _db
        .collection('questions')
        .doc(questionId)
        .collection('replies')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
