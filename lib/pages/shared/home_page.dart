import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../../notifier/user_notifier.dart';
import '../../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<GButton> userNavBar = [
    const GButton(
      icon: Icons.rss_feed,
      text: 'News',
    ),
    const GButton(
      icon: Icons.fastfood,
      text: 'Food Diary',
    ),
    const GButton(
      icon: Icons.local_hospital,
      text: 'Clinic',
    ),
    const GButton(icon: LineIcons.calendar, text: 'Appointments'),
    const GButton(icon: LineIcons.clock, text: 'Prescriptions')
  ];

  List<GButton> dealerNavBar = [
    const GButton(
      icon: Icons.rss_feed,
      text: 'News',
    ),
    const GButton(
      icon: Icons.local_hospital,
      text: 'Clinic',
    ),
    const GButton(
      icon: Icons.fastfood,
      text: 'Food',
    ),
    const GButton(
      icon: Icons.person_outline,
      text: 'Admin Management',
    ),
  ];

  @override
  void initState() {
    super.initState();

    UserNotifier userNotifier =
        Provider.of<UserNotifier>(context, listen: false);

    if (userNotifier.dealerMode) {
      AuthService().getDealerProfileLocal(userNotifier.userUID).then((data) {
        userNotifier.currentDealer = data;
      });
    } else {
      AuthService().getUserProfileLocal(userNotifier.userUID).then((data) {
        userNotifier.currentUser = data;
      });
    }

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        final notification = message['notification'];

        setState(() {
          messages.add(Message(
              title: notification['title'], body: notification['body']));
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");

        final notification = message['data'];
        setState(() {
          messages.add(Message(
            title: '${notification['title']}',
            body: '${notification['body']}',
          ));
        });
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();

  final PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserNotifier>(builder: (context, notifier, widget) {
      return Scaffold(
        key: scaffoldKey,
        drawer: MainDrawer(),
        body: PageView(
            onPageChanged: (index) {
              _selectedIndex = index;
            },
            physics: NeverScrollableScrollPhysics(),
            controller: pageController,
            children: <Widget>[
              if (notifier.dealerMode) ...{
                NewsListPage(),
                ClinicListPage(),
                FoodAdminPage(),
                AdminListPage(),
              } else ...{
                ViewNewsPage(),
                FoodDiary1Page(),
                ClinicListPage(),
                Appointment1Page(),
                ListOfPrescriptionPage(),
              }
            ]),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.lightBlue[100], Colors.blue[300]]),
              boxShadow: [
                BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
              ]),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 6),
              child: GNav(
                gap: 8,
                activeColor: Colors.white,
                iconSize: 24,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                duration: Duration(milliseconds: 800),
                tabBackgroundColor: Colors.blue[700],
                tabs: notifier.dealerMode ? dealerNavBar : userNavBar,
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                    pageController.animateToPage(index,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.ease);
                    // pageController.jumpToPage(index);
                  });
                },
              ),
            ),
          ),
        ),
      );
    });
  }
}

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
          title: Text('FAQ'),
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
