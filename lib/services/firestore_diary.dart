import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  final CollectionReference diaries =
      FirebaseFirestore.instance.collection('diaries');

  // CREATE: add a new diary
  Future<void> addDiary(String title, String diary, DateTime date) {
    return diaries.add({
      'title': title,
      'diary': diary,
      'timestamp': Timestamp.now(),
      'date': Timestamp.fromDate(date),
    });
  }

  // READ: get diaries stream from database
  Stream<QuerySnapshot> getDiariesStream() {
    return diaries.orderBy('timestamp', descending: true).snapshots();
  }

  // READ: get a single diary from database
  Future<DocumentSnapshot> getDiary(String docID) {
    return diaries.doc(docID).get();
  }

  // UPDATE: update diary on database
  Future<void> updateDiary(
      String docID, String newTitle, String newDiary, DateTime date) {
    return diaries.doc(docID).update({
      'title': newTitle,
      'diary': newDiary,
      'timestamp': Timestamp.now(),
      'date': Timestamp.fromDate(date),
    });
  }

  // DELETE: delete diary on database
  Future<void> deleteDiary(String docID) {
    return diaries.doc(docID).delete();
  }
}
