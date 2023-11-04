import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/Add_story.dart';
import 'package:dating/Nearyou.dart';
import 'package:dating/Notification.dart';
import 'package:dating/UploadImagesPage.dart';
import 'package:dating/Viewpage.dart';
import 'package:dating/chat.dart';
import 'package:dating/moreview.dart';
import 'package:dating/profiledetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'All user.dart';
import 'Favorites.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  int notificationCount = 0;
  String? userProfileImageUrl;
  String? authenticatedUserEmail;
  List<DocumentSnapshot<Map<String, dynamic>>?> products = [];

  @override
  void initState() {
    super.initState();
    fetchUserProfileImage();
    fetchProducts();
    refreshPage();
  }

  Future<void> refreshPage() async {
    // Implement your refresh logic here.
    // For example, you can fetch data and update the widget state.
    fetchUserProfileImage();
    fetchProducts();
  }

  void updateNotificationCount(int count) {
    setState(() {
      notificationCount = count;
    });
  }

  void fetchUserProfileImage() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((DocumentSnapshot? snapshot) {
        if (snapshot != null && snapshot.exists) {
          final profileImageUrl = snapshot['profileImageUrl'] as String?;
          if (profileImageUrl != null) {
            setState(() {
              userProfileImageUrl = profileImageUrl;
            });
          }
        }
      }).catchError((error) {
        print('Error fetching profile image URL: $error');
      });
    }
  }

  Future<String?> fetchUserEmail() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return user.email;
      } else {
        return null; // No authenticated user
      }
    } catch (e) {
      print('Error fetching user email: $e');
      return null;
    }
  }

  void fetchProducts() {
    FirebaseFirestore.instance
        .collection('products')
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> snapshot) {
      setState(() {
        products = snapshot.docs;
      });
    }).catchError((error) {
      print('Error fetching products: $error');
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchAuthUserStories() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No authenticated user.');
    }

    final userStories = await FirebaseFirestore.instance
        .collection('stories')
        .where('userId', isEqualTo: user.email) // Filter by user email
        .get();

    return userStories;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchAllUsers() async {
    // Get the current authenticated user
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final String? currentUserEmail = user.email;

      // Replace 'users' with your Firestore collection name.
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email',
              isNotEqualTo: currentUserEmail) // Exclude the authenticated user
          .get();

      return userQuery;
    } else {
      throw Exception("User not authenticated");
    }
  }

  void fetchAuthUserEmail() {
    fetchUserEmail().then((email) {
      if (email != null) {
        setState(() {
          authenticatedUserEmail = email;
        });
      }
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> logoutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          title: Image.asset(
            'assets/Let_sDate-removebg-preview.png',
            width: 120,
            height: 150,
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => FriendRequestsScreen(),
                ));
                // Add your notification action here
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  height: 150,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: InkWell(
                          onTap: () {
                            // Fetch and display stories for the authenticated user
                            final User? user = FirebaseAuth.instance
                                .currentUser; // Get the authenticated user
                            if (user != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StoryView(
                                      selectedUserEmail: user.email ?? ''),
                                ),
                              );
                            } else {
                              // Handle the case where there is no authenticated user
                              // You may want to show an error message or handle this differently.
                            }
                          },
                          child: Stack(
                            children: [
                              CircleAvatar(
                                backgroundImage: userProfileImageUrl != null
                                    ? NetworkImage(userProfileImageUrl!)
                                    : AssetImage('assets/image (5).png')
                                        as ImageProvider,
                                radius: 50,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 118, left: 20),
                                child: Text(
                                  'Your Story',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StoryInput(),
                                      ),
                                    );
                                  },
                                  child: CircleAvatar(
                                    backgroundColor:
                                        Color.fromARGB(255, 173, 4, 4),
                                    radius: 15,
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        future: fetchAllUsers(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Icon(Icons.error_outline);
                          } else if (snapshot.data!.docs.isEmpty) {
                            return Icon(Icons.person);
                          } else {
                            final userDataList = snapshot.data!.docs.map((doc) {
                              return doc.data() as Map<String, dynamic>;
                            }).toList();

                            final userDataWidgets =
                                userDataList.map((userData) {
                              final hasStatus = userData['status'] != null &&
                                  userData['status'] != '';

                              return GestureDetector(
                                onTap: () {
                                  final selectedUserEmail =
                                      userData['email'] as String ??
                                          ''; // Provide a default empty string
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StoryView(
                                          selectedUserEmail: selectedUserEmail),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: hasStatus
                                              ? Border.all(
                                                  color: Colors.red,
                                                  width: 40,
                                                )
                                              : null,
                                        ),
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(userData[
                                                  'profileImageUrl'] ??
                                              ''), // Provide a default empty string
                                          radius: 50,
                                        ),
                                      ),
                                      Text(
                                        userData['name'] ?? '',
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList();

                            return Row(
                              children: userDataWidgets,
                            );
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundImage: AssetImage('assets/p2.jpg'),
                                radius: 50,
                              ),
                            ),
                            Text(
                              'Sam',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundImage: AssetImage('assets/p3.jpg'),
                                radius: 50,
                              ),
                            ),
                            Text(
                              'Jonny',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundImage: AssetImage('assets/p4.jpg'),
                                radius: 50,
                              ),
                            ),
                            Text(
                              'John',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Nearyouuser()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        'Near You',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          wordSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => Viewpage()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          wordSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 5),
              SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: products.map((product) {
                      final productUserEmail = product!['userEmail'] as String;
                      if (authenticatedUserEmail != productUserEmail) {
                        MyUser user = MyUser(
                          email: productUserEmail,
                          profileImageUrl: product['imageUrl'] as String,
                          city: '',
                          dateOfBirth: '',
                          mobileNumber: '',
                          gender: '',
                          name: '',
                          bio: '',
                        );

                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProfileDetail(user: user),
                                  ),
                                );
                              },
                              child: Container(
                                width: 350,
                                height: 450,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 350,
                                      height: 450,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          if (product!['imageUrl'] != null)
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Image.network(
                                                product['imageUrl'] as String,
                                                width: 250,
                                                height: 400,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          if (product!['description'] != null &&
                                              product!['userEmail'] != null)
                                            Positioned(
                                              top: 80,
                                              left: 20,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 300),
                                                child: Text(
                                                  '${product!['description'] as String}\n${product['userEmail'] as String}',
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          if (product!['imageUrl'] != null)
                                            Positioned(
                                              top: 10,
                                              right: 20,
                                              height: 40,
                                              child: LikeButton(
                                                imageUrl: product['imageUrl']
                                                    as String,
                                                toUserEmail: user.email,
                                              ),
                                            ),
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            child: SizedBox(
                                              height: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        );
                      }
                      return Container();
                    }).toList(),
                  ),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: CupertinoTabBar(
          backgroundColor: Colors.black,
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 0 && _currentIndex == 0) {
              // Refresh the page
              fetchProducts();
            } else if (index == 0) {
              // Navigate to the Home page, effectively refreshing it
              Navigator.pushReplacement(context,
                  CupertinoPageRoute(builder: (context) {
                return Home();
              }));
            } else if (index == 2) {
              // Navigate to the UploadProduct page
              Navigator.push(context, CupertinoPageRoute(builder: (context) {
                return UploadImagesPage();
              }));
            } else if (index == 1) {
              // Navigate to the Favorites page
              Navigator.push(context, CupertinoPageRoute(builder: (context) {
                return Favorites();
              }));
            } else if (index == 3) {
              // Navigate to the Chat page
              Navigator.push(context, CupertinoPageRoute(builder: (context) {
                return UserSelectionScreen();
              }));
            } else if (index == 4) {
              Navigator.push(context, CupertinoPageRoute(builder: (context) {
                return MoreView();
              }));
            }
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.heart),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.plus_app),
              label: 'New Post',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                CupertinoIcons.line_horizontal_3,
              ),
              label: 'More',
            ),
          ],
        ));
  }
}

class CurvedImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.quadraticBezierTo(size.width, 20, size.width - 20, 0);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class LikeButton extends StatefulWidget {
  final String imageUrl; // Pass the image URL to the widget
  final String toUserEmail;
  LikeButton({
    required this.imageUrl,
    required this.toUserEmail,
  });

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool isLiked = false; // Initially, the button is not liked

  // Function to handle the liking process
  Future<void> likeImage() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userEmail = user.email;

        // Store the image information in Firebase Firestore
        await FirebaseFirestore.instance.collection('liked_images').add({
          'userEmail': userEmail,
          'imageUrl': widget.imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Display a message to indicate the image was liked
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User Added to the Favorites List!'),
          ),
        );
      } else {
        // Handle the case where the user is not authenticated
      }
    } catch (e) {
      print('Error liking image: $e');
      // Handle the error and provide feedback to the user
    }

    setState(() {
      isLiked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? Colors.red : Colors.black,
        size: 60, // Adjust the size as needed
      ),
      onPressed: isLiked ? null : likeImage, // Disable button after liking
    );
  }
}
