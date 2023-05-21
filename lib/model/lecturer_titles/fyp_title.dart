import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class FYPTitle {
  late String uid;
  String? docID;
  late String title;
  late String content;
  late Timestamp dateCreated;
  Timestamp? dateUpdated;
  String? link;
  List<dynamic>? files = [];
  List<File>? filesToUpload = [];
  late String nameOfLecturer;

  FYPTitle(
      {required this.uid,
      this.docID,
      required this.title,
      required this.content,
      required this.dateCreated,
      this.dateUpdated,
      this.link,
      this.files,
      this.filesToUpload,
      required this.nameOfLecturer});

  set setFileURL(List data) {
    files = data;
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'title': title,
      'content': content,
      "dateCreated": dateCreated,
      "dateUpdated": dateUpdated,
      'link': link,
      'files': files,
      'nameOfLecturer': nameOfLecturer,
    };
  }

  FYPTitle.fromMap(Map<String, dynamic>? data, String documentID) {
    uid = data?['uid'];
    title = data?['title'];
    content = data?['content'];
    dateCreated = data?["dateCreated"];
    dateUpdated = data?["dateUpdated"];
    link = data?['link'];
    files = data?["files"];
    docID = documentID;
    nameOfLecturer = data?["nameOfLecturer"];
  }
}
