import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ViewAllUsersPage extends StatefulWidget {
  @override
  _ViewAllUsersPageState createState() => _ViewAllUsersPageState();
}

class _ViewAllUsersPageState extends State<ViewAllUsersPage> {
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View All Users'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersCollection.snapshots(),
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

          List<QueryDocumentSnapshot> users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var userData = users[index].data() as Map<String, dynamic>;

              // Check if the fields exist and are not null
              String name = userData['name'] ?? 'N/A';
              String email = userData['email'] ?? 'N/A';
              String profileImage = userData['profileImageUrl'] ??
                  'https://path_to_default_image.jpg';

              // Pass the user's ID for deletion
              return UserCard(
                userId: users[index].id,
                email: email,
              );
            },
          );
        },
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final String userId;
  final String email;

  UserCard({
    required this.userId,
    required this.email,
  });

  // Function to delete the user by an admin
  Future<void> deleteUserByAdmin() async {
    try {
      // Mark the user as "deleted" in Firestore.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'isDeleted': true});

      // Delete the user from Firebase Authentication
      await FirebaseAuth.instance.currentUser!.delete();
    } catch (error) {
      print("Error marking user for deletion: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Text(email),
        trailing: ElevatedButton(
          onPressed: deleteUserByAdmin,
          child: Text("Delete User"),
        ),
      ),
    );
  }
}
