import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryScreen extends StatefulWidget {
  final String title;
  final String deckId;
  final bool isFriendDeck;

  const HistoryScreen({
    Key? key,
    required this.title,
    required this.deckId,
    this.isFriendDeck = false,
  }) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> fetchGameResults() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final collectionPath = widget.isFriendDeck
          ? 'Deck/${user.uid}/deckFriend/${widget.deckId}/gameResults'
          : 'Deck/${user.uid}/title/${widget.deckId}/gameResults';

      final querySnapshot = await FirebaseFirestore.instance
          .collection(collectionPath)
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'timestamp': data['timestamp']?.toDate(),
          'score': data['score'],
          'cardCount': data['cardCount'],
          'time': data['time'],
        };
      }).toList();
    } catch (e) {
      print("Error fetching game results: $e");
      return [];
    }
  }

  String formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = (dateTime.year + 543).toString(); // ปีพุทธศักราช
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 215, 166),
      appBar: AppBar(
        title: Text('ประวัติการเล่น: ${widget.title}'),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       Navigator.pop(context);
        //     },
        //     icon: const Icon(Icons.dashboard),
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchGameResults(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'),
              );
            }

            final gameResults = snapshot.data ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ประวัติการเล่นของ ${widget.title}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                gameResults.isNotEmpty
                    ? Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('วันที่')),
                              DataColumn(label: Text('คะแนน')),
                              DataColumn(label: Text('เวลาใช้เล่น\n(วินาที)')),
                            ],
                            rows: gameResults.map((result) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      result['timestamp'] != null
                                          ? formatDateTime(result['timestamp'])
                                          : '',
                                    ),
                                  ),
                                  DataCell(
                                    Text('${result['score']}/${result['cardCount']}'),
                                  ),
                                  DataCell(
                                    Text(result['time'].toString()),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      )
                    : const Center(
                        child: Text(
                          'ยังไม่มีประวัติการเล่น',
                          style: TextStyle(color: Color.fromARGB(255, 192, 66, 57)),
                        ),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
