import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fyp_management/notifier/user_notifier.dart';
import 'package:fyp_management/pages/shared/home_page.dart';
import 'package:provider/provider.dart';

class ClassTransitionPage extends StatefulWidget {
  const ClassTransitionPage({super.key});

  @override
  State<ClassTransitionPage> createState() => _ClassTransitionPageState();
}

class _ClassTransitionPageState extends State<ClassTransitionPage> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  startTimer() async {
    var duration = const Duration(seconds: 2);
    return Timer(duration, () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    UserNotifier notifier = Provider.of<UserNotifier>(context, listen: false);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                notifier.lecturerMode!
                    ? 'Signing In to Lecturer Account'
                    : 'Signing in to Student Account',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(
                strokeWidth: 8,
                backgroundColor: Colors.blue,
                valueColor: AlwaysStoppedAnimation(Colors.cyanAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
