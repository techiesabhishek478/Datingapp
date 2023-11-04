import 'package:dating/home.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication

class FriendRequestsScreen extends StatefulWidget {
  @override
  _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  String userEmailAddress = ""; // Store the authenticated user's email

  // List to keep track of friend requests
  List<QueryDocumentSnapshot> requests = [];

  // Set to keep track of accepted/canceled requests
  Set<String> handledRequests = Set();

  // Map to store the selected options for each request
  Map<String, bool?> selectedOptions = {};

  @override
  void initState() {
    super.initState();

    // Fetch the authenticated user's email
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userEmailAddress = user.email!;
    }

    // Initialize the requests list with friend requests from Firestore
    FirebaseFirestore.instance
        .collection('friend_requests')
        .where('to', isEqualTo: userEmailAddress)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        requests = snapshot.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.black,
      appBar: AppBar(
         backgroundColor:Color.fromARGB(255, 177, 12, 0),
        title: Text('Friend Requests',style: TextStyle(color: Colors.white),),
      ),
      body: requests.isEmpty
          ? Center(child: Text('No friend requests.',style: TextStyle(color: Colors.white),))
          : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                String requestId = requests[index].id;
                String senderEmail = requests[index]['from'];

                // Check if the request has been handled
                bool requestHandled = handledRequests.contains(requestId);

                // Check if the request has been accepted
                bool requestAccepted = selectedOptions[requestId] == true;

                // Check if the request status is "accepted" (if the field exists)
                bool? requestStatusAccepted =
                    (requests[index].data() as Map<String, dynamic>?)
                                ?.containsKey('status') ==
                            true &&
                        requests[index]['status'] == 'accepted';

                return ListTile(
                  title: Text('Friend request from: $senderEmail',style: TextStyle(color: Colors.white),),
                  trailing: requestHandled
                      ? requestStatusAccepted
                          ? Text('Accepted',
                              style: TextStyle(color: Colors.green))
                          : requestAccepted
                              ? Text('Accepted',
                                  style: TextStyle(color: Colors.green))
                              : Text('Canceled',
                                  style: TextStyle(color: Colors.red))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!requestStatusAccepted) // Show buttons only if not accepted
                              IconButton(
                                icon: Icon(Icons.check,color: Colors.green,),
                                onPressed: () => handleFriendRequest(
                                    requestId, true), // Accept
                              ),
                            if (!requestStatusAccepted) // Show buttons only if not accepted
                              IconButton(
                                icon: Icon(Icons.cancel,color: Colors.red,),
                                onPressed: () => handleFriendRequest(
                                    requestId, false), // Cancel
                              ),
                          ],
                        ),
                );
              },
            ),
    );
  }

  // Function to handle a friend request
  void handleFriendRequest(String requestId, bool accept) {
    if (!handledRequests.contains(requestId)) {
      final updatedStatus = accept ? 'accepted' : 'canceled';

      FirebaseFirestore.instance
          .collection('friend_requests')
          .doc(requestId)
          .update({
        'status': updatedStatus,
      });

      // Update the UI to reflect the action taken and remove the buttons
      setState(() {
        handledRequests.add(requestId);
        selectedOptions[requestId] = accept; // Store the selected option
      });
    }
  }
}

void main() => runApp(MaterialApp(home: FriendRequestsScreen()));
