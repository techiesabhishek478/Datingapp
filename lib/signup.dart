import 'package:dating/Login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  String _selectedGender = 'Male';
  final _formKey = GlobalKey<FormState>();

  bool _loading = false; // Manage signup loading state

  Future<void> _signup() async {
    if (_formKey.currentState!.validate() && !_loading) {
      setState(() {
        _loading = true; // Show loading indicator
      });

      try {
        final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (userCredential.user != null) {
          final user = userCredential.user;
          await _firestore.collection('users').doc(user!.uid).set({
            'name': _nameController.text,
            'email': user!.email,
            'city': _cityController.text,
            'gender': _selectedGender,
            'dateOfBirth': _selectedDate,
            'mobileNumber': _mobileNumberController.text,
          });

        
          setState(() {
            _loading = false; // Hide loading indicator
          });

          // Show a success message using a dialog
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Signup Success'),
                content: Text('You have successfully signed up.'),
                actions: [
                  TextButton(
                    onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage())); // Close the dialog
                      // Navigate to another page
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => NextPage()));
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _loading = false; // Hide loading indicator on error
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _ageController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  final TextEditingController _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Stack(children: <Widget>[
      // Background image
      Image.asset(
        'assets/7.png', // Replace with the actual path to your background image
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
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email',labelStyle: TextStyle(color: Colors.white)),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter an email address.';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9.]+@gmail\.com$').hasMatch(value)) {
                      return 'Please enter a valid Gmail address.';
                    }
                    return null;
                  },
               style: TextStyle(color: Colors.white),
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name',labelStyle: TextStyle(color: Colors.white)),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your name.';
                    }
                    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                      return 'Name can only contain alphabets and spaces.';
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
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(labelText: 'Confirm Password',labelStyle: TextStyle(color: Colors.white)),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match.';
                    }
                    return null;
                  },
                   style: TextStyle(color: Colors.white),
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(labelText: 'Age (Date of Birth)',labelStyle: TextStyle(color: Colors.white)),
                  onTap: () {
                    _selectDate(context);
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your date of birth.';
                    }
                    return null;
                  },
                   style: TextStyle(color: Colors.white),
                ),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(labelText: 'City',labelStyle: TextStyle(color: Colors.white)),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your city.';
                    }
                    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                      return 'City can only contain alphabets and spaces.';
                    }
                    return null;
                  },
                   style: TextStyle(color: Colors.white),
                ),
                TextFormField(
                  controller: _mobileNumberController,
                  decoration: InputDecoration(labelText: 'Mobile Number',labelStyle: TextStyle(color: Colors.white)),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your mobile number.';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Mobile number must be exactly 10 digits.';
                    }
                    return null;
                  },
                   style: TextStyle(color: Colors.white),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                  items: [
                    DropdownMenuItem(value: 'Male', child: Text('Male',style: TextStyle(color: Colors.white),)),
                    DropdownMenuItem(value: 'Female', child: Text('Female',style: TextStyle(color: Colors.white),)),
                    DropdownMenuItem(value: 'Other', child: Text('Other',style: TextStyle(color: Colors.white),)),
                  ],
                  hint: Text('Select Gender',style: TextStyle(color: Colors.white),),
                  dropdownColor: Colors.black,
                ),
                SizedBox(height: 10,),
                ElevatedButton(
                  onPressed: _signup,
                  child: _loading
                      ? CircularProgressIndicator() // Show loading indicator
                      : Text('Sign Up'),
                ),
               SizedBox(height: 10), // Add some spacing
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("I have an account. ",style: TextStyle(color: Colors.white,fontSize: 19),),
                    GestureDetector(
                      onTap: () {
                        // Navigate to the login page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
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
