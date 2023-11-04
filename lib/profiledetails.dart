import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/All%20user.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileDetail extends StatefulWidget {
  final MyUser user;

  ProfileDetail({required this.user});

  @override
  _ProfileDetailState createState() => _ProfileDetailState();
}

class _ProfileDetailState extends State<ProfileDetail> {
  Map<String, dynamic> userData = {}; // Initialize as an empty map

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchAcceptedFriendRequestsCount();
  }

  void fetchUserData() {
    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: widget.user.email)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            querySnapshot.docs.first;
        setState(() {
          // Store all fields in the userData map
          userData = snapshot.data() ?? {};
        });
      }
    }).catchError((error) {
      print('Error fetching user data: $error');
    });
  }

  int acceptedFriendRequestsCount = 0;

  void fetchAcceptedFriendRequestsCount() {
    FirebaseFirestore.instance
        .collection('friend_requests')
        .where('status', isEqualTo: 'accepted')
        .where('from', isEqualTo: widget.user.email)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      print('Query 1 executed successfully');
      print('Query 1 results size: ${querySnapshot.size}');
      querySnapshot.docs.forEach((doc) {
        print('Query 1 Document data: ${doc.data()}');
      });
      setState(() {
        acceptedFriendRequestsCount = querySnapshot.size;
      });
    }).catchError((error) {
      print('Error in query 1: $error');
    });

    FirebaseFirestore.instance
        .collection('friend_requests')
        .where('status', isEqualTo: 'accepted')
        .where('to', isEqualTo: widget.user.email)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      print('Query 2 executed successfully');
      print('Query 2 results size: ${querySnapshot.size}');
      querySnapshot.docs.forEach((doc) {
        print('Query 2 Document data: ${doc.data()}');
      });
      setState(() {
        acceptedFriendRequestsCount += querySnapshot.size;
      });
    }).catchError((error) {
      print('Error in query 2: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 177, 12, 0),
        title: Text(
          'Profile Detail',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 15,),
            // Display user profile image
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(widget.user.profileImageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            if (userData.isNotEmpty)
              Column(
                children: [
                  Text(
                    'Name: ${userData['name'] ?? ''}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                 
                  Text(
                    'Email: ${userData['email'] ?? ''}',
                    style: TextStyle(
                      fontSize: 18,
                       fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'City: ${userData['city'] ?? ''}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Gender: ${userData['gender'] ?? ''}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Bio: ${userData['bio'] ?? ''}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Total Friend: $acceptedFriendRequestsCount',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
