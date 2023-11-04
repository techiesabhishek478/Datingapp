import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:firebase_database/firebase_database.dart';

class Hobbies extends StatefulWidget {
  @override
  State<Hobbies> createState() => _HobbiesState();
}

class _HobbiesState extends State<Hobbies> {
  String? username;
  String? profileImageUrl;
  Set<String> _selectedOptions = Set<String>();

  void _handleOptionChange(String label) {
    setState(() {
      if (_selectedOptions.contains(label)) {
        _selectedOptions.remove(label);
      } else {
        _selectedOptions.add(label);
      }
    });
  }

  void _handleSubmit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userEmail = user.email;
      if (userEmail != null) {
        await saveDataToFirestore(
          userEmail, _selectedOptions, username, // Include username
          profileImageUrl,
        );
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else {
      // Handle the case when the user is not authenticated
      // You may want to show an error message or take other actions
    }
  }

  Future<void> saveDataToFirestore(String userEmail,
      Set<String> selectedOptions, String? username, profileImageUrl) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference optionsCollection =
        firestore.collection('user_options');

    await optionsCollection.doc(userEmail).set({
      'options': selectedOptions.toList(),
      'userEmail': userEmail,
      'name': username,
      'profileImageUrl': profileImageUrl,
    });
  }

  Future<void> _fetchUserDatas() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userEmail = user.email;
        if (userEmail != null) {
          final userOptionsDoc = await FirebaseFirestore.instance
              .collection('user_options')
              .doc(userEmail)
              .get();

          if (userOptionsDoc.exists) {
            final userData = userOptionsDoc.data();
            final selectedOptions = userData?['options'];

            setState(() {
              _selectedOptions = Set<String>.from(selectedOptions);
            });
          } else {
            // Handle the case when user options document does not exist.
            // You can set default values or handle it according to your app's logic.
          }
        } else {
          // Handle the case when user's email is null.
        }
      } catch (e) {
        print("Error fetching user options data: $e");
      }
    }
  }

// final Set<String> _selectedOptions = Set<String>();

//   void _handleOptionChange(String label) {
//   setState(() {
//     if (_selectedOptions.contains(label)) {
//       _selectedOptions.remove(label);
//     } else {
//       _selectedOptions.add(label);
//     }
//   });
// }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final userData = userDoc.data();

          final name = userData?['name'];
          final email = userData?['email'];
          final gender = userData?['gender'];
          final city = userData?['city'];
          final dateOfBirth = userData?['dateOfBirth'];
          final mobileNumber = userData?['mobileNumber'];
          final bio = userData?['bio'];
          final userImageUrl =
              userData?['profileImageUrl']; // Fetch user's profile image URL

          setState(() {
            username = name;
            profileImageUrl =
                userImageUrl; // Assign the user's profile image URL
          });
        } else {
          print("User document does not exist.");
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchUserDatas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "  Let's talk lifestyle\n  habits,${username ?? 'Username'}",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '  Do their habits match yours?\n  you go first.',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(
                      thickness: 2,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.local_bar,
                          size: 35,
                          color: Colors.black,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'How often do you drink?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildElevatedButtonOption('Not for me'),
                        SizedBox(width: 10),
                        _buildElevatedButtonOption('Sober curious'),
                      ],
                    ),
                    Row(
                      children: [
                        _buildElevatedButtonOption('On special occasions'),
                         SizedBox(width: 7),
                        _buildElevatedButtonOption('Sober'),
                      ],
                    ),
                    Row(
                      children: [
                        _buildElevatedButtonOption('Socially on weekends'),
                        SizedBox(width: 10),
                        _buildElevatedButtonOption('Most nights'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.smoking_rooms_outlined,
                          size: 35,
                          color: Colors.black,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'How often do you smoke?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildElevatedButtonOption('Social Smoker'),
                        SizedBox(width: 5),
                        _buildElevatedButtonOption('Smoker when drinking'),
                      ],
                    ),
                    Row(
                      children: [
                        _buildElevatedButtonOption('Non-smoker'),
                        SizedBox(width: 10),
                        _buildElevatedButtonOption('Smoker'),
                      ],
                    ),
                    Row(
                      children: [
                        _buildElevatedButtonOption('Trying to quit'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 35,
                          color: Colors.black,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Do You Workout',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildElevatedButtonOption('Everyday'),
                        SizedBox(width: 10),
                        _buildElevatedButtonOption('Often'),
                        SizedBox(width: 10),
                        _buildElevatedButtonOption('Sometimes'),
                      ],
                    ),
                    Row(
                      children: [
                        _buildElevatedButtonOption('Never'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.pets,
                          size: 35,
                          color: Colors.black,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Do You have any pets?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildElevatedButtonOption('Dog'),
                        SizedBox(width: 5),
                        _buildElevatedButtonOption('Cat'),
                        SizedBox(width: 5),
                        _buildElevatedButtonOption('Reptile'),
                        SizedBox(width: 5),
                        _buildElevatedButtonOption("Rabbit"),
                      ],
                    ),
                    Row(
                      children: [
                        _buildElevatedButtonOption('Bird'),
                        SizedBox(width: 5),
                        _buildElevatedButtonOption('Fish'),
                        SizedBox(width: 5),
                        _buildElevatedButtonOption("Don't have but love"),
                      ],
                    ),
                    Row(
                      children: [
                        _buildElevatedButtonOption('Other'),
                        SizedBox(width: 10),
                        _buildElevatedButtonOption('Turtle'),
                        SizedBox(width: 10),
                        _buildElevatedButtonOption("Hamster"),
                      ],
                    ),
                    Row(
                      children: [
                        _buildElevatedButtonOption('Pet-free'),
                        SizedBox(width: 10),
                        _buildElevatedButtonOption('All the pets'),
                      ],
                    ),
                    Row(
                      children: [
                        _buildElevatedButtonOption('Allergic to pets'),
                        SizedBox(width: 8),
                        _buildElevatedButtonOption('Amphibian'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        _buildElevatedButtonOption("Want a pet"),
                      ],
                    ),
                    Divider(
                      color: Colors.grey,
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: Container(
                        width: 150,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            primary: Colors.black, // Background color
                            onPrimary: Colors.white, // Text color
                          ),
                          child: Text("Submit"),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElevatedButtonOption(String label) {
    final isSelected = _selectedOptions.contains(label);
    return ElevatedButton(
      onPressed: () {
        _handleOptionChange(label);
      },
      style: ButtonStyle(
        backgroundColor: isSelected
            ? MaterialStateProperty.all<Color>(Colors.red)
            : MaterialStateProperty.all<Color>(Colors.white),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
