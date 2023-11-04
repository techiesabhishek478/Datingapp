import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/chat.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser currentUser;
  final ChatUser otherUser;

  ChatScreen({required this.currentUser, required this.otherUser});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Stream<List<QueryDocumentSnapshot>> messagesStream;

  @override
  void initState() {
    super.initState();
    final currentUserEmail = widget.currentUser.userEmail;
    final selectedUserEmail = widget.otherUser.userEmail;

    final messagesQuery1 = firestore
        .collection('messages')
        .where('senderEmail', isEqualTo: currentUserEmail)
        .where('receiverEmail', isEqualTo: selectedUserEmail);

    final messagesQuery2 = firestore
        .collection('messages')
        .where('senderEmail', isEqualTo: selectedUserEmail)
        .where('receiverEmail', isEqualTo: currentUserEmail);

    final mergedStream = Rx.combineLatest2(
      messagesQuery1.snapshots(),
      messagesQuery2.snapshots(),
      (QuerySnapshot query1, QuerySnapshot query2) =>
          [...query1.docs, ...query2.docs],
    ).map((list) {
      list.sort((a, b) {
        Timestamp timestampA = a['timestamp'];
        Timestamp timestampB = b['timestamp'];
        return timestampA.compareTo(timestampB);
      });
      return list;
    });

    setState(() {
      messagesStream = mergedStream;
    });
  }

  void sendMessage() {
    String message = messageController.text.trim();
    if (message.isNotEmpty) {
      String senderEmail = widget.currentUser.userEmail;
      String receiverEmail = widget.otherUser.userEmail;

      firestore.collection('messages').add({
        'senderEmail': senderEmail,
        'receiverEmail': receiverEmail,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      messageController.clear();
    }
  }

  Widget buildMessageBubble(
      QueryDocumentSnapshot message, String currentUserEmail) {
    String messageText = message['message'];
    String senderEmail = message['senderEmail'];
    bool isCurrentUser = senderEmail == currentUserEmail;
    final messageColor =
        isCurrentUser ? Color.fromARGB(255, 177, 12, 0) : Colors.black87;

    // Get the timestamp and format it
    Timestamp timestamp = message['timestamp'];
    DateTime dateTime = timestamp.toDate();
    String formattedTime = DateFormat('HH:mm').format(dateTime);

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: messageColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
            bottomLeft:
                isCurrentUser ? Radius.circular(16.0) : Radius.circular(0),
            bottomRight:
                isCurrentUser ? Radius.circular(0) : Radius.circular(16.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              messageText,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 4.0),
            Text(
              formattedTime, // Display formatted timestamp
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String currentUserEmail = widget.currentUser.userEmail;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 177, 12, 0),
        title: Text(
          'Chat with ${widget.otherUser.name}',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background_image.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.3), BlendMode.srcOver),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<QueryDocumentSnapshot>>(
                stream: messagesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print('Firestore Error: ${snapshot.error}');
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data;

                  if (messages == null || messages.isEmpty) {
                    return Center(child: Text('No messages yet.'));
                  }

                  return ListView(
                    children: messages
                        .map((message) =>
                            buildMessageBubble(message, currentUserEmail))
                        .toList(),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Color.fromARGB(255, 177, 12, 0),
                    ),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
