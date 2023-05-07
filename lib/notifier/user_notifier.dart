import 'package:flutter/widgets.dart';
import 'package:fyp_management/model/lecturer_details.dart';
import 'package:fyp_management/model/student_details.dart';

class UserNotifier with ChangeNotifier {
  StudentDetails? _studentDetails;
  LecturerDetails? _lecturerDetails;
  String? _userUID;
  bool? _isLecturer;

  StudentDetails? get getStudentDetails => _studentDetails;
  LecturerDetails? get getLecturerDetails => _lecturerDetails;
  String? get userUID => _userUID;
  bool? get lecturerMode => _isLecturer;

  set setLecturerMode(bool? mode) {
    _isLecturer = mode;
    if (_isLecturer == null) {
      print("[UserNotifier] User/Admin Mode Resetted");
      return;
    }
    if (_isLecturer!) {
      print("[UserNotifier] Currently on Lecturer Mode");
    } else {
      print("[UserNotifier] Currently on Student Mode");
    }
  }

  set setUserUID(String uid) {
    _userUID = uid;
    print("[UserNotifier] USER UID $uid");
  }

  set currentStudent(StudentDetails data) {
    _studentDetails = data;
    print("[UserNotifier] MODEL INITIALIZE");
  }

  set currentLecturer(LecturerDetails data) {
    _lecturerDetails = data;
    print("[UserNotifier] MODEL INITIALIZE");
  }

  set notifyCurrentStudent(StudentDetails data) {
    _studentDetails = data;
    print("[UserNotifier] MODEL UPDATED");
    notifyListeners();
  }

  set notifyCurrentLecturer(LecturerDetails data) {
    _lecturerDetails = data;
    print("[UserNotifier] MODEL UPDATED");
    notifyListeners();
  }
}
