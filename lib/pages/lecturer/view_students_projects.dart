import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fyp_management/model/auth/student_details.dart';
import 'package:fyp_management/model/student/student_proposal.dart';
import 'package:fyp_management/pages/lecturer/view_project_details_lect.dart';
import 'package:fyp_management/pages/shared/main_drawer.dart';
import 'package:fyp_management/services/auth_service.dart';
import 'package:fyp_management/services/lecturer_fyp_title_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../notifier/user_notifier.dart';

class ViewStudentsProjectPage extends StatefulWidget {
  const ViewStudentsProjectPage({super.key});

  @override
  State<ViewStudentsProjectPage> createState() =>
      _ViewStudentsProjectPageState();
}

class _ViewStudentsProjectPageState extends State<ViewStudentsProjectPage> {
  late String _uid;
  late Stream<List<StudentProject>> _stream;

  @override
  void initState() {
    UserNotifier noti = Provider.of<UserNotifier>(context, listen: false);
    _uid = noti.userUID!;
    callApi();
    super.initState();
  }

  void callApi() async {
    _stream = FYPTitleService().getApprovedTitle(_uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('View Students Project'),
      ),
      drawer: MainDrawer(),
      body: StreamBuilder<List<StudentProject>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Container(
              color: Colors.blueGrey[100],
              child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return _card(
                      context,
                      snapshot.data![index],
                      index,
                      snapshot.data!.length,
                      UniqueKey(),
                    );
                  }),
            );
          }
          return const NoDataView();
        },
      ),
    );
  }

  Widget _card(
    BuildContext context,
    StudentProject data,
    int index,
    int currIndex,
    Key key,
  ) {
    return FutureBuilder<StudentDetails>(
      future: AuthService().getStudentProfileLocal(data.uid),
      initialData: StudentDetails(email: "", username: "", phone: ""),
      builder: (context, studentData) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LectProjectDetailPage(data: data),
              ),
            );
          },
          child: Card(
            key: key,
            elevation: 12,
            margin: index + 1 == currIndex
                ? const EdgeInsets.only(
                    top: 15, left: 15, right: 15, bottom: 80)
                : const EdgeInsets.all(15),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          data.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Proposal by: ${studentData.data?.username}",
                        style: GoogleFonts.actor(),
                      ),
                      const SizedBox(height: 10),
                      Text("Contact number: ${studentData.data?.phone}"),
                      const SizedBox(height: 10),
                      Text(data.title),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NoDataView extends StatelessWidget {
  const NoDataView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              SizedBox(
                  height: 40,
                  width: 40,
                  child: Icon(
                    Icons.cancel_presentation_sharp,
                    color: Colors.red,
                    size: 40,
                  )),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'You havent received any proposals yet',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ]),
      ),
    );
  }
}
