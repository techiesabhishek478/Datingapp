import 'package:dating/profiledetails.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyUser {
  final String city;
  final String dateOfBirth;
  final String email;
  final String gender;
  final String mobileNumber;
  final String name;
  final String profileImageUrl;
  bool friendRequestSent;
  bool friendRequestReceived;
  bool friendRequestPending;
  final String bio;

  MyUser({
    required this.city,
    required this.dateOfBirth,
    required this.email,
    required this.gender,
    required this.mobileNumber,
    required this.name,
    required this.profileImageUrl,
    required this.bio,
    this.friendRequestSent = false,
    this.friendRequestReceived = false,
    this.friendRequestPending = false,
  });

  factory MyUser.fromMap(Map<String, dynamic> data) {
    return MyUser(
      city: data['city'] ?? "",
      dateOfBirth: data['dateOfBirth'] is Timestamp
          ? (data['dateOfBirth'] as Timestamp).toDate().toString()
          : data['dateOfBirth'] ?? "",
      email: data['email'] ?? "",
      gender: data['gender'] ?? "",
      mobileNumber: data['mobileNumber'] ?? "",
      name: data['name'] ?? "",
      profileImageUrl: data['profileImageUrl'] ?? "",
      bio: data['bio'] ?? "",
    );
  }
}

class ViewAllUsers extends StatefulWidget {
  const ViewAllUsers({Key? key}) : super(key: key);

  @override
  _ViewAllUsersState createState() => _ViewAllUsersState();
}

