import 'package:dating/moreview.dart';
import 'package:flutter/material.dart';


class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      
      appBar: null, // Set app bar to null
      body: Stack(
        children: [
           Image.asset(
            'assets/l.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        
          Positioned(
                  top: 0,
                  left: 10,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MoreView()));
                          },
                        ),
                      ),
                    ),
                  ),
                ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 350,),
                Text(
                  'Welcome to Our App!',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'About Us:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Welcome to Let's Date, where we believe in love at first swipe. Our dating app is designed to help you effortlessly find your soulmate or perfect match. Discover meaningful connections and create unforgettable moments with ease. It's time to embark on your romantic journey!",
                  style: TextStyle(fontSize: 16 ,color: Colors.white),
                ),
                SizedBox(height: 16),
                Text(
                  'Contact Information:',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Email: contact@app.com',
                  style: TextStyle(fontSize: 16,color: Colors.white),
                ),
                Text(
                  'Phone: +1 (123) 456-7890',
                  style: TextStyle(fontSize: 16,color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AboutPage(),
  ));
}