import 'package:dating/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Favorites(),
    );
  }
}

class Favorites extends StatefulWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  late User? currentUser;
  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp();
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("User not authenticated");
    }
    await fetchLikedImages();
  }

  Future<void> fetchLikedImages() async {
    final String currentUserEmail = currentUser!.email!;
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('liked_images')
        .where('userEmail', isEqualTo: currentUserEmail)
        .get();

    setState(() {
      data = querySnapshot.docs.map((doc) {
        final Map<String, dynamic> item = doc.data() as Map<String, dynamic>;
        item['documentID'] = doc.id; // Store the document ID
        return item;
      }).toList();
    });
  }

  Future<void> unlikeImage(String imageUrl) async {
    // Find the document ID for the given imageUrl
    String? documentID;
    for (final item in data) {
      if (item['imageUrl'] == imageUrl) {
        documentID = item['documentID'];
        break;
      }
    }

    if (documentID != null) {
      // Delete it from the Firestore database
      final DocumentReference documentReference =
          FirebaseFirestore.instance.collection('liked_images').doc(documentID);
      await documentReference.delete();
      // Remove the item from the list
      setState(() {
        data.removeWhere((item) => item['imageUrl'] == imageUrl);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Favorites',style: TextStyle(color: Colors.white),),
         backgroundColor: Color.fromARGB(255, 177, 12, 0),
      ),
      body: data.isEmpty
          ? Center(
              // Display a message when the list is empty
              child: Text('No favorite Image',style: TextStyle(color: Colors.white),),
            )
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final imageUrl = data[index]['imageUrl'];
                final timestamp = data[index]['timestamp'];
                final userEmail = data[index]['userEmail'];

                return Card(
                  elevation: 4,
                  margin: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 400,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('User Email: $userEmail'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              unlikeImage(imageUrl);
                            },
                            style: TextButton.styleFrom(primary: Colors.red),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 340),
                              child: Icon(
                                Icons.favorite, // Use the favorite (heart) icon
                                color: Colors.red, // Set the color to red
                                size: 24, // Set the size of the icon
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
