import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daylog/colors/app_colors.dart';
import 'package:daylog/services/firestore_reminder.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final FireStoreService firestoreService = FireStoreService();

  final TextEditingController textController = TextEditingController();

  void openReminder({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(
            docID == null ? 'Add Reminder' : 'Edit Reminder',
            style: GoogleFonts.gloriaHallelujah(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple[500],
            ),
          ),
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter a reminder..',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.gloriaHallelujah(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                firestoreService.addReminder(textController.text);
              } else {
                firestoreService.updateReminder(docID, textController.text);
              }

              textController.clear();

              Navigator.pop(context);
            },
            child: Text(
              docID == null ? 'Add' : 'Update',
              style: GoogleFonts.gloriaHallelujah(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void viewReminder(String docID) async {
    DocumentSnapshot document = await firestoreService.getReminder(docID);
    String reminderText = document['reminder'];
    Timestamp createdOn = document['timestamp'];
    String formattedDate =
        DateFormat('dd-MM-yyyy h:mm a').format(createdOn.toDate());

    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(
            'View Reminder',
            style: GoogleFonts.gloriaHallelujah(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple[500],
            ),
          ),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Reminder:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(reminderText),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Created On:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(formattedDate),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Close',
              style: GoogleFonts.gloriaHallelujah(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> toggleReminderStatus(String docID, bool isDone) async {
    await firestoreService.updateReminderStatus(docID, !isDone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(35.0),
          child: Text(
            'Reminder',
            style: GoogleFonts.gloriaHallelujah(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
        ),
        backgroundColor: const Color(0xffFFCCBC),
        automaticallyImplyLeading: false,
        leading: null,
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.brightorange,
            width: 5.0,
          ),
        ),
        child: FloatingActionButton(
          onPressed: openReminder,
          backgroundColor: AppColors.vibrantpink,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
          child: const Icon(
            Icons.playlist_add_rounded,
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getRemindersStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List remindersList = snapshot.data!.docs;
            return ListView.builder(
              itemCount: remindersList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = remindersList[index];
                String docID = document.id;

                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String reminderText = data['reminder'];
                bool isDone = data['finished'] ?? false;
                Timestamp createdOn = data['timestamp'];
                String formattedDate =
                    DateFormat('dd-MM-yyyy h:mm a').format(createdOn.toDate());

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  tileColor: isDone ? Colors.grey[200] : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  title: Text(
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    reminderText,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    formattedDate,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => viewReminder(docID),
                        icon: const Icon(
                          Icons.remove_red_eye_rounded,
                          color: AppColors.charcoal,
                        ),
                      ),
                      IconButton(
                        onPressed: () => openReminder(docID: docID),
                        icon: const Icon(
                          Icons.edit,
                          color: AppColors.charcoal,
                        ),
                      ),
                      IconButton(
                        onPressed: () => firestoreService.deleteReminder(docID),
                        icon: const Icon(
                          Icons.delete,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ],
                  ),
                  leading: Checkbox(
                    value: isDone,
                    onChanged: (bool? value) {
                      if (value != null) {
                        toggleReminderStatus(docID, isDone);
                      }
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
