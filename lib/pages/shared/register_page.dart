import 'package:flutter/material.dart';
import 'package:fyp_management/model/lecturer_details.dart';
import 'package:fyp_management/model/student_details.dart';
import 'package:provider/provider.dart';

import '../../notifier/user_notifier.dart';
import '../../services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  final String email;
  final String password;
  final bool isLecturer;

  const SignUpPage({
    super.key,
    required this.email,
    required this.password,
    required this.isLecturer,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  late String email;
  late String password;
  late bool isLecturer;
  String _userName = '';
  String _phoneNumber = '';

  @override
  void initState() {
    email = widget.email;
    password = widget.password;
    isLecturer = widget.isLecturer;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Form(
            autovalidateMode: AutovalidateMode.always,
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  userNameField(),
                  phoneNumberField(),
                  buttonAcceptDeny(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget userNameField() {
    return Padding(
        padding: const EdgeInsets.only(top: 70, left: 50, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Username',
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
            TextFormField(
              decoration: const InputDecoration(hintText: 'eg. John Wick'),
              maxLines: 1,
              onSaved: (value) => _userName = value ?? "",
              validator: (value) =>
                  _userName.isEmpty ? 'Enter your username' : null,
              onChanged: (value) => setState(() => _userName = value),
            )
          ],
        ));
  }

  Widget phoneNumberField() {
    String pattern = r'^(\+?6?01)[0-46-9]-*[0-9]{7,8}$';
    RegExp regex = RegExp(pattern);

    return Padding(
        padding: const EdgeInsets.only(top: 40, left: 50, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Phone Number',
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'eg. 0123456789'),
              maxLines: 1,
              validator: (value) {
                if (!isLecturer) {
                  if (!regex.hasMatch(value ?? "")) {
                    return 'Enter a valid Malaysian phone number';
                  } else {
                    return null;
                  }
                } else {
                  if (value == null && value!.isEmpty) {
                    return 'Enter a valid Malaysian phone number';
                  } else {
                    return null;
                  }
                }
              },
              onChanged: (value) {
                setState(() => _phoneNumber = value);
              },
            )
          ],
        ));
  }

  Widget buttonAcceptDeny() {
    return Padding(
      padding: EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(
            width: 50,
          ),
          Consumer<UserNotifier>(
            builder: (context, notifier, widget) {
              return ElevatedButton(
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  registerAccount(notifier);
                },
              );
            },
          )
        ],
      ),
    );
  }

  void registerAccount(UserNotifier notifier) async {
    if (_formKey.currentState!.validate()) {
      if (isLecturer) {
        await _auth.signUpWithEmailAndPassword(
            notifier, isLecturer, email, password,
            lecturerData: LecturerDetails(
              username: _userName,
              email: email,
              phone: _phoneNumber,
            ));
      } else {
        await _auth.signUpWithEmailAndPassword(
            notifier, isLecturer, email, password,
            studentData: StudentDetails(
              email: email,
              username: _userName,
              phone: _phoneNumber,
            ));
      }
    }
  }
}
