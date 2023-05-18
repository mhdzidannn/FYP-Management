class LecturerDetails {
  late String email;
  late String username;
  late String phone;
  List? students;
  List? titleSubmitted;

  LecturerDetails({
    required this.email,
    required this.username,
    required this.phone,
    this.students,
    this.titleSubmitted,
  });

  LecturerDetails.fromMap(Map<String, dynamic>? data) {
    email = data?['email'];
    username = data?['username'];
    phone = data?['phone'];
    students = data?['students'];
    titleSubmitted = data?['titleSubmitted'];
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
