import 'dart:io';
import 'package:dating/home.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class UploadImagesPage extends StatefulWidget {
  const UploadImagesPage({Key? key});

  @override
  State<UploadImagesPage> createState() => _UploadImagesPageState();
}

class _UploadImagesPageState extends State<UploadImagesPage> {
  final _descriptionController = TextEditingController();
  XFile? _imageFile;
  bool _isUploading = false;
  String _uploadMessage = '';

  void _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

 Future<void> _uploadPost() async {
  if (_imageFile != null) {
    String description = _descriptionController.text;

    // Get the authenticated user
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Create a map with the product data
      Map<String, dynamic> productData = {
        'description': description,
        'userEmail': user.email,
        // Add other product details here
      };

      // Simulate an upload with a delay for demonstration purposes.
      setState(() {
        _isUploading = true;
      });

      // You should replace this with your actual Firestore and Firebase Storage logic.
      // Store the product data in a 'products' collection.
      try {
        final result = await FirebaseFirestore.instance.collection('products').add(productData);

        // Store the image in Firebase Storage and get the download URL
        final storageRef = FirebaseStorage.instance.ref().child('products/${result.id}.jpg');
        await storageRef.putFile(File(_imageFile!.path));
        final imageUrl = await storageRef.getDownloadURL();

        // Update the Firestore document with the image URL
        await result.update({'imageUrl': imageUrl});

        setState(() {
          _isUploading = false;
          _uploadMessage = 'Uploaded successfully!';
        });
      } catch (error) {
        setState(() {
          _isUploading = false;
          _uploadMessage = 'Error uploading: $error';
        });
      }
    } else {
      setState(() {
        _uploadMessage = 'User not authenticated. Please log in.';
      });
    }
  } else {
    setState(() {
      _uploadMessage = 'Please select an image first.';
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Upload Post',style: TextStyle(color: Colors.white),),
        backgroundColor:Color.fromARGB(255, 177, 12, 0), // Customize the app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Wrap the Column with a SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min, // Set mainAxisSize to min
            children: <Widget>[
              _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.file(
                        File(_imageFile!.path),
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                    ),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick an Image',style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 177, 12, 0), // Button color
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadPost,
                child: Text('Upload Post',style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 177, 12, 0), // Button color
                ),
              ),
              if (_isUploading)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(),
                ),
              if (_uploadMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _uploadMessage,
                    style: TextStyle(
                      color: _uploadMessage.startsWith('Error') ? Colors.red : Colors.green,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
