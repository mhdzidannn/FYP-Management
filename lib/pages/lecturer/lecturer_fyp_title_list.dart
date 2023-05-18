import 'package:flutter/material.dart';
import 'package:fyp_management/model/lecturer_titles/fyp_title.dart';
import 'package:fyp_management/pages/lecturer/lecturer_fyp_title_create.dart';
import 'package:fyp_management/pages/shared/main_drawer.dart';
import 'package:fyp_management/services/lecturer_fyp_title_services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../notifier/user_notifier.dart';

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

  Widget _card(BuildContext context, FYPTitle data, int index, int currIndex) {
    String createdAt;
    String updatedAt = "";
    String timeCreated;
    String timeUpdated;

    int hourCreated = data.dateCreated.toDate().hour;
    String minuteCreated = data.dateCreated.toDate().minute.toString();

    if (data.dateCreated.toDate().minute < 10) {
      minuteCreated = '0${data.dateCreated.toDate().minute}';
    }

    if (hourCreated == 0) {
      hourCreated = 12;
      timeCreated = '$hourCreated.${minuteCreated}AM';
    }
    if (hourCreated > 12) {
      hourCreated = hourCreated - 12;
      timeCreated = '$hourCreated.${minuteCreated}PM';
    } else {
      timeCreated = '$hourCreated.${minuteCreated}AM';
    }

    createdAt =
        "$timeCreated at ${data.dateCreated.toDate().day}/${data.dateCreated.toDate().month}/${data.dateCreated.toDate().year}";

//IF DATE UPDATED EXIST
    if (data.dateUpdated != null) {
      String minuteUpdated = data.dateUpdated!.toDate().minute.toString();
      if (data.dateUpdated!.toDate().minute < 10) {
        minuteUpdated = '0${data.dateUpdated!.toDate().minute}';
      }

      int hourUpdated = data.dateUpdated!.toDate().hour;

      if (hourUpdated == 0) {
        hourUpdated = 12;
        timeUpdated = '$hourUpdated.${minuteUpdated}AM';
      }
      if (hourUpdated > 12) {
        hourUpdated = hourUpdated - 12;
        timeUpdated = '$hourUpdated.${minuteUpdated}PM';
      } else {
        timeUpdated = '$hourUpdated.${minuteUpdated}AM';
      }

      updatedAt =
          "$timeUpdated at ${data.dateUpdated!.toDate().day}/${data.dateUpdated!.toDate().month}/${data.dateUpdated!.toDate().year}";
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
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                if (data.dateUpdated == null) ...{
                  Text(
                    createdAt,
                    style: TextStyle(
                        color: Colors.blue[900], fontStyle: FontStyle.italic),
                  ),
                } else ...{
                  Text(updatedAt),
                },
                const SizedBox(height: 20),
                Text(
                  data.content,
                ),
                const SizedBox(height: 20),
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
                    ],
                  )
                },
                const SizedBox(height: 20),
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
