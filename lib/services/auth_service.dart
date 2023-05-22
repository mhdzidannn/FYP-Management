import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_management/model/auth/lecturer_details.dart';
import 'package:fyp_management/model/auth/student_details.dart';
import 'package:fyp_management/model/auth/user.dart';
import 'package:fyp_management/notifier/user_notifier.dart';

import 'auth_exception_handler.dart';

enum AuthResultStatus {
  successful,
  emailAlreadyExists,
  wrongPassword,
  invalidEmail,
  userNotFound,
  userDisabled,
  operationNotAllowed,
  tooManyRequests,
  undefined,
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? userUID;

  Stream<LecturerDetails> getLecturerProfileStream(String uid) {
    return FirebaseFirestore.instance
        .collection("UserData")
        .doc("Lecturer")
        .collection("LecturerProfile")
        .doc(uid)
        .snapshots()
        .map((event) {
      return LecturerDetails.fromMap(event.data(), event.id);
    });
  }

  Stream<StudentDetails> getStudentProfileStream(String uid) {
    return FirebaseFirestore.instance
        .collection("UserData")
        .doc("Student")
        .collection("UserProfile")
        .doc(uid)
        .snapshots()
        .map((event) => StudentDetails.fromMap(event.data(), event.id));
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

  Future<StudentDetails> getStudentProfileLocal(String uid) async {
    return await FirebaseFirestore.instance
        .collection("UserData")
        .doc("Student")
        .collection("UserProfile")
        .doc(uid)
        .get()
        .then((snapshot) {
      return StudentDetails.fromMap(snapshot.data(), snapshot.id);
    });
  }

  //auth to change user stream
  Stream<UserBaseDetail?> get userStream {
    return _auth.authStateChanges().map((user) {
      if (user != null) {
        userUID = user.uid;
        return UserBaseDetail(uid: user.uid);
      } else {
        return null;
      }
    });
  }

  Future<DocumentSnapshot> getStudentGeneralInformation() async {
    return await FirebaseFirestore.instance
        .collection("UserData")
        .doc("Student")
        .get();
  }

  Future<DocumentSnapshot> getLecturerGeneralInformation() async {
    return await FirebaseFirestore.instance
        .collection("UserData")
        .doc("Lecturer")
        .get();
  }

  Future<bool> checkUserDetails(UserNotifier notifier) async {
    try {
      return await Future.wait(<Future<DocumentSnapshot>>[
        getStudentGeneralInformation(),
        getLecturerGeneralInformation()
      ]).then((futureCalls) {
        UserGeneralInfo studentInfo = UserGeneralInfo.fromMapUser(
            futureCalls[0].data() as Map<String, dynamic>);
        UserGeneralInfo lecturerInfo = UserGeneralInfo.fromMapDealer(
            futureCalls[1].data() as Map<String, dynamic>);

        if (lecturerInfo.listOfUID.contains(notifier.userUID)) {
          print("[Firebase] The current user is a admin");
          // notifier.currentLecturer =
          notifier.setLecturerMode = true;
          return true;
        }
        if (studentInfo.listOfUID.contains(notifier.userUID)) {
          print("[Firebase] The current user is a user");
          // notifier.currentStudent =
          notifier.setLecturerMode = false;
          return true;
        } else {
          print("SINI PULAK DOH");
          return _auth.signOut().then((value) => false);
        }
      });
    } catch (e) {
      print("[Firebase] Error in validating user mode : ${e.toString()}");
      return false;
    }
  }

  // method to sign in with email and password
  signIn(String email, String password) async {
    AuthResultStatus status;
    try {
      final authResult = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((result) async {
        print("[Firebase] Logging in process completed");
      });
      if (authResult != null) {
        status = AuthResultStatus.successful;
      } else {
        status = AuthResultStatus.undefined;
      }
    } catch (e) {
      print('Exception caught: $e');
      status = AuthExceptionHandler.handleException(e);
    }
    return status;
  }

  Future<bool> signUpWithEmailAndPassword(
    UserNotifier notifier,
    bool isLecturer,
    String email,
    String password, {
    StudentDetails? studentData,
    LecturerDetails? lecturerData,
  }) async {
    DocumentReference student =
        FirebaseFirestore.instance.collection("UserData").doc("Student");
    DocumentReference lecturer =
        FirebaseFirestore.instance.collection("UserData").doc("Lecturer");

    try {
      return await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((result) async {
        if (isLecturer) {
          return FirebaseFirestore.instance.runTransaction((transaction) async {
            await transaction.get(lecturer).then((snapshot) async {
              if (!snapshot.exists) {
                return;
              }
              UserGeneralInfo recent = UserGeneralInfo.fromMapDealer(
                  snapshot.data() as Map<String, dynamic>);
              recent.listOfUID.add(result.user?.uid);
              transaction.update(snapshot.reference,
                  {'UID': FieldValue.arrayUnion(recent.listOfUID)});
            });
          }).then((_) async {
            return await lecturer
                .collection("LecturerProfile")
                .doc(result.user?.uid)
                .set(lecturerData!.toMap())
                .then((_) {
              notifier.setLecturerMode = true;
              notifier.setUserUID = result.user?.uid ?? "";
              print("[Firebase] Successfull lecturer Registration");
              return true;
            });
          });
        } else {
          return FirebaseFirestore.instance.runTransaction((transaction) async {
            await transaction.get(student).then((snapshot) async {
              if (!snapshot.exists) {
                return;
              }
              UserGeneralInfo recent = UserGeneralInfo.fromMapUser(
                  snapshot.data() as Map<String, dynamic>);
              recent.listOfUID.add(result.user?.uid);
              transaction.update(snapshot.reference,
                  {'UID': FieldValue.arrayUnion(recent.listOfUID)});
            });
          }).then((_) async {
            return await student
                .collection("UserProfile")
                .doc(result.user?.uid)
                .set(studentData!.toMap())
                .then((_) {
              notifier.setLecturerMode = false;
              notifier.setUserUID = result.user?.uid ?? "";
              print("[Firebase] Successfull student Registration");
              return true;
            });
          });
        }
      });
    } catch (e) {
      print("[SIGNUP] Error During Sign Up : ${e.toString()}");
      return false;
    }
  }

  // method to signout
  signOut(UserNotifier notifier) async {
    try {
      await _auth.signOut().then((_) {
        notifier.setLecturerMode = null;
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