class _ViewAllUsersState extends State<ViewAllUsers> {
  List<MyUser> users = [];
  String authenticatedUserEmail = '';
  Map<String, String?> friendRequestsStatus = {};
  Stream<QuerySnapshot>? friendRequestsStream;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchFriendRequests();
  }

  bool hasExistingFriendRequest(String friendEmail) {
    return friendRequestsStatus[friendEmail] == 'pending' ||
        friendRequestsStatus[friendEmail] == 'accepted';
  }

  void checkExistingFriendRequests() {
    for (int i = 0; i < users.length; i++) {
      final user = users[i];
      String friendRequestStatus = friendRequestsStatus[user.email] ?? 'none';

      if (friendRequestStatus == 'pending') {
        users[i].friendRequestSent = true;
        users[i].friendRequestPending = true;
      }
    }
  }

  Future<String> fetchFriendRequestStatus(String friendEmail) async {
    final fromUserRequest = await FirebaseFirestore.instance
        .collection('friend_requests')
        .where('from', isEqualTo: authenticatedUserEmail)
        .where('to', isEqualTo: friendEmail)
        .get();

    final toUserRequest = await FirebaseFirestore.instance
        .collection('friend_requests')
        .where('from', isEqualTo: friendEmail)
        .where('to', isEqualTo: authenticatedUserEmail)
        .get();

    if (fromUserRequest.docs.isNotEmpty) {
      final doc = fromUserRequest.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('status')) {
        return data['status'];
      }
    } else if (toUserRequest.docs.isNotEmpty) {
      final doc = toUserRequest.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('status')) {
        return data['status'];
      }
    }

    return 'none'; // Default status
  }

  void fetchFriendRequests() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      authenticatedUserEmail = currentUser.email!;
      friendRequestsStream = FirebaseFirestore.instance
          .collection('friend_requests')
          .where('to', isEqualTo: authenticatedUserEmail)
          .snapshots();

      friendRequestsStream!.listen((snapshot) {
        print("Received friend requests: ${snapshot.docs.length} documents");
        setState(() {
          friendRequestsStatus.clear();
          if (snapshot.docs.isNotEmpty) {
            for (var doc in snapshot.docs) {
              final from = doc['from'].toString();
              final data = doc.data() as Map<String, dynamic>; // Cast to a Map
              if (data.containsKey('status')) {
                final status = data['status'].toString();
                friendRequestsStatus[from] = status;
              } else {
                friendRequestsStatus[from] = 'unknown';
              }
            }
          }

          checkExistingFriendRequests();
          print("Friend requests status: $friendRequestsStatus");
        });
      });
    }
  }

  void fetchUsers() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();

    setState(() {
      users = snapshot.docs
          .map((doc) => MyUser.fromMap(doc.data() as Map<String, dynamic>))
          .where((user) => user.email != authenticatedUserEmail)
          .toList();
    });
  }

  void refreshPage() {
    setState(() {
      friendRequestsStatus.clear();
      fetchFriendRequests();
    });
  }

  void sendFriendRequest(String friendEmail, int index) {
    if (!users[index].friendRequestPending &&
        !hasExistingFriendRequest(friendEmail)) {
      setState(() {
        friendRequestsStatus[friendEmail] = 'pending';
        users[index].friendRequestSent = true;
        users[index].friendRequestPending = true;
      });

      FirebaseFirestore.instance.collection('friend_requests').add({
        'from': authenticatedUserEmail,
        'to': friendEmail,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Friend request sent successfully',
          style: TextStyle(color: Colors.white),
        ),
      ));
    }
  }

  void cancelFriendRequest(String friendEmail, int index) {
    if (friendRequestsStatus[friendEmail] == 'pending') {
      FirebaseFirestore.instance
          .collection('friend_requests')
          .where('from', isEqualTo: authenticatedUserEmail)
          .where('to', isEqualTo: friendEmail)
          .where('status', isEqualTo: 'pending')
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.forEach((doc) {
            doc.reference.delete();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Friend request to $friendEmail canceled.'),
            ),
          );
          setState(() {
            friendRequestsStatus[friendEmail] = 'none';
            users[index].friendRequestSent = false;
            users[index].friendRequestPending = false;
          });
        }
      }).catchError((error) {
        print("Error canceling friend request: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   leading: IconButton(
      //     icon: Icon(
      //       Icons.arrow_back,
      //       color: Colors.black,
      //     ),
      //     onPressed: () {
      //       Navigator.pushReplacement(
      //           context, MaterialPageRoute(builder: (context) => Home()));
      //     },
      //   ),
      //   backgroundColor: Color.fromARGB(255, 177, 12, 0),
      //   title: Text(
      //     'User List',
      //     style: TextStyle(color: Colors.white),
      //   ),
      // ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search for a user',
                labelStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
              style: TextStyle(color: Colors.white), // Set text color to white

              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                if (!user.name
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase())) {
                  return Container();
                }

                String friendRequestStatus =
                    friendRequestsStatus[user.email] ?? 'none';

                return ListTile(
                  leading: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileDetail(user: user),
                        ),
                      );
                    },
                    child: Image.network(
                      user.profileImageUrl,
                      width: 80,
                      height: 100,
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: user.email == authenticatedUserEmail
                      ? null
                      : Text(
                          user.email,
                          style: TextStyle(color: Colors.white),
                        ),
                  trailing: Container(
                    width: 100,
                    child: FutureBuilder<String>(
                      future: fetchFriendRequestStatus(user.email),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else {
                          final friendRequestStatus = snapshot.data;
                          return friendRequestStatus == 'pending'
                              ? Row(
                                  children: [
                                    const Icon(Icons.hourglass_empty,
                                        color: Colors.blue),
                                    IconButton(
                                      icon:
                                          Icon(Icons.cancel, color: Colors.red),
                                      onPressed: () {
                                        cancelFriendRequest(user.email, index);
                                      },
                                    ),
                                  ],
                                )
                              : friendRequestStatus == 'accepted'
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : user.friendRequestSent
                                      ? const Icon(Icons.person, color: Colors.white)
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.person_add_rounded,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            sendFriendRequest(
                                                user.email, index);
                                          },
                                        );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          if (users.isEmpty)
            Text(
              'No user found for "$searchQuery"',
              style: const TextStyle(color: Colors.white),
            ),
        ],
      ),
    );
  }
}
