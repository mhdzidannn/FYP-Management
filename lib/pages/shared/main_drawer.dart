import 'package:flutter/material.dart';
import 'package:fyp_management/notifier/user_notifier.dart';
import 'package:fyp_management/services/auth_service.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatelessWidget {
  final AuthService _auth = AuthService();

  MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    UserNotifier notifier = Provider.of<UserNotifier>(context, listen: false);

    return Drawer(
        child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        if (notifier.lecturerMode!) ...{
          UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient:
                    LinearGradient(colors: [Colors.blue, Colors.lightBlue]),
              ),
              currentAccountPicture: ClipOval(
                child: Material(
                  color: Colors.indigo,
                  child: InkWell(
                    splashColor: Colors.lightBlueAccent,
                    child: const SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(
                          Icons.account_circle,
                          size: 40,
                          color: Colors.white,
                        )),
                    onTap: () {},
                  ),
                ),
              ),
              accountName: Text(
                notifier.getLecturerDetails!.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(notifier.getLecturerDetails!.email))
        } else ...{
          UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient:
                    LinearGradient(colors: [Colors.blue, Colors.lightBlue]),
              ),
              currentAccountPicture: ClipOval(
                child: Material(
                  color: Colors.indigo,
                  child: InkWell(
                    splashColor: Colors.lightBlueAccent,
                    child: const SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(
                          Icons.account_circle,
                          size: 40,
                          color: Colors.white,
                        )),
                    onTap: () {},
                  ),
                ),
              ),
              accountName: Text(
                notifier.getStudentDetails!.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(notifier.getStudentDetails!.email))
        },
        ListTile(
          title: const Text('FAQ'),
          trailing: Icon(
            Icons.help_outline,
            color: Colors.blue[800],
          ),
        ),
        const Divider(
          thickness: 1,
        ),
        ListTile(
          title: const Text('Sign Out'),
          trailing: Icon(
            Icons.exit_to_app,
            color: Colors.blue[800],
          ),
          onTap: () {
            Navigator.pop(context);
            _auth.signOut(notifier);
          },
        ),
        const Divider(
          thickness: 1,
        ),
        const SizedBox(
          height: 20,
        ),
        Center(
          child: Text(
            'V 1.0.0',
            style:
                TextStyle(color: Colors.blue[600], fontWeight: FontWeight.bold),
          ),
        )
      ],
    ));
  }
}
