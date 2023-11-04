import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/hobbiespage.dart';
import 'package:flutter/material.dart';
import 'package:dating/home.dart';
import 'package:dating/login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 5 seconds and then navigate based on user authentication
    Timer(Duration(seconds: 5), () {
      checkUserAuthentication();
    
    });
  }

  void checkUserAuthentication() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is authenticated, check if their email is in Firestore
      final userEmail = user.email;
      if (userEmail != null) {
        bool emailExistsInFirestore =
            await doesEmailExistInFirestore(userEmail);

        if (emailExistsInFirestore) {
          // User's email exists in Firestore, navigate to the home page
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Home()));
        } else {
          // User's email doesn't exist in Firestore, navigate to the hobbies page
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Hobbies()));
        }
      } else {
        // Handle the case where the user's email is not available
        // You may want to show an error message or take other actions
      }
    } else {
      // User is not authenticated, navigate to the login page
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  Future<bool> doesEmailExistInFirestore(String email) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference optionsCollection =
        firestore.collection('user_options');

    final doc = await optionsCollection.doc(email).get();
    return doc.exists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Your splash screen content with an image from assets
            Image.asset(
              'assets/5.png', // Replace with the actual path to your image
              fit: BoxFit.cover, // Set the height as needed
            ),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
