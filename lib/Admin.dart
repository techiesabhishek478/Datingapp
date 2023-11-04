import 'package:dating/Admin/ViewAllUser.dart';
import 'package:dating/Admin/ViewFeedBack.dart';
import 'package:dating/Admin/ViewLikedImage.dart';
import 'package:dating/Login.dart';
import 'package:dating/ViewAllPost.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Import the fl_chart library
import 'package:cloud_firestore/cloud_firestore.dart'; // Import the cloud_firestore package

class AdminHome extends StatefulWidget {
  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  // Sample data for user activity (you can replace it with your actual data)
  List<FlSpot> userActivityData = [];

  @override
  void initState() {
    super.initState();
    // Fetch product data when the widget is initialized
    fetchProductData().then((data) {
      setState(() {
        userActivityData = data;
      });
    });
  }

  Future<List<FlSpot>> fetchProductData() async {
    // Reference to the Firestore collection
    CollectionReference productsCollection =
        FirebaseFirestore.instance.collection('products');

    // Fetch the documents from the "products" collection
    QuerySnapshot productData = await productsCollection.get();

    // Process the data to create FlSpot objects
    List<FlSpot> dataPoints = [];
    int index = 0;

    for (QueryDocumentSnapshot product in productData.docs) {
      // Use your data fields from the document, e.g., 'quantity' and 'timestamp'
      double quantity = (product['quantity'] as num).toDouble();
      dataPoints.add(FlSpot(index.toDouble(), quantity));
      index++;
    }

    return dataPoints;
  }

  void _handleLogout() {
    // Implement your logout logic here, e.g., navigate to the login page
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
         automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          // Container(
          //     width: double.infinity,
          //     height: 300,
          //     padding: EdgeInsets.all(16),
          //     child: LineChart(
          //       LineChartData(
          //         titlesData: FlTitlesData(show: false),
          //         gridData: FlGridData(
          //           show: false,
          //         ),
          //         borderData: FlBorderData(
          //           show: true,
          //           border: Border(
          //             top: BorderSide(color: Colors.blue, width: 2),
          //             bottom: BorderSide(color: Colors.blue, width: 2),
          //             left: BorderSide(color: Colors.blue, width: 2),
          //             right: BorderSide(color: Colors.blue, width: 2),
          //           ),
          //         ),
          //         minX: 0,
          //         maxX:
          //             userActivityData.isNotEmpty ? userActivityData.last.x : 1,
          //         minY: 0,
          //         maxY: getMaxY(userActivityData) + 20,
          //         lineBarsData: [
          //           LineChartBarData(
          //             spots: userActivityData,
          //             isCurved: true,
          //             belowBarData: BarAreaData(show: true),
          //             color: Colors.blue, // Set the line color
          //           ),
          //         ],
          //       ),
          //     )),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: <Widget>[
                // The rest of your DashboardOption widgets
                DashboardOption(
                  title: 'View All Users',
                  icon: Icons.people,
                  onTap: () {
                    // Navigate to a page to view all users
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewAllUsersPage()),
                    );
                  },
                ),
                DashboardOption(
                  title: 'View Feedback',
                  icon: Icons.feedback,
                  onTap: () {
                    // Navigate to a page to view feedback
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewFeedbackPage()),
                    );
                  },
                ),
                DashboardOption(
                  title: 'View Liked Images',
                  icon: Icons.image,
                  onTap: () {
                    // Navigate to a page to view liked images
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewLikedImagesPage()),
                    );
                  },
                ),
                DashboardOption(
                  title: "View All Post's",
                  icon: Icons.post_add_outlined,
                  onTap: () {
                    // Navigate to a page to view liked images
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewAllPostsPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

double getMaxY(List<FlSpot> data) {
  double max = 0;
  for (var spot in data) {
    if (spot.y > max) {
      max = spot.y;
    }
  }
  return max;
}

class DashboardOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function onTap;

  DashboardOption(
      {required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 60, color: Colors.blue),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
