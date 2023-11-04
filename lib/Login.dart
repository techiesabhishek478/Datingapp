import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/hobbiespage.dart';
import 'package:dating/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Admin.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

 Future<void> _login() async {
  if (_formKey.currentState!.validate() && !_loading) {
    setState(() {
      _loading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Check if the user's email exists in the 'user_options' collection
      final user = _auth.currentUser;
      if (user != null) {
        final userEmail = user.email;
        if (userEmail != null) {
          bool emailExistsInFirestore = await doesEmailExistInFirestore(userEmail);

          if (emailExistsInFirestore) {
            // User's email exists in Firestore
            setState(() {
              _loading = false;
            });
            
            if (userEmail == "admin@admin.com") {
              // Navigate to AdminHome page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdminHome()),
              );
            } else {
              // Navigate to the regular Home page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            }
          } else {
            // User's email doesn't exist in Firestore, navigate to the hobbies page
            setState(() {
              _loading = false;
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Hobbies()),
            );
          }
        }
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _loading = false;
      });
    }
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
        body: Stack(children: <Widget>[
      // Background image
      Image.asset(
        'assets/6.png', // Replace with the actual path to your background image
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),

      Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 290,),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email',labelStyle: TextStyle(color: Colors.white)),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter an email address.';
                    }
                    return null;
                  },
                   style: TextStyle(color: Colors.white),
                ),
                
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password',labelStyle: TextStyle(color: Colors.white)),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a password.';
                    }
                    return null;
                  },
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: _login,
                  child: _loading ? CircularProgressIndicator() : Text('Login'),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Don't have an account? ",style: TextStyle(color: Colors.white,fontSize: 19),),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                      
                      child: Text(
                        "Signup",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 19
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ]));
  }
}
