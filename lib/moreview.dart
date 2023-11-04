import 'package:dating/About.dart';
import 'package:dating/Favorites.dart';
import 'package:dating/Feedbackpage.dart';
import 'package:dating/Login.dart';
import 'package:dating/ProfilePage.dart';
import 'package:dating/UploadImagesPage.dart';
import 'package:dating/chat.dart';
import 'package:dating/hobbiespage.dart';
import 'package:dating/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class MoreView extends StatefulWidget {
  const MoreView({Key? key});

  @override
  State<MoreView> createState() => _MoreViewState();
}

Future<void> logoutUser() async {
  try {
    await FirebaseAuth.instance.signOut();
  } catch (e) {
    print('Error signing out: $e');
  }
}

class _MoreViewState extends State<MoreView> {
  int _currentIndex = 4;
  Future<Map<String, dynamic>?> getProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return snapshot.data() as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Color _selectedItemColor = Colors.black;
    Color _unselectedItemColor = Colors.black38;
    return Scaffold(
      appBar: null,
      backgroundColor: Colors.black,
      body: Container(
        child: Stack(
          children: [
            // Positioned(
            //   top: 0,
            //   left: 10,
            //   right: 0,
            //   child: AppBar(
            //     backgroundColor: Colors.transparent,
            //     elevation: 0,
            //     leading: CircleAvatar(
            //       backgroundColor: Colors.black,
            //       child: Container(
            //         decoration: BoxDecoration(
            //           shape: BoxShape.circle,
            //           border: Border.all(
            //             color: Colors.black,
            //             width: 2.0,
            //           ),
            //         ),
            //         child: IconButton(
            //           icon: Icon(Icons.arrow_back, color: Colors.white),
            //           onPressed: () {
            //             Navigator.pushReplacement(context,
            //                 MaterialPageRoute(builder: (context) => Home()));
            //           },
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'More',
                  style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    FutureBuilder<Map<String, dynamic>?>(
                      future: getProfileData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else {
                          var userData = snapshot.data;
                          var name = userData?['name'];
                          var profileImageUrl = userData?['profileImageUrl'];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor:
                                    Color.fromARGB(255, 177, 12, 0),
                                backgroundImage: profileImageUrl != null
                                    ? NetworkImage(profileImageUrl)
                                    : AssetImage('assets/profile.png')
                                        as ImageProvider,
                              ),
                              SizedBox(height: 10),
                              Text(
                                name ?? 'User Name',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                width: 150,
                                height: 40,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 177, 12, 0),
                                        Color.fromARGB(255, 177, 12, 0),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProfileUpdatePage()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.white12,
                                      shadowColor: Colors.white12,
                                    ),
                                    child: Text(
                                      'Edit Profile',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.feedback_outlined,
                        size: 20,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Feedback',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FeedbackPage()));
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                      title: Text(
                        'About',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AboutPage()));
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(
                        CupertinoIcons.square_favorites_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                      title: Text(
                        "Add Hobbie's",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => Hobbies()));
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.logout,
                        size: 20,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        logoutUser().then((_) {
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ));
                        });
                      },
                    ),
                    Divider(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Colors.black,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 4 && _currentIndex == 4) {
          } else if (index == 0) {
            Navigator.pushReplacement(context,
                CupertinoPageRoute(builder: (context) {
              return Home();
            }));
          } else if (index == 2) {
            Navigator.push(context, CupertinoPageRoute(builder: (context) {
              return UploadImagesPage();
            }));
          } else if (index == 1) {
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
      ),
    );
  }
}
