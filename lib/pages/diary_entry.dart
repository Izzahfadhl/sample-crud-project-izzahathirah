import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daylog/colors/app_colors.dart';
import 'package:daylog/services/firestore_diary.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DiaryEntryPage extends StatefulWidget {
  final String? docID;

  const DiaryEntryPage({Key? key, this.docID}) : super(key: key);

  @override
  State<DiaryEntryPage> createState() => _DiaryEntryPageState();
}

class _DiaryEntryPageState extends State<DiaryEntryPage> {
  final FireStoreService firestoreService = FireStoreService();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController textController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.docID != null) {
      _loadDiary();
    }
  }

  void _loadDiary() async {
    DocumentSnapshot document = await firestoreService.getDiary(widget.docID!);
    String title = document['title'];
    String diaryText = document['diary'];
    Timestamp date = document['date'];
    setState(() {
      titleController.text = title;
      textController.text = diaryText;
      selectedDate = date.toDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          widget.docID == null ? 'Add Diary' : 'Edit Diary',
          style: GoogleFonts.gloriaHallelujah(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal,
          ),
        ),
        backgroundColor: const Color(0xffFFCCBC),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Enter diary title..',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: textController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter diary content..',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && pickedDate != selectedDate) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                child: Text(
                  'Pick Date: ${DateFormat('dd-MM-yyyy').format(selectedDate)}',
                  style: GoogleFonts.gloriaHallelujah(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (widget.docID == null) {
                    firestoreService.addDiary(
                      titleController.text,
                      textController.text,
                      selectedDate,
                    );
                  } else {
                    firestoreService.updateDiary(
                      widget.docID!,
                      titleController.text,
                      textController.text,
                      selectedDate,
                    );
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  widget.docID == null ? 'Add' : 'Update',
                  style: GoogleFonts.gloriaHallelujah(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
