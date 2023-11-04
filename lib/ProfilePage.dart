import 'dart:io';
import 'dart:typed_data';
import 'package:dating/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileUpdatePage extends StatefulWidget {
  @override
  _ProfileUpdatePageState createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  bool _isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _refreshUserData() async {
    await _fetchUserData();
  }

  Uint8List? _image;
  final TextEditingController bioController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  String _selectedGender = 'Male';
  List<String> _genderOptions = ['Male', 'Female', 'Other'];

  void ProfileUpdate() async {
  String username = usernameController.text;
  String email = emailController.text;
  String mobileNumber = mobileNumberController.text;
  String dob = dobController.text;
  String gender = _selectedGender;
  String bio = bioController.text; // Get the user's bio

  await FirebaseFirestore.instance.collection('users').doc(_user.uid).update({
    'name': username,
    'email': email,
    'mobileNumber': mobileNumber,
    'dateOfBirth': dob,
    'gender': gender,
    'city': _city,
    'name': _name,
    'bio': bio, // Save the user's bio
  });

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('Profile updated successfully!'),
    duration: Duration(seconds: 2),
  ));
}

  late User _user;
  String _username = '';
  String _email = '';
  String _mobileNumber = '';
  DateTime? _dob;
  String _city = '';
  String _name = '';

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileNumberController = TextEditingController();
  TextEditingController _dobController = TextEditingController();

  List<String> predefinedProfileImages = [
    
  
    
    
    "https://i.pinimg.com/564x/65/1f/7a/651f7a8f13202b1439383541807b66c5.jpg",
    "https://i.pinimg.com/564x/8f/26/99/8f2699244cfea107be75146d28ddbb47.jpg",
    "https://i.pinimg.com/564x/3a/ad/9a/3aad9a9713a142589d3ec2d7e56be442.jpg",
    "https://i.pinimg.com/564x/8d/ae/30/8dae304df0d54ecc2b862490ab521e4a.jpg",
    "https://i.pinimg.com/564x/cc/bf/d3/ccbfd3030c85a522fff32dc69ea970bc.jpg",
    "https://i.pinimg.com/736x/5f/7d/0a/5f7d0afd678c1d4d8e60d8b988e04cac.jpg",
      "https://i.pinimg.com/474x/c1/77/84/c17784b377f5b7da881a0ce6f4315b4e.jpg",
    "https://i.pinimg.com/474x/e6/a4/f8/e6a4f8683090abdb3d05ec2c0484206d.jpg",
    "https://i.pinimg.com/564x/2a/78/83/2a7883f9f669d143e7a2620fcfb369e3.jpg",
    "https://i.pinimg.com/564x/44/46/a3/4446a319b1029b08b16be2c9a19410bf.jpg",
    "https://i.pinimg.com/474x/7d/24/f7/7d24f7bcd27c8e6a0905b73edd7761bf.jpg",
    "https://i.pinimg.com/474x/40/84/63/4084638684fc77fb6c34d3b42093dd6d.jpg",
    "https://i.pinimg.com/564x/59/55/b8/5955b86397516e21b4e9ed5ce1c07f28.jpg",
  ];

  @override
  void initState() {
    super.initState();
    _isPasswordVisible = false;
    _user = FirebaseAuth.instance.currentUser!;
    _fetchUserData();
  }

