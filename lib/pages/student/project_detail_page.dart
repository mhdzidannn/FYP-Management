import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fyp_management/model/auth/lecturer_details.dart';
import 'package:fyp_management/model/student/student_proposal.dart';
import 'package:fyp_management/pages/shared/pdf_viewer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ExistingProjectDetailPage extends StatefulWidget {
  final StudentProject data;
  final LecturerDetails lecturerDetails;
  final LecturerDetails supervisorDetails;
  final List<File> proposalFiles;

  const ExistingProjectDetailPage({
    required this.data,
    required this.lecturerDetails,
    required this.supervisorDetails,
    required this.proposalFiles,
    super.key,
  });

  @override
  State<ExistingProjectDetailPage> createState() =>
      _ExistingProjectDetailPageState();
}

class _ExistingProjectDetailPageState extends State<ExistingProjectDetailPage> {
  Widget _textDisplay(String fieldName) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10),
      child: Text(
        fieldName,
        style: GoogleFonts.ubuntuCondensed(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 25,
              horizontal: 30,
            ),
            child: Text(
              'Manage your project logs and submissions here.',
              style: GoogleFonts.ubuntuCondensed(),
            ),
          ),
        ),
        const Divider(),
        _textDisplay('Proposal Name: ${widget.data.title}'),
        _textDisplay('Supervisor Name: ${widget.supervisorDetails.username}'),
        _textDisplay('Supervisor Email: ${widget.supervisorDetails.email}'),
        _textDisplay(
            'Supervisor Contact Number: ${widget.supervisorDetails.phone}'),
        const Divider(),
        _textDisplay('Lecturer Name: ${widget.lecturerDetails.username}'),
        _textDisplay('Lecturer Email: ${widget.lecturerDetails.email}'),
        _textDisplay(
            'Lecturer Contact Number: ${widget.lecturerDetails.phone}'),
        const Divider(),
        if (widget.data.link != null && widget.data.link!.isNotEmpty) ...{
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                child: Text(
                  "${widget.data.link}",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
                onTap: () async {
                  Uri url = Uri.parse("https://${widget.data.link!}");
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
        if (widget.data.files != null &&
            widget.data.files!.isNotEmpty &&
            widget.data.files![0] != "") ...{
          for (int i = 0; i < widget.data.files!.length; i++) ...{
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PDFScreen(path: widget.proposalFiles[i].path),
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
    );
  }
}
