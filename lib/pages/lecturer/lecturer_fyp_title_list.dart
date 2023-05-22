import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fyp_management/model/lecturer_titles/fyp_title.dart';
import 'package:fyp_management/pages/lecturer/lecturer_fyp_title_create.dart';
import 'package:fyp_management/pages/shared/main_drawer.dart';
import 'package:fyp_management/pages/shared/pdf_viewer.dart';
import 'package:fyp_management/services/create_file_from_url.dart';
import 'package:fyp_management/services/lecturer_fyp_title_services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../notifier/user_notifier.dart';
import 'package:path_provider/path_provider.dart';

class LectFYPTitleListPage extends StatefulWidget {
  const LectFYPTitleListPage({super.key});

  @override
  State<LectFYPTitleListPage> createState() => _LectFYPTitleListPage();
}

class _LectFYPTitleListPage extends State<LectFYPTitleListPage> {
  late String _uid;
  late bool _deleteMode;
  late Stream<List<FYPTitle>> _fypTitleStream;

  @override
  void initState() {
    UserNotifier noti = Provider.of<UserNotifier>(context, listen: false);
    _uid = noti.userUID!;
    _deleteMode = false;
    _fypTitleStream = FYPTitleService().getTitle(_uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('FYP Titles'),
        actions: <Widget>[
          IconButton(
            icon: _deleteMode
                ? const Icon(Icons.cancel)
                : const Icon(Icons.delete),
            onPressed: () => setState(() => _deleteMode = !_deleteMode),
          )
        ],
      ),
      drawer: MainDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue[700],
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LecturerCreateFYPTitle(),
          ),
        ),
        label: const Text(
          'Create New Title',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: StreamBuilder<List<FYPTitle>>(
        stream: _fypTitleStream,
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
                        'You havent created any titles yet',
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

  Widget _card(
    BuildContext context,
    FYPTitle data,
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

    deleteAlertDialog() {
      Widget cancelButton = TextButton(
        child: const Text("Cancel"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      Widget launchButton =
          Consumer<UserNotifier>(builder: (context, notifier, widget) {
        return TextButton(
          child: const Text("Delete"),
          onPressed: () {
            FYPTitleService().deleteFypTitle(data, notifier);
            Navigator.pop(context, true);
          },
        );
      });
      AlertDialog alert = AlertDialog(
        title: const Text("Notice"),
        content: const Text(
            "Clicking 'Delete' will remove the title from the listing. \n\nProceed?"),
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

    return Card(
      key: key,
      elevation: 12,
      margin: index + 1 == currIndex
          ? const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 80)
          : const EdgeInsets.all(15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
                Text("Title by: ${data.nameOfLecturer}"),
                const SizedBox(height: 10),
                Text(data.content),
                const SizedBox(height: 10),
                if (data.link != null && data.link!.isNotEmpty) ...{
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        child: Text(
                          "${data.link}",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () async {
                          Uri url = Uri.parse("https://${data.link!}");
                          print(url);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  )
                },
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
          if (_deleteMode) ...{
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black,
                child: IconButton(
                  onPressed: () {
                    deleteAlertDialog();
                  },
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                ),
              ),
            )
          }
        ],
      ),
    );
  }
}
