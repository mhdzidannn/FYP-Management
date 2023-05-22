import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fyp_management/model/lecturer_titles/fyp_title.dart';
import 'package:fyp_management/pages/shared/main_drawer.dart';
import 'package:fyp_management/pages/shared/pdf_viewer.dart';
import 'package:fyp_management/pages/student/submit_proposal_page.dart';
import 'package:fyp_management/services/lecturer_fyp_title_services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../notifier/user_notifier.dart';
import 'package:path_provider/path_provider.dart';

class StudentFypTitleListPage extends StatefulWidget {
  const StudentFypTitleListPage({super.key});

  @override
  State<StudentFypTitleListPage> createState() => _StudentFypTitleListPage();
}

class _StudentFypTitleListPage extends State<StudentFypTitleListPage> {
  late bool _selectMode;
  late Stream<List<FYPTitle>> _fypTitleStream;

  @override
  void initState() {
    UserNotifier noti = Provider.of<UserNotifier>(context, listen: false);
    _selectMode = false;
    _fypTitleStream = FYPTitleService().getTitleForStudent();
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
            icon:
                _selectMode ? const Icon(Icons.cancel) : const Icon(Icons.send),
            onPressed: () => setState(() => _selectMode = !_selectMode),
          )
        ],
      ),
      drawer: MainDrawer(),
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
          var file = await createFileOfPdfUrl(url);
          listOfFile.add(file);
        },
      );
    }

    selectTitleAlertDialog() {
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
            Navigator.pop(context, true);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubmitProposalPage(fypTitle: data),
              ),
            );
          },
        );
      });
      AlertDialog alert = AlertDialog(
        title: const Text("You are about to submit a proposal"),
        content: const Text(
            "Once confirmed this title, you cannot change title unless contact administrator. \n\nProceed?"),
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
          if (_selectMode) ...{
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: IconButton(
                  onPressed: () {
                    selectTitleAlertDialog();
                  },
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                ),
              ),
            )
          }
        ],
      ),
    );
  }

  Future<File> createFileOfPdfUrl(String url) async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }
    return completer.future;
  }
}
