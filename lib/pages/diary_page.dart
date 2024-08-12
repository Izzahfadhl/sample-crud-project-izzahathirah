// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daylog/colors/app_colors.dart';
import 'package:daylog/pages/diary_entry.dart';
import 'package:daylog/services/firestore_diary.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPage();
}

class _DiaryPage extends State<DiaryPage> {
  final FireStoreService firestoreService = FireStoreService();

  void _editDiary(String docID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryEntryPage(docID: docID),
      ),
    );
  }

  Future<bool> _isFavourite(String docID) async {
    DocumentSnapshot favouriteDoc = await FirebaseFirestore.instance
        .collection('favourites')
        .doc(docID)
        .get();
    return favouriteDoc.exists;
  }

  void _viewDiary(String docID) async {
    DocumentSnapshot document = await firestoreService.getDiary(docID);
    bool isFavourite = await _isFavourite(docID);
    String title = document['title'];
    String diaryText = document['diary'];
    Timestamp createdOn = document['timestamp'];
    Timestamp date = document['date'];
    String formattedDate =
        DateFormat('dd-MM-yyyy h:mm a').format(createdOn.toDate());
    String diaryDate = DateFormat('dd-MM-yyyy').format(date.toDate());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(
            'View Diary',
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
              'Title:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Date:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              diaryDate,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Diary:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              diaryText,
              style: GoogleFonts.dancingScript(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 30),
              IconButton(
                icon: Icon(
                  isFavourite ? Icons.favorite : Icons.favorite_border_rounded,
                  color: Colors.red,
                ),
                onPressed: () async {
                  if (isFavourite) {
                    await FirebaseFirestore.instance
                        .collection('favourites')
                        .doc(docID)
                        .delete();
                  } else {
                    await _addToFavourites(docID);
                  }
                  Navigator.pop(context);
                },
              ),
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
        ],
      ),
    );
  }

  void _deleteDiary(String docID) {
    firestoreService.deleteDiary(docID);
  }

  Future<void> _addToFavourites(String docID) async {
    try {
      DocumentSnapshot document = await firestoreService.getDiary(docID);

      if (document.exists) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        await FirebaseFirestore.instance
            .collection('favourites')
            .doc(docID)
            .set(data);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diary added to favourites!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diary not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to favourites: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(35.0),
          child: Text(
            'Diary',
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DiaryEntryPage(),
              ),
            );
          },
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
        stream: firestoreService.getDiariesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List diariesList = snapshot.data!.docs;

            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1.0,
              ),
              itemCount: diariesList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = diariesList[index];
                String docID = document.id;

                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String diaryText = data['diary'];
                String title = data['title'];
                Timestamp createdOn = data['timestamp'];
                Timestamp date = data['date'];
                // ignore: unused_local_variable
                String formattedDate =
                    DateFormat('dd-MM-yyyy h:mm a').format(createdOn.toDate());
                // ignore: unused_local_variable
                String diaryDate =
                    DateFormat('dd-MM-yyyy').format(date.toDate());

                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Title: $title',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 15),
                              Text(
                                diaryText,
                                style: GoogleFonts.dancingScript(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_red_eye_rounded),
                            onPressed: () => _viewDiary(docID),
                            tooltip: 'View Diary',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editDiary(docID),
                            tooltip: 'Edit Diary',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteDiary(docID),
                            tooltip: 'Delete Diary',
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
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
