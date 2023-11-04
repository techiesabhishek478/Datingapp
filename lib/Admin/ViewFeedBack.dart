import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewFeedbackPage extends StatefulWidget {
  @override
  State<ViewFeedbackPage> createState() => _ViewFeedbackPageState();
}

class _ViewFeedbackPageState extends State<ViewFeedbackPage> {
  final CollectionReference feedbackCollection =
      FirebaseFirestore.instance.collection('feedback');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Feedback'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: feedbackCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<QueryDocumentSnapshot> feedbackList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: feedbackList.length,
            itemBuilder: (context, index) {
              var feedbackData = feedbackList[index].data() as Map<String, dynamic>;
              String email = feedbackData['email'] ?? 'No email provided';
              String feedback = feedbackData['feedback'] ?? 'No feedback provided';
              Timestamp timestamp = feedbackData['timestamp'];

              // Format the timestamp into a readable string
              String formattedTimestamp =
                  timestamp.toDate().toLocal().toString();

              return FeedbackCard(
                email: email,
                feedback: feedback,
                timestamp: formattedTimestamp,
                onDelete: () {
                  // Implement the logic to delete the feedback entry
                  deleteFeedbackEntry(feedbackList[index].id);
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> deleteFeedbackEntry(String feedbackId) async {
    try {
      await feedbackCollection.doc(feedbackId).delete();
    } catch (e) {
      print('Error deleting feedback entry: $e');
    }
  }
}

class FeedbackCard extends StatelessWidget {
  final String email;
  final String feedback;
  final String timestamp;
  final VoidCallback onDelete;

  FeedbackCard({
    required this.email,
    required this.feedback,
    required this.timestamp,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('Email: $email'),
            subtitle: Text('Feedback: $feedback'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Timestamp: $timestamp'),
          ),
          ElevatedButton(
            onPressed: onDelete,
            child: Text('Delete Feedback'),
          ),
        ],
      ),
    );
  }
}
