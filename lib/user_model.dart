
class MyUser {
  final String city;
  final String dateOfBirth;
  final String email;
  final String gender;
  final String mobileNumber;
  final String name;
  final String profileImageUrl;
  bool friendRequestSent;
  bool friendRequestReceived;
   bool isBlocked;

  MyUser({
    required this.city,
    required this.dateOfBirth,
    required this.email,
    required this.gender,
    required this.mobileNumber,
    required this.name,
    required this.profileImageUrl,
    this.friendRequestSent = false,
    this.friendRequestReceived = false,
    this.isBlocked = false
  });

  factory MyUser.fromMap(Map<String, dynamic> data) {
    return MyUser(
      city: data['city'] ?? "",
      dateOfBirth: data['dateOfBirth'] ?? "",
      email: data['email'] ?? "",
      gender: data['gender'] ?? "",
      mobileNumber: data['mobileNumber'] ?? "",
      name: data['name'] ?? "",
      profileImageUrl: data['profileImageUrl'] ?? "",
    );
  }
}

