import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NextPage extends StatelessWidget {
  final DocumentSnapshot<Map<String, dynamic>> productSnapshot;

  NextPage({required this.productSnapshot});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> product = productSnapshot.data() as Map<String, dynamic>;

    // Build your NextPage using the product data
    // ...

    return Scaffold(
      appBar: AppBar(
        title: Text('Next Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display product details using the 'product' data
          ],
        ),
      ),
    );
  }
}