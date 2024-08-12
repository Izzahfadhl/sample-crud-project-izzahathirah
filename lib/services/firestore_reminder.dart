import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  final CollectionReference reminders =
      FirebaseFirestore.instance.collection('reminders');

  // CREATE: add a new reminder
  Future<void> addReminder(String reminder) {
    return reminders.add({
      'reminder': reminder,
      'timestamp': Timestamp.now(),
      'finished': false,
    });
  }

  // READ: get reminders stream from database
  Stream<QuerySnapshot> getRemindersStream() {
    final remindersStream =
        reminders.orderBy('timestamp', descending: true).snapshots();
    return remindersStream;
  }

  // READ: get a single reminder from database
  Future<DocumentSnapshot> getReminder(String docID) {
    return reminders.doc(docID).get();
  }

  // UPDATE: update reminder on database
  Future<void> updateReminder(String docID, String newReminder) {
    return reminders.doc(docID).update({
      'reminder': newReminder,
      'timestamp': Timestamp.now(),
    });
  }

  // UPDATE: update reminder's status on database
  Future<void> updateReminderStatus(String docID, bool finished) async {
    return reminders.doc(docID).update({'finished': finished});
  }

  // DELETE: delete reminder on database
  Future<void> deleteReminder(String docID) {
    return reminders.doc(docID).delete();
  }
}
