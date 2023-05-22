class StudentDetails {
  late String email;
  late String username;
  late String phone;
  String? lecturerUID;
  List? studentProposal;
  String? uid;

  StudentDetails({
    required this.email,
    required this.username,
    required this.phone,
    this.lecturerUID,
    this.studentProposal,
    this.uid,
  });

  StudentDetails.fromMap(Map<String, dynamic>? data, String documentID) {
    email = data?['email'];
    username = data?['username'];
    phone = data?['phone'];
    lecturerUID = data?['lecturerUID'];
    studentProposal = data?['student_proposal'];
    uid = documentID;
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'phone': phone,
      'lecturerUID': lecturerUID,
      'student_proposal': studentProposal,
    };
  }
}
