import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:fyp_management/model/student/student_proposal.dart';
import 'package:fyp_management/notifier/user_notifier.dart';

class StudentService {
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

  Future<bool> submitProposal(StudentProject model, UserNotifier user) async {
    try {
      return Future.wait(
              [uploadFYPFiles(model.filesToUpload, user.userUID!, model.title)])
          .then((value) async {
        model.setFileURL = value[0];
        _proposalCollection.add(model.toMap()).then((doc) {
          _studentDocRef.doc(user.userUID).update({
            'student_proposal': FieldValue.arrayUnion([doc.id])
          });
          _allTitlesCollection.doc(model.uid).update({
            'student_proposal': FieldValue.arrayUnion([doc.id])
          });
          print("[StudentService] Succesfully upload StudentService doc");
          return true;
        });

        return false;
      });
    } catch (e) {
      print("[StudentService] Error in adding title : ${e.toString()}");
      return false;
    }
  }

  Future<List<String>> uploadFYPFiles(
    List<File>? files,
    String userUID,
    String title,
  ) async {
    List<String> storageURL = [];
    int index = 0;

    if (files == null) {
      return [""];
    }

    for (var file in files) {
      Uint8List fileBytes = await file.readAsBytes();

      var snapshot = await FirebaseStorage.instance
          .ref()
          .child('proposals/$userUID/$title $index')
          .putData(fileBytes);

      index++;
      if (snapshot.state == TaskState.success) {
        String downloadUrl = await snapshot.ref.getDownloadURL();
        storageURL.add(downloadUrl);
        print('[FirebaseStorage] Success Upload');
      } else {
        print(
            '[FirebaseStorage] Error during upload : ${snapshot.state.toString()}');
        throw ('[FirebaseStorage] Error during upload');
      }
    }

    print("UDAH ABIS HANTAR");
    return storageURL;
  }

  Stream<List<StudentProject>> getStudentSelectedProject(String uid) {
    return _proposalCollection
        .where('uid', isEqualTo: uid)
        .where('supervisorDetails', isNull: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((data) => StudentProject.fromMap(
                  data.data() as Map<String, dynamic>?,
                  data.id,
                ))
            .toList());
  }
}
