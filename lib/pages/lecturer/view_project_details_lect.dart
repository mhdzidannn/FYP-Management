import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fyp_management/model/auth/lecturer_details.dart';
import 'package:fyp_management/model/student/project_logs.dart';
import 'package:fyp_management/model/student/student_proposal.dart';
import 'package:fyp_management/notifier/lecturer_title_notifier.dart';
import 'package:fyp_management/notifier/user_notifier.dart';
import 'package:fyp_management/pages/shared/main_drawer.dart';
import 'package:fyp_management/pages/student/project_detail_page.dart';
import 'package:fyp_management/pages/student/project_log.dart';
import 'package:fyp_management/services/auth_service.dart';
import 'package:fyp_management/services/create_file_from_url.dart';
import 'package:fyp_management/services/lecturer_fyp_title_services.dart';
import 'package:fyp_management/services/student_fyp_title_services.dart';
import 'package:provider/provider.dart';

class LectProjectDetailPage extends StatefulWidget {
  final StudentProject data;

  const LectProjectDetailPage({
    required this.data,
    super.key,
  });

  @override
  State<LectProjectDetailPage> createState() => _LectProjectDetailPageState();
}

class _LectProjectDetailPageState extends State<LectProjectDetailPage> {
  late Stream<List<StudentProject>> _stream;
  static LecturerDetails? _supervisorDetails;
  static LecturerDetails? _lecturerDetails;
  List<File> _proposalFiles = [];

  final _formKey = GlobalKey<FormState>();
  final _gradeController = TextEditingController();
  bool _gradeDone = false;

  @override
  void initState() {
    super.initState();
    _stream = StudentService().getStudentSelectedProject(widget.data.uid);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getSupervisorDetail(String uidLecturer) async {
    _supervisorDetails =
        await AuthService().getLecturerProfileLocal(uidLecturer);
  }

  Future<void> getLecturerDetail(String uidLecturer) async {
    _lecturerDetails = await AuthService().getLecturerProfileLocal(uidLecturer);
  }

  Future<bool> listOfFutures(StudentProject projectData) async {
    return Future.wait([
      getSupervisorDetail(projectData.supervisorDetails),
      getLecturerDetail(projectData.lecturersDetails ?? ""),
    ]).then((value) => true).onError((error, stackTrace) => false);
  }

  loadFiles(StudentProject projectData) {
    if (projectData.files != null && projectData.files!.isNotEmpty) {
      projectData.files!.forEach(
        (element) async {
          var url = element as String;
          if (url.isEmpty) {
            return;
          }
          var file = await FileServices().createFileOfPdfUrl(url);
          _proposalFiles.add(file);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FYPTitleNotifier>(
      builder: (context, value, widget) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Project Management',
              style: TextStyle(fontSize: 20),
            ),
          ),
          body: StreamBuilder<List<StudentProject>>(
            stream: _stream,
            builder: (context, projectData) {
              if (projectData.hasData && projectData.data!.isNotEmpty) {
                StudentProject data = projectData.data!.first;
                loadFiles(data);

                return FutureBuilder<bool>(
                  future: listOfFutures(projectData.data!.first),
                  builder: (context, snapshot) {
                    if (snapshot.data == false) {
                      return const NotApprovedPage();
                    }
                    return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: SingleChildScrollView(
                        primary: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ExistingProjectDetailPage(
                              data: data,
                              lecturerDetails: _lecturerDetails ??
                                  LecturerDetails.initialData(),
                              proposalFiles: _proposalFiles,
                              supervisorDetails: _supervisorDetails ??
                                  LecturerDetails.initialData(),
                            ),
                            const Divider(thickness: 1),
                            _nameOfFields("Meetings and submission logs"),
                            FutureBuilder<List<ProjectLogs>>(
                              future: StudentService().getLogs(data.docID!),
                              builder: (ctx, logsData) {
                                if (logsData.hasData && logsData.data != null) {
                                  return ProjectLogPage(data: logsData.data!);
                                }
                                return const Center(child: Text("No logs yet"));
                              },
                            ),
                            const Divider(thickness: 1),
                            _nameOfFields(
                                "Grade given: ${data.supervisorGrades ?? "Not given yet"}"),
                            const Divider(thickness: 1),
                            Form(
                              key: _formKey,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _nameOfFields("Grade"),
                                  const SizedBox(width: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: Consumer<UserNotifier>(
                                        builder: (context, notifier, widget) {
                                      return ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            StudentProject model =
                                                StudentProject(
                                              docID: data.docID,
                                              uid: data.uid,
                                              supervisorGrades:
                                                  _gradeController.text,
                                              dateCreated: Timestamp.now(),
                                              title: '',
                                              supervisorDetails: '',
                                            );
                                            _onSubmitPressed(model, notifier);
                                          }
                                        },
                                        child: const Text("Submit"),
                                      );
                                    }),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                    hintText: 'eg. 100 / A / 86 / A-'),
                                controller: _gradeController,
                                maxLines: 1,
                                textInputAction: TextInputAction.done,
                                maxLength: 3,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Grade must not be empty'
                                        : null,
                                onChanged: (val) {
                                  setState(() {
                                    if (val.isNotEmpty) {
                                      if (!_gradeDone) {
                                        _gradeDone = !_gradeDone;
                                      }
                                    } else {
                                      if (_gradeDone) {
                                        _gradeDone = false;
                                      }
                                    }
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return const NotApprovedPage();
            },
          ),
        );
      },
    );
  }

  Widget _nameOfFields(String fieldName, {bool isMandatory = false}) {
    return Padding(
        padding: const EdgeInsets.only(top: 10, left: 10),
        child: RichText(
          text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 18),
              children: <TextSpan>[
                TextSpan(
                    text: fieldName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (isMandatory) ...{
                  const TextSpan(
                      text: ' *', style: TextStyle(color: Colors.red))
                },
              ]),
        ));
  }

  Future<bool?> _onSubmitPressed(StudentProject model, UserNotifier userData) {
    return showDialog(
      context: context,
      builder: (context) => FutureBuilder<bool>(
        future: FYPTitleService().submitGrade(userData, model),
        builder: (context, snapshot) {
          return AlertDialog(
            content: SizedBox(
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (snapshot.connectionState == ConnectionState.done) ...{
                    Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        child: RichText(
                          text: TextSpan(
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                              children: <TextSpan>[
                                if (snapshot.hasData) ...{
                                  const TextSpan(
                                      text:
                                          'You have succesfully give a grade!'),
                                } else ...{
                                  const TextSpan(
                                      text:
                                          'An error has occured during the upload-Error:conn.Error'),
                                }
                              ]),
                        )),
                    GestureDetector(
                      onTap: snapshot.hasData
                          ? () {
                              Navigator.of(context).pop(true);
                              Navigator.pop(context);
                            }
                          : () {
                              Navigator.of(context).pop(false);
                            },
                      child: Text(
                        snapshot.hasData ? 'OK' : 'Try Again',
                        style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    )
                  } else ...{
                    const Center(
                      child: SizedBox(
                        height: 75,
                        width: 75,
                        child: CircularProgressIndicator(),
                      ),
                    )
                  }
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class NotApprovedPage extends StatelessWidget {
  const NotApprovedPage({super.key});

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
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'You proposal is not approved yet',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
