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
import 'package:fyp_management/services/student_fyp_title_services.dart';
import 'package:provider/provider.dart';

class StudentProjectPage extends StatefulWidget {
  const StudentProjectPage({super.key});

  @override
  State<StudentProjectPage> createState() => _StudentProjectPageState();
}

class _StudentProjectPageState extends State<StudentProjectPage> {
  late Stream<List<StudentProject>> _stream;
  static LecturerDetails? _supervisorDetails;
  static LecturerDetails? _lecturerDetails;
  List<File> _proposalFiles = [];

  @override
  void initState() {
    super.initState();
    UserNotifier notifier = Provider.of<UserNotifier>(context, listen: false);
    _stream = StudentService().getStudentSelectedProject(notifier.userUID!);
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
          drawer: MainDrawer(),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _nameOfFields("Meetings and submission logs"),
                                ElevatedButton(
                                  onPressed: () {
                                    submitLogDialog(data);
                                  },
                                  child: const Text("Add"),
                                )
                              ],
                            ),
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

  submitLogDialog(StudentProject projectData) {
    final _formKey = GlobalKey<FormState>();
    final _summaryController = TextEditingController();
    late bool _summaryDone = false;

    List<File>? _filesToUpload;
    int _numberOfFilesSelected = 0;

    Future<FilePickerResult?> pickFiles() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'docx'],
      );
      return result;
    }

    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context, true);
      },
    );
    Widget launchButton =
        Consumer<UserNotifier>(builder: (context, notifier, widget) {
      return TextButton(
        child: const Text("Submit"),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            ProjectLogs model = ProjectLogs(
              projectUID: projectData.docID!,
              uid: notifier.userUID!,
              filesToUpload: _filesToUpload,
              dateCreated: Timestamp.now(),
              summary: _summaryController.text,
            );
            _onSubmitPressed(model, notifier);
          }
        },
      );
    });
    AlertDialog alert = AlertDialog(
      title: const Text("Log Submission"),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SizedBox(
            width: double.maxFinite,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                        hintText: 'eg. FYP Management System'),
                    controller: _summaryController,
                    maxLines: 1,
                    textInputAction: TextInputAction.done,
                    maxLength: 100,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Title must not be empty'
                        : null,
                    onChanged: (val) {
                      setState(() {
                        if (val.isNotEmpty) {
                          if (!_summaryDone) {
                            _summaryDone = !_summaryDone;
                          }
                        } else {
                          if (_summaryDone) {
                            _summaryDone = false;
                          }
                        }
                      });
                    },
                  ),
                  _numberOfFilesSelected == 0
                      ? GestureDetector(
                          onTap: () async {
                            var result = await pickFiles();
                            if (result != null) {
                              setState(() {
                                _filesToUpload = result.paths
                                    .map((path) => File(path!))
                                    .toList();
                                _numberOfFilesSelected = result.count;
                              });
                            }
                          },
                          child: const Text('Click here to upload file'),
                        )
                      : GestureDetector(
                          onTap: () async {
                            var result = await pickFiles();
                            if (result != null) {
                              setState(
                                () {
                                  _filesToUpload = result.paths
                                      .map((path) => File(path!))
                                      .toList();
                                  _numberOfFilesSelected = result.count;
                                },
                              );
                            }
                          },
                          child: const Text('Reupload file'),
                        ),
                ],
              ),
            ),
          );
        },
      ),
      actions: [
        cancelButton,
        launchButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<bool?> _onSubmitPressed(ProjectLogs model, UserNotifier userData) {
    return showDialog(
      context: context,
      builder: (context) => FutureBuilder<bool>(
        future: StudentService().addLog(userData, model),
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
                                          'You have succesfully updated the logs!'),
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
                'Your proposal is not approved yet',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
