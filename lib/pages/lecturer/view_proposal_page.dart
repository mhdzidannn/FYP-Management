import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fyp_management/model/auth/lecturer_details.dart';
import 'package:fyp_management/model/auth/student_details.dart';
import 'package:fyp_management/model/student/student_proposal.dart';
import 'package:fyp_management/pages/shared/main_drawer.dart';
import 'package:fyp_management/pages/shared/pdf_viewer.dart';
import 'package:fyp_management/services/approval_services.dart';
import 'package:fyp_management/services/auth_service.dart';
import 'package:fyp_management/services/create_file_from_url.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../notifier/user_notifier.dart';
import 'package:path_provider/path_provider.dart';

class ViewProposalPage extends StatefulWidget {
  const ViewProposalPage({super.key});

  @override
  State<ViewProposalPage> createState() => _ViewProposalPage();
}

class _ViewProposalPage extends State<ViewProposalPage> {
  late String _uid;
  late bool _assignLectMode;
  late Stream<List<StudentProject>> _stream;
  late List<LecturerDetails> _listOfLecturers;

  @override
  void initState() {
    UserNotifier noti = Provider.of<UserNotifier>(context, listen: false);
    _uid = noti.userUID!;
    _assignLectMode = false;
    callApi();
    super.initState();
  }

  void callApi() async {
    _stream = ApprovalServices().getStudentProposal(_uid);
    _listOfLecturers = await ApprovalServices().getListOfLecturers(_uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Review Students Proposal'),
        actions: <Widget>[
          IconButton(
            icon: _assignLectMode
                ? const Icon(Icons.cancel)
                : const Icon(Icons.assignment_add),
            onPressed: () => setState(() => _assignLectMode = !_assignLectMode),
          )
        ],
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
        },
      ),
    );
  }

  assignLectDialog(StudentProject data) {
    AlertDialog alert = AlertDialog(
      title: const Text(
        "Select lecturer to mark this proposal \n\nAssigning lecturer to the proposals indicates that the proposal is approved",
        style: TextStyle(fontSize: 15),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          primary: true,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                /// just create another dialog
                confirmationDialog(
                  _listOfLecturers[index].username,
                  data.docID,
                  _listOfLecturers[index].uid,
                );
              },
              title: Text(_listOfLecturers[index].username),
              subtitle: Text("Email: ${_listOfLecturers[index].email}"),
            );
          },
          itemCount: _listOfLecturers.length,
        ),
      ),
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  confirmationDialog(String username, uidOfProposal, uidOfLecturer) {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget launchButton =
        Consumer<UserNotifier>(builder: (context, notifier, widget) {
      return TextButton(
        child: const Text("Confirm"),
        onPressed: () {
          ApprovalServices()
              .assignLecturerToStudent(uidOfProposal, uidOfLecturer);
          Navigator.of(context).pop();
          Navigator.pop(context, true);
        },
      );
    });
    AlertDialog alert = AlertDialog(
      title: Text(
        "Confirm to select $username?",
        style: const TextStyle(fontSize: 15),
      ),
      actions: [
        cancelButton,
        launchButton,
      ],
    );
    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _card(
    BuildContext context,
    StudentProject data,
    int index,
    int currIndex,
    Key key,
  ) {
    List<File> listOfFile = [];

    if (data.files != null && data.files!.isNotEmpty) {
      data.files!.forEach(
        (element) async {
          var url = element as String;
          if (url.isEmpty) {
            return;
          }
          var file = await FileServices().createFileOfPdfUrl(url);
          listOfFile.add(file);
        },
      );
    }

    return FutureBuilder<StudentDetails>(
      future: AuthService().getStudentProfileLocal(data.uid),
      initialData: StudentDetails(email: "", username: "", phone: ""),
      builder: (context, studentData) {
        return Card(
          key: key,
          elevation: 12,
          margin: index + 1 == currIndex
              ? const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 80)
              : const EdgeInsets.all(15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
                    if (data.files != null &&
                        data.files!.isNotEmpty &&
                        data.files![0] != "") ...{
                      for (int i = 0; i < data.files!.length; i++) ...{
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PDFScreen(path: listOfFile[i].path),
                              ),
                            );
                          },
                          child: Text(
                            "View File ${i + 1}",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.blueAccent,
                            ),
                          ),
                        )
                      }
                    }
                  ],
                ),
              ),
              if (_assignLectMode) ...{
                Positioned(
                  top: 10,
                  right: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: IconButton(
                      onPressed: () {
                        assignLectDialog(data);
                      },
                      icon: const Icon(Icons.assignment_add),
                      color: Colors.blue,
                    ),
                  ),
                )
              }
            ],
          ),
        );
      },
    );
  }
}
