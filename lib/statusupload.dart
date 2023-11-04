import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StatusUploadPage extends StatefulWidget {
  @override
  _StatusUploadPageState createState() => _StatusUploadPageState();
}

class _StatusUploadPageState extends State<StatusUploadPage> {
  final picker = ImagePicker();
  XFile? _selectedMedia; // Use XFile instead of PickedFile

  Future<void> _pickMedia() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // Use pickImage
    setState(() {
      _selectedMedia = pickedFile;
    });
  }

  Future<void> _uploadStatus() async {
    if (_selectedMedia != null) {
      final Reference storageRef = FirebaseStorage.instance.ref().child(DateTime.now().toString());
      final UploadTask uploadTask = storageRef.putFile(File(_selectedMedia!.path));
      await uploadTask.whenComplete(() => print('Status uploaded'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Upload Status'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_selectedMedia != null)
              Image.file(File(_selectedMedia!.path))
            else
              Text('No media selected'),
            ElevatedButton(
              onPressed: _pickMedia,
              child: Text('Select Media'),
            ),
            ElevatedButton(
              onPressed: _uploadStatus,
              child: Text('Upload Status'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: StatusUploadPage()));
