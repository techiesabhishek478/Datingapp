import 'package:dating/All%20user.dart';
import 'package:dating/Suggation.dart';
import 'package:dating/UploadImagesPage.dart';
import 'package:flutter/material.dart';

class Viewpage extends StatefulWidget {
  @override
  State<Viewpage> createState() => _ViewpageState();
}

class _ViewpageState extends State<Viewpage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 177, 12, 0),
          title: Text("User's",style: TextStyle(color: Colors.white,fontSize: 25),),
          bottom: TabBar(
            labelColor: Colors.white, // Selected tab label color
            unselectedLabelColor: Colors.black, // Unselected tab label color
            indicatorColor: Colors.white, // Tab indicator color
            tabs: [
              Tab(text: "View All User's"),
              Tab(text: "Suggestion User's"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ViewAllUsers(), // First Tab Content
            Suggestion(), // Second Tab Content
          ],
        ),
      ),
    );
  }
}
