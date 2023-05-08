import 'package:flutter/material.dart';
import 'package:fyp_management/pages/shared/main_drawer.dart';
import 'package:provider/provider.dart';
import '../../notifier/user_notifier.dart';

class TempPage extends StatefulWidget {
  const TempPage({super.key});

  @override
  State<TempPage> createState() => _TempPage();
}

class _TempPage extends State<TempPage> {
  final bool _notiIcon = true;
  late String uid;

  @override
  void initState() {
    UserNotifier noti = Provider.of<UserNotifier>(context, listen: false);
    uid = noti.userUID!;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('News'),
          actions: <Widget>[
            IconButton(
              icon: _notiIcon
                  ? const Icon(Icons.notifications_off)
                  : const Icon(Icons.notifications_active),
              onPressed: () {},
            )
          ],
        ),
        drawer: MainDrawer(),
        body: Container(
          color: Colors.white,
          child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  SizedBox(
                      height: 40,
                      width: 40,
                      child: Image(
                        image: AssetImage('assets/images/noti.png'),
                      )),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'No news or announcements',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ]),
          ),
        ));
  }
}
