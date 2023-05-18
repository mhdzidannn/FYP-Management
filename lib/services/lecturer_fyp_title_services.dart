import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:fyp_management/model/lecturer_titles/fyp_title.dart';
import 'package:fyp_management/notifier/user_notifier.dart';

class FYPTitleService {
  CollectionReference _fypTitlesCollection =
      FirebaseFirestore.instance.collection('FYPTitles');

  final _lectDocRef = FirebaseFirestore.instance
      .collection("UserData")
      .doc("Lecturer")
      .collection("LecturerProfile");
  final _studentDocRef = FirebaseFirestore.instance
      .collection("UserData")
      .doc("Student")
      .collection("UserProfile");

  Future<bool> submitTitle(FYPTitle model, UserNotifier user) async {
    try {
      return Future.wait(
              [uploadFYPFiles(model.filesToUpload, user.userUID!, model.title)])
          .then((value) async {
        if (user.lecturerMode!) {
          model.setFileURL = value[0];
          _fypTitlesCollection.add(model.toMap()).then((doc) {
            _lectDocRef.doc(user.userUID).update({
              'fyp_title': FieldValue.arrayUnion([doc.id])
            });
            print("[FYPTitleService] Succesfully upload FYPTitleService doc");
            return true;
          });
        } else {
          model.setFileURL = value[0];
          _fypTitlesCollection.add(model.toMap()).then((doc) {
            _studentDocRef.doc(user.userUID).update({
              'fyp_title': FieldValue.arrayUnion([doc.id])
            });
            print("[FYPTitleService] Succesfully upload FYPTitleService doc");
            return true;
          });
        }
        return false;
      });
    } catch (e) {
      print("[FYPTitleService] Error in adding title : ${e.toString()}");
      return false;
    }
  }

  Future<List<String>> uploadFYPFiles(
    List<File>? files,
    String userUID,
    String title,
  ) async {
    List<String> storageURL = [];

    if (files == null) {
      return [""];
    }

    for (var file in files) {
      Uint8List fileBytes = await file.readAsBytes();

      var snapshot = await FirebaseStorage.instance
          .ref()
          .child('fypTitles/$userUID/$title')
          .putData(fileBytes);

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

  Stream<List<FYPTitle>> getTitle(String uid) {
    return _fypTitlesCollection
        .where('uid', isEqualTo: uid)
        .orderBy('dateCreated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((data) => FYPTitle.fromMap(
                  data.data() as Map<String, dynamic>?,
                  data.id,
                ))
            .toList());
  }

  Future<void> deleteFypTitle(FYPTitle dataModel, UserNotifier user) async {
    WriteBatch batchWrite = FirebaseFirestore.instance.batch();

    try {
      batchWrite.delete(_fypTitlesCollection.doc(dataModel.docID));

      await batchWrite.commit().then((_) async {
        _fypTitlesCollection.doc(dataModel.uid).delete();
        if (user.lecturerMode!) {
          _lectDocRef.doc(user.userUID).update({
            'fyp_title': FieldValue.arrayRemove([dataModel.uid])
          });
        } else {
          _studentDocRef.doc(user.userUID).update({
            'fyp_title': FieldValue.arrayRemove([dataModel.uid])
          });
        }
      });
    } catch (e) {
      print(
          "[FYP Title] Error during deleting your FYP Title : ${e.toString()}");
    }
  }
}
