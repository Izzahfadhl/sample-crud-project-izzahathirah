import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daylog/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  String? selectedDiaryID;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('diaries')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.removed) {
          _removeFromFavourites(change.doc.id);
        }
      }
    });
  }

  Future<void> _removeFromFavourites(String diaryID) async {
    try {
      await FirebaseFirestore.instance
          .collection('favourites')
          .doc(diaryID)
          .delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove from favourites: $e')),
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
            'Favourite Moments',
            style: GoogleFonts.gloriaHallelujah(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: const Color(0xffFFCCBC),
        automaticallyImplyLeading: false,
        leading: null,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('favourites').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List diariesList = snapshot.data!.docs;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: diariesList.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = diariesList[index];
                      String docID = document.id;
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String titleText = data['title'];
                      String diaryText = data['diary'];
                      Timestamp createdOn = data['timestamp'];
                      Timestamp date = data['date'];
                      // ignore: unused_local_variable
                      String formattedDate = DateFormat('dd-MM-yyyy h:mm a')
                          .format(createdOn.toDate());
                      String diaryDate =
                          DateFormat('dd-MM-yyyy').format(date.toDate());

                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            'Title: $titleText',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            diaryText,
                            style: GoogleFonts.dancingScript(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            'Date: $diaryDate',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              selectedDiaryID = docID;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                if (selectedDiaryID != null) ...[
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('favourites')
                        .doc(selectedDiaryID)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var document = snapshot.data!;
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String titleText = data['title'];
                        String diaryText = data['diary'];
                        Timestamp createdOn = data['timestamp'];
                        Timestamp date = data['date'];
                        // ignore: unused_local_variable
                        String formattedDate = DateFormat('dd-MM-yyyy h:mm a')
                            .format(createdOn.toDate());
                        String diaryDate =
                            DateFormat('dd-MM-yyyy').format(date.toDate());

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 5,
                            color: AppColors.blushpink,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Title: ',
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        titleText,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Text(
                                        'Date: ',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        diaryDate,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    diaryText,
                                    style: GoogleFonts.dancingScript(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedDiaryID = null;
                                        });
                                      },
                                      child: const Text('Close Details'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                ],
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
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
