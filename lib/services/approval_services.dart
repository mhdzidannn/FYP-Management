import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_management/model/auth/lecturer_details.dart';
import 'package:fyp_management/model/student/student_proposal.dart';

class ApprovalServices {
  final CollectionReference _proposalCollection =
      FirebaseFirestore.instance.collection('StudentProposals');

  final CollectionReference _allTitlesCollection =
      FirebaseFirestore.instance.collection('AllTitles');

  final _lectDocRef = FirebaseFirestore.instance
      .collection("UserData")
      .doc("Lecturer")
      .collection("LecturerProfile");
  final _studentDocRef = FirebaseFirestore.instance
      .collection("UserData")
      .doc("Student")
      .collection("UserProfile");

  Stream<List<StudentProject>> getStudentProposal(String uid) {
    return _proposalCollection
        .where('supervisorDetails', isEqualTo: uid)
        .orderBy('dateCreated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((data) => StudentProject.fromMap(
                  data.data() as Map<String, dynamic>?,
                  data.id,
                ))
            .toList());
  }

  Future<LecturerDetails> getLecturerProfileLocal(String uid) async {
    return await FirebaseFirestore.instance
        .collection("UserData")
        .doc("Lecturer")
        .collection("LecturerProfile")
        .doc(uid)
        .get()
        .then((snapshot) =>
            LecturerDetails.fromMap(snapshot.data(), snapshot.id));
  }

  Future<List<LecturerDetails>> getListOfLecturers(String uid) async {
    List<LecturerDetails> lectDetails = [];
    await FirebaseFirestore.instance
        .collection("UserData")
        .doc("Lecturer")
        .collection("LecturerProfile")
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((element) {
        if (element.id != uid) {
          lectDetails.add(LecturerDetails.fromMap(element.data(), element.id));
        }
      });
    });
    return lectDetails;
  }

  Future<void> assignLecturerToStudent(
    String uidOfProposal,
    String uidOfLecturer,
  ) async {
    _proposalCollection.doc(uidOfProposal).update({
      'lecturersDetails': uidOfLecturer,
    });
    _lectDocRef.doc(uidOfLecturer).update({
      'students': FieldValue.arrayUnion([uidOfProposal]),
    });
  }
}
