import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_swiper_3/flutter_swiper_3.dart';

class Suggestion extends StatefulWidget {
  @override
  _SuggestionState createState() => _SuggestionState();
}

class _SuggestionState extends State<Suggestion> {
  bool isFavorited = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, String>> matchingUsers = [];
  int currentCardIndex = 0;
  List<String> likedUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestionsForCurrentUser();
  }

  Future<void> _loadSuggestionsForCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userOptions = await _loadUserOptions(user.email);
      if (userOptions!.isNotEmpty) {
        _loadSuggestions(userOptions);
      }
    }
  }

  Future<List<String>?> _loadUserOptions(String? userEmail) async {
    if (userEmail != null) {
      try {
        final querySnapshot =
            await _firestore.collection('user_options').doc(userEmail).get();

        if (querySnapshot.exists) {
          final data = querySnapshot.data();
          if (data != null) {
            final options = (data['options'] as List<dynamic>?)
                ?.where((item) => item != null)
                .map((item) => item.toString())
                .toList();
            return options;
          }
        }
      } catch (error) {
        print("Error loading user options: $error");
      }
    }
    return null;
  }

  Future<void> _loadSuggestions(List<String>? userOptions) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || userOptions == null) {
      return;
    }

    try {
      final dislikedUsersDoc = await _firestore
          .collection('disliked_users')
          .doc(currentUser.email)
          .get();
      final dislikedUsersData = dislikedUsersDoc.data();

      final querySnapshot = await _firestore
          .collection('user_options')
          .where('options', arrayContainsAny: userOptions)
          .get();

      for (final doc in querySnapshot.docs) {
        final userId = doc.id;
        if (userId != currentUser.email &&
            !likedUsers.contains(userId) &&
            (dislikedUsersData == null || dislikedUsersData[userId] != true)) {
          final friendRequestSnapshot = await _firestore
              .collection('friend_requests')
              .doc(currentUser.email)
              .collection('sent_requests')
              .doc(userId)
              .get();

          if (!friendRequestSnapshot.exists) {
            final data = doc.data();
            matchingUsers.add({
              'userId': userId,
              'name': data['name'] ?? 'No Name',
              'profile': data['profileImageUrl'] ?? '',
            });
          }
        }
      }
    } catch (error) {
      print("Error loading suggestions: $error");
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveLikedUser(
      String currentUserEmail, String likedUserId) async {
    try {
      await _firestore.collection('liked_users').doc(currentUserEmail).set({
        likedUserId: true,
      }, SetOptions(merge: true));
    } catch (error) {
      print("Error saving liked user: $error");
    }
  }

  void _swipeCard(bool like) {
    setState(() {
      if (currentCardIndex < matchingUsers.length) {
        if (like) {
          final likedUserId = matchingUsers[currentCardIndex]['userId'];
          final currentUser = _auth.currentUser;

          if (likedUserId != null && currentUser != null) {
            final currentUserEmail = currentUser.email;
            if (currentUserEmail != null) {
              _saveLikedUser(currentUserEmail, likedUserId);
            }
          }
        }

        if (currentCardIndex < matchingUsers.length - 1) {
          currentCardIndex++;
        } else {
          // No more cards to display, handle accordingly
        }
      }
    });
  }

  void _excludeUserFromSuggestions(String userId) {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final currentUserEmail = currentUser.email;
      _firestore.collection('disliked_users').doc(currentUserEmail).set({
        userId: true,
      }, SetOptions(merge: true));
      _swipeCard(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(), // Show a loading indicator
            )
          : matchingUsers.isEmpty
              ? Center(
                  child: Text(
                    'No matching users found',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Swiper(
                  itemCount: matchingUsers.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      elevation: 8,
                      margin: EdgeInsets.all(24),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 9 / 16,
                            child: Image.network(
                              matchingUsers[index]['profile']!,
                              fit: BoxFit.contain,
                              loadingBuilder:
                                  (BuildContext context, Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Name: ${matchingUsers[index]['name']}',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                    Text(
                                      'Email: ${matchingUsers[index]['userId']}',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 80,
                            bottom: 65,
                            child: IconButton(
                              icon: Icon(Icons.cancel, color: Colors.red, size: 70),
                              onPressed: () {
                                _swipeCard(false);
                                _excludeUserFromSuggestions(
                                    matchingUsers[index]['userId']!);
                              },
                            ),
                          ),
                          Positioned(
                            right: 80,
                            bottom: 65,
                            child: IconButton(
                              icon: Icon(
                                isFavorited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorited ? Colors.red : Colors.black,
                                size: 70,
                              ),
                              onPressed: () {
                                setState(() {
                                  isFavorited = !isFavorited;
                                  // Add your logic to handle the like or favorite action here.
                                  if (isFavorited) {
                                    // Handle liking the user.
                                  } else {
                                    // Handle unliking the user.
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onIndexChanged: (int index) {
                    setState(() {
                      currentCardIndex = index;
                    });
                  },
                  loop: false,
                ),
    );
  }
}
