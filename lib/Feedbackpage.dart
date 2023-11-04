import 'package:dating/moreview.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  String _feedbackErrorMessage = '';
  String _emailErrorMessage = '';

  @override
  void initState() {
    super.initState();

    loadUserEmail();
  }

  Future<void> loadUserEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String? userEmail = user.email;

        setState(() {
          _emailController.text = userEmail!;
        });
      }
    } catch (e) {
      print('Error fetching user email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 177, 12, 0),
        title: Text(
          'Send Feedback',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MoreView(),
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(
                  'Your Feedback:',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _feedbackController,
                  maxLines: 5,
                  onChanged: (value) {
                    setState(() {
                      _feedbackErrorMessage = '';
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Type your feedback here...',
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                    border: OutlineInputBorder(),
                    errorText: _feedbackErrorMessage.isNotEmpty
                        ? _feedbackErrorMessage
                        : null,
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16),
                Text(
                  'Your Email (Required):',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    setState(() {
                      _emailErrorMessage = '';
                    });
                  },
                  maxLength: 60,
                  decoration: InputDecoration(
                    hintText: 'Enter your email (required)',
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                    border: OutlineInputBorder(),
                    errorText: _emailErrorMessage.isNotEmpty
                        ? _emailErrorMessage
                        : null,
                    counter: SizedBox.shrink(),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16),
                Container(
                  width: 150.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 177, 12, 0),
                        Color.fromARGB(255, 177, 12, 0),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(
                        20.0), // Adjust the radius as needed
                    border: Border.all(
                      color: Colors.black, // Adjust the border color as needed
                      width: 2.0, // Adjust the border width as needed
                    ),
                  ),
                  child: ElevatedButton(
                      onPressed: () async {
                        String feedback = _feedbackController.text;
                        String email = _emailController.text;

                        if (feedback.isEmpty) {
                          setState(() {
                            _feedbackErrorMessage =
                                'Please enter your feedback';
                          });
                        } else if (email.isEmpty || !isValidEmail(email)) {
                          setState(() {
                            _emailErrorMessage = 'Please enter a valid email';
                          });
                        } else {
                          FirebaseFirestore firestore =
                              FirebaseFirestore.instance;

                          try {
                            await firestore.collection('feedback').add({
                              'feedback': feedback,
                              'email': email,
                              'timestamp': FieldValue.serverTimestamp(),
                            });

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.black,
                                  title: Text(
                                    'Feedback Sent',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: Text(
                                    'Thank you for your feedback!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'OK',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            _feedbackController.clear();
                            _emailController.clear();
                          } catch (e) {
                            print('Error saving feedback: $e');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white12,
                        shadowColor: Colors.white12,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: Container(
                        constraints:
                            BoxConstraints(minWidth: 150.0, minHeight: 40.0),
                        alignment: Alignment.center,
                        child: Text(
                          'Send Feedback',
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isValidEmail(String email) {
    return email.contains('@') && email.split('@')[1].contains('.');
  }
}

void main() {
  runApp(MaterialApp(
    home: FeedbackPage(),
  ));
}
