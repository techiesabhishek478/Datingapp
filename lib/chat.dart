import 'package:dating/chatscreen.dart';
import 'package:dating/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class ChatUser {
  final String userEmail;
  final String name;
  final String email;
  final String profileImageUrl;

  ChatUser({
    required this.userEmail,
    required this.name,
    required this.email,
    required this.profileImageUrl,
  });
}

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ChatUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    // Make sure you're fetching the user's email correctly
    return ChatUser(
      userEmail: user.email ?? '',
      name: user.displayName ?? '',
      email: user.email ?? '',
      profileImageUrl: '',
    );
  }

  Future<List<ChatUser>> getAllUsers() async {
    final currentUser = await getCurrentUser();

    final fromQuery = await _firestore
        .collection('friend_requests')
        .where('status', isEqualTo: 'accepted')
        .where('from', isEqualTo: currentUser?.userEmail)
        .get();

    final toQuery = await _firestore
        .collection('friend_requests')
        .where('status', isEqualTo: 'accepted')
        .where('to', isEqualTo: currentUser?.userEmail)
        .get();

    final fromEmails = fromQuery.docs.map((doc) => doc['to']).toList();
    final toEmails = toQuery.docs.map((doc) => doc['from']).toList();

    final allEmails = [...fromEmails, ...toEmails];

    // Fetch user details for the emails found in friend requests.
    final usersQuerySnapshot = await _firestore
        .collection('users')
        .where('email', whereIn: allEmails)
        .get();

    final users = usersQuerySnapshot.docs
        .map((doc) => ChatUser(
              userEmail: doc['email'],
              name: doc['name'],
              email: doc['email'],
              profileImageUrl: doc['profileImageUrl'],
            ))
        .where((user) => user.userEmail != currentUser?.userEmail)
        .toList();

    return users;
  }
}

class UserSelectionScreen extends StatefulWidget {
  @override
  _UserSelectionScreenState createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  final UserRepository userRepository = UserRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Select a User to Chat With',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 177, 12, 0),
      ),
      body: FutureBuilder<List<ChatUser>>(
        future: userRepository.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}',
                style: TextStyle(color: Colors.white));
          } else {
            final users = snapshot.data;

            if (users == null || users.isEmpty) {
              return Center(
                child: Text('You have no users to chat with.',
                    style: TextStyle(color: Colors.white)),
              );
            }

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user.name, style: TextStyle(color: Colors.white)),
                  subtitle:
                      Text(user.email, style: TextStyle(color: Colors.white)),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.profileImageUrl),
                  ),
                  onTap: () async {
                    final currentUser = await userRepository.getCurrentUser();
                    if (currentUser != null) {
                      final currentContext = context; // Capture the context.
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        currentContext, // Use the captured context.
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            currentUser: currentUser,
                            otherUser: user,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UserSelectionScreen(),
  ));
}
