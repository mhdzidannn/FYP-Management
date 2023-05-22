import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fyp_management/model/student/project_logs.dart';
import 'package:fyp_management/pages/shared/pdf_viewer.dart';
import 'package:fyp_management/services/url2pdf.dart';

class ProjectLogPage extends StatefulWidget {
  final List<ProjectLogs> data;

  const ProjectLogPage({required this.data, super.key});

  @override
  State<ProjectLogPage> createState() => _ProjectLogPageState();
}

class _ProjectLogPageState extends State<ProjectLogPage> {
  Future<List<File>> loadFilesForLog(ProjectLogs logsData, int index) async {
    List<File> tempList = [];
    URL2PDF downloader = URL2PDF();
    if (logsData.files != null && logsData.files!.isNotEmpty) {
      logsData.files!.forEach(
        (element) async {
          var url = element as String;
          if (url.isEmpty) {
            return;
          }
          var file = await downloader.createFileOfPdfUrl(url);
          tempList.add(file);
        },
      );
    }
    await Future.delayed(const Duration(milliseconds: 500));
    return tempList;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      primary: false,
      itemBuilder: (cont, index) {
        return Card(
          margin: const EdgeInsets.all(10),
          color: Colors.blue[100],
          shadowColor: Colors.grey[300],
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                Text(widget.data[index].summary),
                FutureBuilder<List<File>>(
                  initialData: [],
                  future: loadFilesForLog(widget.data[index], index),
                  builder: (ctxt, fileData) {
                    if (fileData.data!.isNotEmpty) {
                      for (var file in fileData.data!) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PDFScreen(path: file.path),
                              ),
                            );
                          },
                          child: const Text(
                            'View File',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blueAccent,
                            ),
                          ),
                        );
                      }
                    }
                    return const SizedBox();
                  },
                )
              ],
            ),
          ),
        );
      },
      separatorBuilder: (cont, index) {
        return const Divider();
      },
      itemCount: widget.data.length,
    );
  }
}
