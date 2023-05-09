import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            SizedBox(
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
