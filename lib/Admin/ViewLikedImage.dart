import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewLikedImagesPage extends StatefulWidget {
  @override
  State<ViewLikedImagesPage> createState() => _ViewLikedImagesPageState();
}

class _ViewLikedImagesPageState extends State<ViewLikedImagesPage> {
  final CollectionReference likedImagesCollection =
      FirebaseFirestore.instance.collection('liked_images');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Liked Images'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: likedImagesCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<QueryDocumentSnapshot> likedImages = snapshot.data!.docs;

          return ListView.builder(
            itemCount: likedImages.length,
            itemBuilder: (context, index) {
              var imageData = likedImages[index].data() as Map<String, dynamic>;

              // Customize the design format as per your requirements
              // Inside the StreamBuilder where you create LikedImageCard:
return LikedImageCard(
  imageUrl: imageData['imageUrl'] ?? 'https://example.com/default.jpg',
  title: imageData['title'] ?? 'Untitled',
  description: imageData['description'] ?? 'No description',
  userEmail: imageData['userEmail'] ?? 'No email provided',
);

            },
          );
        },
      ),
    );
  }
}
class LikedImageCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String userEmail;

  LikedImageCard({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          Image.network(imageUrl), // Load image from URL
          ListTile(
            title: Text(title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description),
                Text(
                  'User Email: $userEmail',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
