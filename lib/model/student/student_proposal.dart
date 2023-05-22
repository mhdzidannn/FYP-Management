import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProject {
  late String uid;
  String? docID;
  late String title;
  late Timestamp dateCreated;
  Timestamp? dateUpdated;
  String? link;
  List<dynamic>? files = [];
  List<File>? filesToUpload = [];
  late String supervisorDetails;

  /// if this is not null, means supervisor approved and has assigned lecturer to grade.
  String? lecturersDetails;

  double? supervisorMarks;
  String? supervisorGrades;
  double? lecturersMarks;
  String? lecturersGrades;

  StudentProject({
    required this.uid,
    this.docID,
    required this.title,
    required this.dateCreated,
    this.dateUpdated,
    this.link,
    this.files,
    this.filesToUpload,
    required this.supervisorDetails,
    this.lecturersDetails,
    this.supervisorGrades,
  });

  set setFileURL(List data) {
    files = data;
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'title': title,
      "dateCreated": dateCreated,
      "dateUpdated": dateUpdated,
      'link': link,
      'files': files,
      'supervisorDetails': supervisorDetails,
      'lecturersDetails': lecturersDetails,
      'supervisorGrades': supervisorGrades,
    };
  }

  StudentProject.fromMap(Map<String, dynamic>? data, String documentID) {
    uid = data?['uid'];
    title = data?['title'];
    dateCreated = data?["dateCreated"];
    dateUpdated = data?["dateUpdated"];
    link = data?['link'];
    files = data?["files"];
    docID = documentID;
    supervisorDetails = data?["supervisorDetails"];
    lecturersDetails = data?["lecturersDetails"];
    supervisorGrades = data?["supervisorGrades"];
  }
}