Future<void> _fetchUserData() async {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final email = user.email;
    final userDataQuery = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (userDataQuery.exists) {
      final userData = userDataQuery.data() as Map<String, dynamic>;

      setState(() {
        usernameController.text = userData['name'] ?? '';
        emailController.text = email ?? '';
        mobileNumberController.text = userData['mobileNumber'] ?? '';
        _city = userData['city'] ?? '';
        _name = userData['name'] ?? '';
        bioController.text = userData['bio'] ?? ''; // Set the user's bio

        if (userData['dateOfBirth'] != null) {
          if (userData['dateOfBirth'] is Timestamp) {
            final timestamp = userData['dateOfBirth'] as Timestamp;
            final dateOfBirth = timestamp.toDate();
            _dob = dateOfBirth;
            _dobController.text = _formatDate(dateOfBirth);
          } else if (userData['dateOfBirth'] is String) {
            // Handle the case when 'dateOfBirth' is stored as a String
            // You can parse the date from the String if needed
            // Example: _dobController.text = userData['dateOfBirth'];
          }
        }
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      _dobController.text = prefs.getString('dateOfBirth') ?? '';
    }
  }
}


String _formatDate(DateTime date) {
  final day = date.day.toString();
  final month = date.month.toString();
  final year = date.year.toString();
  return '$day/$month/$year'; // Customize the format as needed
}


  Future<void> _getImageFromGallery() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path) as Uint8List?;
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _getImageFromCamera() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path) as Uint8List?;
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _showProfileImageSelectionDialog() async {
    int _currentIndex = 0;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black54,
          title: Text(
            'Select Profile Image',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 300,
            height: 200,
            child: PageView.builder(
              itemCount: predefinedProfileImages.length,
              controller: PageController(initialPage: _currentIndex),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (BuildContext context, int index) {
                final imageUrl = predefinedProfileImages[index];
                return GestureDetector(
                  onTap: () {
                    _refreshUserData();
                    _updateProfileImage(imageUrl);
                    Navigator.of(context).pop(true);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Hero(
                      tag: imageUrl,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(imageUrl),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _refreshUserData();
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ))!;

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dob = picked;
        _dobController.text = picked.toLocal().toString().split(' ')[0];
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('dob', _dobController.text);
    }
  }

  void _updateProfileImage(String imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(_user.uid).update({
        'profileImageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile image updated successfully!'),
        duration: Duration(seconds: 2),
      ));
    } catch (error) {
      print('Error updating profile image: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor:Color.fromARGB(255, 177, 12, 0),
        title: Text('Profile Update',style: TextStyle(color: Colors.white),),
        // leading: IconButton(
        //   icon: Icon(
        //     Icons.arrow_back,
        //     size: 30,
        //   ),
        //   onPressed: () {
        //     Navigator.pushReplacement(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => Home(),
        //       ),
        //     );
        //   },
        // ),
        
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                _showProfileImageSelectionDialog();
              },
              child: imageProfile(),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                
                enabled: false,
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: TextStyle(
                color: Colors.white,
              ),
              enabled: false,
            ),
            SizedBox(height: 10.0),
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.white)
              ),
               style: TextStyle(
                color: Colors.white,
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
              ],
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Username is required';
                }
                final RegExp usernameRegExp = RegExp(r'^[a-zA-Z\s]+$');
                if (!usernameRegExp.hasMatch(value)) {
                  return 'Username must contain only alphabetic characters and spaces and should not exceed 20 characters';
                }
                if (value.contains(RegExp(r'[0-9]'))) {
                  return 'Username cannot contain numbers';
                }
                return null;
              },
            ),
            SizedBox(height: 10.0),
            TextField(
  controller: bioController,
  decoration: InputDecoration(
    labelText: 'Bio',
    labelStyle: TextStyle(color: Colors.white),
  ),
  style: TextStyle(color: Colors.white),
  maxLength: 60, // Set the maximum length for the bio
  maxLines: 2, // Allow up to 2 lines for the bio
),
SizedBox(height: 10.0),

            TextField(
              controller: mobileNumberController,
              decoration: InputDecoration(labelText: 'Mobile Number',
              labelStyle: TextStyle(color: Colors.white)
              ),
              style: TextStyle(color: Colors.white),

              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
            ),
            SizedBox(height: 10.0),
            DropdownButtonFormField<String>(
              dropdownColor:Color.fromARGB(255, 177, 12, 0),
              decoration: InputDecoration(labelText: 'Select Gender',labelStyle: TextStyle(color: Colors.white)
              ),
                  style: TextStyle(color: Colors.white),

              value: _selectedGender,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue!;
                });
              },
              items: _genderOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            GestureDetector(
              onTap: () {
                _selectDate(context);
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: _dobController,
                  decoration: InputDecoration(labelText: 'Date of Birth',labelStyle: TextStyle(color: Colors.white)),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(30.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 177, 12, 0), Color.fromARGB(255, 177, 12, 0),],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ElevatedButton(
            onPressed: () {
              _refreshUserData();
              ProfileUpdate();
            },
            child: Text(
              'Save',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
              elevation: MaterialStateProperty.all(0),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
          ),
        ),
      ),
    );
  }

  Widget imageProfile() {
    if (_user != null) {
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(_user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final userData = snapshot.data?.data() as Map<String, dynamic>?;
            final profileImageUrl = userData?['profileImageUrl'] as String?;

            return Stack(
              children: [
                _image != null
                    ? CircleAvatar(
                        radius: 64,
                        backgroundImage: MemoryImage(_image!),
                      )
                    : profileImageUrl != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage: NetworkImage(profileImageUrl),
                          )
                        : const CircleAvatar(
                            radius: 64,
                            backgroundImage: NetworkImage(
                                "https://static.thenounproject.com/png/5034901-200.png"),
                          ),
                Positioned(
                  child: GestureDetector(
                    onTap: () {
                      _showProfileImageSelectionDialog();
                    },
                    child: Icon(
                      Icons.mode_edit_outline_rounded,
                      size: 30,
                      color: Color.fromARGB(255, 177, 12, 0),
                    ),
                  ),
                  bottom: 0.3,
                  left: 90,
                ),
              ],
            );
          }
        },
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}
