import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: StoryInput()));
}

class Story {
  final String text;
  final String imageUrl;
  final String videoUrl;
  final String userEmail;
  final String storyId;

  Story({
    this.text = '',
    this.imageUrl = '',
    this.videoUrl = '',
    required this.storyId,
    required this.userEmail,
  });
}

class StoryInput extends StatefulWidget {
  @override
  _StoryInputState createState() => _StoryInputState();
}

class _StoryInputState extends State<StoryInput> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController textController = TextEditingController();
  String selectedImage = '';
  String selectedVideo = '';

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    Future<void> setImage(String imageUrl) async {
      setState(() {
        selectedImage = imageUrl;
      });
    }

    Future<void> setVideo(String videoUrl) async {
      setState(() {
        selectedVideo = videoUrl;
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Add a Story',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 177, 12, 0),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () async {
                    final image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      final imageUrl = await uploadFile(image.path, 'images/');
                      await setImage(imageUrl);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      image: selectedImage.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(selectedImage),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: selectedImage.isEmpty
                        ? Center(
                            child: Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              Card(
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () async {
                    final video = await ImagePicker()
                        .pickVideo(source: ImageSource.gallery);
                    if (video != null) {
                      final videoUrl = await uploadVideo(video.path, 'videos/');
                      await setVideo(videoUrl);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    child: selectedVideo.isNotEmpty
                        ? VideoPlayerWidget(selectedVideo)
                        : Center(
                            child: Icon(
                              Icons.videocam,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: 'Write a story',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                style: TextStyle(color: Colors.white),
                maxLines: 4,
              ),
              SizedBox(
                height: 5,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (user != null) {
                    final storyId =
                        DateTime.now().millisecondsSinceEpoch.toString();
                    final story = Story(
                      storyId: storyId,
                      text: textController.text,
                      imageUrl: selectedImage,
                      videoUrl: selectedVideo,
                      userEmail: user.email ?? '',
                    );
                    await saveStory(story);
                    final userEmail = user.email ?? '';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StoryView(selectedUserEmail: userEmail),
                      ),
                    );
                  }
                },
                child: Text(
                  'Add Story',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 177, 12, 0),
                  padding: EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> uploadFile(String filePath, String folderName) async {
    final Reference storageReference =
        FirebaseStorage.instance.ref('$folderName/${DateTime.now()}');
    final UploadTask uploadTask = storageReference.putFile(File(filePath));
    await uploadTask;
    final String downloadURL = await storageReference.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideo(String filePath, String folderName) async {
    final Reference storageReference =
        FirebaseStorage.instance.ref('$folderName/${DateTime.now()}.mp4');
    final UploadTask uploadTask = storageReference.putFile(File(filePath));
    await uploadTask;
    final String downloadURL = await storageReference.getDownloadURL();
    return downloadURL;
  }

  Future<void> saveStory(Story story) async {
    await FirebaseFirestore.instance.collection('stories').add({
      'text': story.text,
      'imageUrl': story.imageUrl,
      'videoUrl': story.videoUrl,
      'userId': story.userEmail,
    });
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  VideoPlayerWidget(this.videoUrl);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          // Ensure the first frame is shown
          _controller.play();
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class StoryView extends StatelessWidget {
  final String selectedUserEmail;

  StoryView({required this.selectedUserEmail});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    void deleteStory(String storyId) async {
      if (user != null && user.email == selectedUserEmail) {
        await FirebaseFirestore.instance
            .collection('stories')
            .doc(storyId)
            .delete();
      }
    }

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            'Stories',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color.fromARGB(255, 177, 12, 0),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('stories')
              .where('userId', isEqualTo: selectedUserEmail)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final stories =
                snapshot.data!.docs.map((DocumentSnapshot document) {
              final data = document.data() as Map<String, dynamic>;
              final text = data['text'] as String? ?? '';
              final imageUrl = data['imageUrl'] as String? ?? '';
              final videoUrl = data['videoUrl'] as String? ?? '';
              final storyId = document.id;

              return Story(
                text: text,
                imageUrl: imageUrl,
                videoUrl: videoUrl,
                userEmail: selectedUserEmail,
                storyId: storyId,
              );
            }).toList();
            if (stories.isEmpty) {
              return Center(
                child: Text('No stories available.',
                    style: TextStyle(color: Colors.white)),
              );
            }

            return ListView.builder(
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                return StoryCard(
                  story: story,
                  user: user,
                  deleteStory: () => deleteStory(story.storyId),
                );
              },
            );
          },
        ));
  }
}

class StoryCard extends StatelessWidget {
  final Story story;
  final User? user;
  final void Function() deleteStory;

  StoryCard({
    required this.story,
    required this.user,
    required this.deleteStory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (story.text.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                story.text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (story.imageUrl.isNotEmpty)
            Image.network(
              story.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          if (story.videoUrl.isNotEmpty) VideoPlayerWidget(story.videoUrl),
          if (user != null && user!.email == story.userEmail)
            ElevatedButton(
              onPressed: deleteStory,
              child: Text('Delete', style: TextStyle(color: Colors.white)),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Color.fromARGB(255, 177, 12, 0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
