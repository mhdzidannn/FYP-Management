class LecturerDetails {
  late String email;
  late String username;
  late String phone;
  List? students;
  List? titleSubmitted;
  String? uid;

  LecturerDetails({
    required this.email,
    required this.username,
    required this.phone,
    this.students,
    this.titleSubmitted,
    this.uid,
  });

  LecturerDetails.fromMap(Map<String, dynamic>? data, String documentID) {
    email = data?['email'];
    username = data?['username'];
    phone = data?['phone'];
    students = data?['students'];
    titleSubmitted = data?['titleSubmitted'];
    uid = documentID;
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'phone': phone,
      'students': students,
      'titleSubmitted': titleSubmitted,
    };
  }
}
