import 'package:dating/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String name;
  final String city;
  final String profileImageUrl;

  UserProfile({
    required this.name,
    required this.city,
    required this.profileImageUrl,
    l,
  });
}

class Nearyouuser extends StatefulWidget {
  const Nearyouuser({Key? key}) : super(key: key);

  @override
  _NearyouuserState createState() => _NearyouuserState();
}

class _NearyouuserState extends State<Nearyouuser> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _fetchAuthenticatedUserCity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(
              body: Center(child: Text("Error: ${snapshot.error}")));
        }

        final authenticatedUserCity = snapshot.data;

        return Scaffold(
           backgroundColor: Colors.black,
          appBar: AppBar(
             leading: IconButton(icon: Icon(Icons.arrow_back,color: Colors.black,),onPressed: () {
               Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => Home()));
            },),
            
            // actions: [
            //   IconButton(
            //       onPressed: () {
            //         Navigator.pushReplacement(context,
            //             MaterialPageRoute(builder: (context) => Home()));
            //       },
            //       icon: Icon(Icons.arrow_back))
            // ],
            title: Text("Users in Your City",style: TextStyle(color: Colors.white),),
            backgroundColor: Color.fromARGB(255, 177, 12, 0),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .where('city', isEqualTo: authenticatedUserCity)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                    child: Text("No user data available in your city.",style: TextStyle(color: Colors.white),));
              }

              final userDocs = snapshot.data!.docs;

              return ListView.builder(
                itemCount: userDocs.length,
                itemBuilder: (context, index) {
                  final userDoc = userDocs[index];
                  final user = UserProfile(
                    name: userDoc['name'],
                    city: userDoc['city'],
                    profileImageUrl: userDoc['profileImageUrl'],
                  );

                  return ListTile(
                    leading: Image.network(user.profileImageUrl),
                    title: Text(user.name,style: TextStyle(color: Colors.white),),
                    subtitle: Text(user.city,style: TextStyle(color: Colors.white),),
                    // trailing: IconButton(
                    //   icon: Icon(Icons.person_add),
                    //   onPressed: () {
                    //     sendFriendRequest(userDoc['email']);
                    //   },
                    // ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<String> _fetchAuthenticatedUserCity() async {
     try {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userCity = userDoc['city'] ?? '';
      print('Authenticated User City: $userCity'); // Add this line
      return userCity;
    }
  } catch (e) {
    print('Error fetching authenticated user: $e');
  }
  return ''; // Return a default value if there is an error.
}

  void sendFriendRequest(String friendEmail) {
    // Your sendFriendRequest implementation.
  }
}

void main() {
  runApp(MaterialApp(
    home: Nearyouuser(),
  ));
}
