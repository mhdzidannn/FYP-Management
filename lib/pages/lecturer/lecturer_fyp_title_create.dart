import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fyp_management/model/lecturer_titles/fyp_title.dart';
import 'package:fyp_management/notifier/lecturer_title_notifier.dart';
import 'package:fyp_management/notifier/user_notifier.dart';
import 'package:fyp_management/services/lecturer_fyp_title_services.dart';
import 'package:provider/provider.dart';

class LecturerCreateFYPTitle extends StatefulWidget {
  const LecturerCreateFYPTitle({super.key});

  @override
  State<LecturerCreateFYPTitle> createState() => _LecturerCreateFYPTitleState();
}

class _LecturerCreateFYPTitleState extends State<LecturerCreateFYPTitle> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _linkController = TextEditingController();

  final _dismissKeyboard = FocusNode();
  final _titleFocus = FocusNode();
  final _contentFocus = FocusNode();

  late bool _newsTitleDone;
  late bool _newsContentDone;

  List<File>? _files;
  int? _numberOfFilesSelected;

  @override
  void initState() {
    super.initState();
    FYPTitleNotifier notifier =
        Provider.of<FYPTitleNotifier>(context, listen: false);
    Future.delayed(const Duration(milliseconds: 1)).then((_) {
      notifier.setProgress = 0;
    });
    _newsTitleDone = false;
    _newsContentDone = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// to change focus to next text field
  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FYPTitleNotifier>(builder: (context, value, widget) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Post a FYP Title',
            style: TextStyle(fontSize: 20),
          ),
        ),
        bottomNavigationBar: _submitButton(),
        body: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(_dismissKeyboard),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 25, horizontal: 30),
                          child: Text(
                            'Post a FYP Title for the students',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      _nameOfFields('FYP Title', 0, 25),
                      _titleField(value),
                      _nameOfFields('Summary', 25, 25),
                      _contentField(value),
                      _nameOfFields('Add a link', 25, 25, isMandatory: false),
                      _linkField(),
                      _nameOfFields('Add files', 25, 25, isMandatory: false),
                      _addFile(),
                    ],
                  ),
                ),
              ),
            )),
      );
    });
  }

  Widget _nameOfFields(String fieldName, double top, double left,
      {bool isMandatory = true}) {
    return Padding(
        padding: EdgeInsets.only(top: top, left: left),
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

  Widget _titleField(FYPTitleNotifier value) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: TextFormField(
        decoration:
            const InputDecoration(hintText: 'eg. FYP Management System'),
        controller: _titleController,
        focusNode: _titleFocus,
        onFieldSubmitted: (val) {
          _fieldFocusChange(context, _titleFocus, _contentFocus);
        },
        maxLines: 1,
        textInputAction: TextInputAction.next,
        maxLength: 100,
        validator: (value) =>
            value == null || value.isEmpty ? 'Title must not be empty' : null,
        onChanged: (val) {
          setState(() {
            if (val.isNotEmpty) {
              if (!_newsTitleDone) {
                _newsTitleDone = !_newsTitleDone;
                value.updateProgressBarIndicator(true);
              }
            } else {
              if (_newsTitleDone) {
                _newsTitleDone = false;
                value.updateProgressBarIndicator(false);
              }
            }
          });
        },
      ),
    );
  }

  Widget _contentField(FYPTitleNotifier value) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: TextFormField(
        decoration: const InputDecoration(
            hintText: 'eg. Design a system that manages projects ...'),
        controller: _contentController,
        focusNode: _contentFocus,
        maxLines: 1,
        textInputAction: TextInputAction.next,
        maxLength: 1000,
        validator: (value) =>
            value == null || value.isEmpty ? 'Summary must not be empty' : null,
        onChanged: (val) {
          setState(() {
            if (val.isNotEmpty) {
              if (!_newsContentDone) {
                _newsContentDone = !_newsContentDone;
              }
            } else {
              if (_newsContentDone) {
                _newsContentDone = false;
              }
            }
          });
        },
      ),
    );
  }

  Widget _linkField() {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: TextFormField(
        controller: _linkController,
        textInputAction: TextInputAction.done,
        decoration:
            const InputDecoration(hintText: 'e.g. Link to external site'),
      ),
    );
  }

  Widget _addFile() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 50, right: 50, bottom: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 320,
            width: 320,
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _files == null
                ? TextButton(
                    onPressed: () {
                      _pickFiles();
                    },
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          Icon(Icons.file_upload),
                          Text('You have not yet upload any documents'),
                        ],
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Number of files selected: $_numberOfFilesSelected',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () {
                          _pickFiles();
                        },
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 30.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'Click here to reselect files',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'docx'],
    );
    if (result != null) {
      _files = result.paths.map((path) => File(path!)).toList();
      _numberOfFilesSelected = result.count;
      setState(() {});
    }
    if (!mounted) return;
  }

  Widget _submitButton() {
    return Consumer<UserNotifier>(
      builder: (context, notifier, widget) {
        return ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              FYPTitle model = FYPTitle(
                uid: notifier.userUID!,
                title: _titleController.text,
                content: _contentController.text,
                link: _linkController.text,
                filesToUpload: _files,
                dateCreated: Timestamp.now(),
              );
              _onSubmitPressed(model, notifier);
            }
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: const Center(
              child: Text(
                'Submit',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _onSubmitPressed(FYPTitle model, UserNotifier userData) {
    return showDialog(
      context: context,
      builder: (context) => FutureBuilder<bool>(
        future: FYPTitleService().submitTitle(model, userData),
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
                                          'You have succesfully posted a FYP Title!'),
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
