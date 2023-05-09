class StudentDetails {
  late String email;
  late String username;
  late String phone;
  String? lecturerUID;
  List? appliedTitle;

  StudentDetails({
    required this.email,
    required this.username,
    required this.phone,
    this.lecturerUID,
    this.appliedTitle,
  });

  StudentDetails.fromMap(Map<String, dynamic>? data) {
    email = data?['email'];
    username = data?['username'];
    phone = data?['phone'];
    lecturerUID = data?['lecturerUID'];
    appliedTitle = data?['appliedTitle'];
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'phone': phone,
      'lecturerUID': lecturerUID,
      'appliedTitle': appliedTitle,
    };
  }
}
