import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewAllPostsPage extends StatefulWidget {
  @override
  _ViewAllPostsPageState createState() => _ViewAllPostsPageState();
}

class _ViewAllPostsPageState extends State<ViewAllPostsPage> {
  final CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View All Products'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: productsCollection.snapshots(),
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

          List<QueryDocumentSnapshot> productsList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: productsList.length,
            itemBuilder: (context, index) {
              var productData = productsList[index].data() as Map<String, dynamic>;
              String description = productData['description'] ?? 'No description';
              String imageUrl = productData['imageUrl'] ??
                  'https://path_to_default_image.jpg';
              String userEmail = productData['userEmail'] ?? 'No email provided';

              return ProductCard(
                description: description,
                imageUrl: imageUrl,
                userEmail: userEmail,
                onDelete: () {
                  // Implement the logic to delete the product
                  deleteProduct(productsList[index].id);
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await productsCollection.doc(productId).delete();
    } catch (e) {
      print('Error deleting product: $e');
    }
  }
}

class ProductCard extends StatelessWidget {
  final String description;
  final String imageUrl;
  final String userEmail;
  final VoidCallback onDelete;

  ProductCard({
    required this.description,
    required this.imageUrl,
    required this.userEmail,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          Image.network(imageUrl), // Load image from URL
          ListTile(
            title: Text('Description: $description'),
            subtitle: Text('User Email: $userEmail'),
          ),
          ElevatedButton(
            onPressed: onDelete,
            child: Text('Delete Product'),
          ),
        ],
      ),
    );
  }
}
