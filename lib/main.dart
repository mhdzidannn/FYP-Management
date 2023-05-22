import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fyp_management/firebase_options.dart';
import 'package:fyp_management/model/auth/lecturer_details.dart';
import 'package:fyp_management/model/auth/student_details.dart';
import 'package:fyp_management/model/auth/user.dart';
import 'package:fyp_management/notifier/lecturer_title_notifier.dart';
import 'package:fyp_management/notifier/user_notifier.dart';
import 'package:provider/provider.dart';
import 'pages/shared/class_translation_page.dart';
import 'pages/shared/loading_page.dart';
import 'pages/shared/login_transition_page.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserNotifier(),
      child: StreamBuilder<UserBaseDetail?>(
        stream: AuthService().userStream,
        builder: (context, snapshot) {
          UserNotifier notifier =
              Provider.of<UserNotifier>(context, listen: false);
          if (snapshot.data != null) {
            notifier.setUserUID = snapshot.data?.uid ?? "";
            return FutureBuilder<bool>(
              future: AuthService().checkUserDetails(notifier),
              builder: (context, mode) {
                if (mode.hasData) {
                  if (mode.data!) {
                    return MultiProvider(
                      providers: [
                        if (notifier.lecturerMode!) ...{
                          StreamProvider<LecturerDetails>.value(
                            value: AuthService().getLecturerProfileStream(
                                notifier.userUID ?? ""),
                            initialData: LecturerDetails.initialData(),
                          )
                        } else ...{
                          StreamProvider<StudentDetails>.value(
                            value: AuthService().getStudentProfileStream(
                                notifier.userUID ?? ""),
                            initialData: StudentDetails(
                              email: '',
                              phone: '',
                              username: '',
                            ),
                          )
                        },
                        ChangeNotifierProvider(
                          create: (context) => FYPTitleNotifier(),
                        ),
                      ],
                      child: MaterialApp(
                        debugShowCheckedModeBanner: false,
                        theme: ThemeData(primaryColor: Colors.blue[800]),
                        home: const ClassTransitionPage(),
                      ),
                    );
                  } else {
                    AuthService().signOut(notifier);
                    return Container();
                  }
                } else {
                  return const MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: LoadingPage(),
                  );
                }
              },
            );
          } else {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(primarySwatch: Colors.lightBlue),
              home: const LoginTransitionPage(),
            );
          }
        },
      ),
    );
  }
}
