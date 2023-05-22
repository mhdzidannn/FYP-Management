import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectLogs {
  late String projectUID;
  late String uid;
  String? docID;
  late String summary;
  late Timestamp dateCreated;
  Timestamp? dateUpdated;
  List<dynamic>? files = [];
  List<File>? filesToUpload = [];

  ProjectLogs({
    required this.projectUID,
    required this.uid,
    this.docID,
    required this.summary,
    required this.dateCreated,
    this.dateUpdated,
    this.files,
    this.filesToUpload,
  });

  set setFileURL(List data) {
    files = data;
  }

  Map<String, dynamic> toMap() {
    return {
      'projectUID': projectUID,
      'uid': uid,
      'summary': summary,
      "dateCreated": dateCreated,
      "dateUpdated": dateUpdated,
      'files': files,
    };
  }

  ProjectLogs.fromMap(Map<String, dynamic>? data, String documentID) {
    projectUID = data?['projectUID'];
    uid = data?['uid'];
    summary = data?['summary'];
    dateCreated = data?["dateCreated"];
    dateUpdated = data?["dateUpdated"];
    files = data?["files"];
    docID = documentID;
  }
}
