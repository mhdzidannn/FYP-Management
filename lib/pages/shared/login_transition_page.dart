import 'dart:async';

import 'package:flutter/material.dart';

class LoginTransitionPage extends StatefulWidget {
  const LoginTransitionPage({super.key});

  @override
  State<LoginTransitionPage> createState() => _LoginTransitionPageState();
}

class _LoginTransitionPageState extends State<LoginTransitionPage> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  startTimer() async {
    var duration = const Duration(seconds: 1);
    return Timer(duration, () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
              gradient: RadialGradient(colors: [
            Colors.white,
            Colors.blue,
          ], radius: 3)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 280,
                width: 280,
                child:
                    Image.asset('assets/images/initial.png', fit: BoxFit.cover),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: SizedBox(
                  width: 300,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.blue,
                    valueColor: AlwaysStoppedAnimation(Colors.cyanAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
