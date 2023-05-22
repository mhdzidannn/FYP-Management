import 'package:flutter/material.dart';
import 'package:fyp_management/pages/lecturer/lecturer_fyp_title_list.dart';
import 'package:fyp_management/pages/lecturer/view_proposal_page.dart';
import 'package:fyp_management/pages/student/student_fyp_title_list.dart';
import 'package:fyp_management/pages/shared/temp_page.dart';
import 'package:fyp_management/pages/shared/main_drawer.dart';
import 'package:fyp_management/pages/student/student_project_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../../notifier/user_notifier.dart';
import '../../services/auth_service.dart';

const List<GButton> studentNavBar = [
  GButton(
    icon: Icons.rss_feed,
    text: 'FYP Titles',
  ),
  GButton(
    icon: LineIcons.powerpointFile,
    text: 'Project detail',
  ),
];

const List<GButton> lecturerNavBar = [
  GButton(
    icon: Icons.rss_feed,
    text: 'FYP Titles',
  ),
  GButton(
    icon: LineIcons.powerpointFile,
    text: 'Students Proposal',
  ),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  late int _selectedIndex;
  final PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    UserNotifier userNotifier =
        Provider.of<UserNotifier>(context, listen: false);

    if (userNotifier.lecturerMode!) {
      AuthService().getLecturerProfileLocal(userNotifier.userUID!).then((data) {
        userNotifier.currentLecturer = data;
      });
    } else {
      AuthService().getStudentProfileLocal(userNotifier.userUID!).then((data) {
        userNotifier.currentStudent = data;
      });
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserNotifier>(
      builder: (context, notifier, widget) {
        return Scaffold(
          key: scaffoldKey,
          drawer: MainDrawer(),
          body: PageView(
            onPageChanged: (index) {
              _selectedIndex = index;
            },
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            children: <Widget>[
              if (notifier.lecturerMode!) ...{
                const LectFYPTitleListPage(),
                const ViewProposalPage(),
              } else ...{
                StudentFypTitleListPage(key: UniqueKey()),
                StudentProjectPage(key: UniqueKey()),
              }
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(colors: [Colors.lightBlue, Colors.blue]),
              boxShadow: [
                BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 6),
                child: GNav(
                  gap: 8,
                  activeColor: Colors.white,
                  iconSize: 24,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  duration: const Duration(milliseconds: 800),
                  tabBackgroundColor: Colors.blue,
                  tabs: notifier.lecturerMode! ? lecturerNavBar : studentNavBar,
                  selectedIndex: _selectedIndex,
                  onTabChange: (index) {
                    setState(
                      () {
                        _selectedIndex = index;
                        pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.ease,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
