import 'package:flutter/material.dart';
import 'package:fyp_management/notifier/user_notifier.dart';
import 'package:fyp_management/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fyp_management/pages/shared/register_page.dart';
import 'package:fyp_management/services/auth_exception_handler.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late bool _isLoading;
  late String _errorMessage;
  late bool _isLoginForm;
  late String _email;
  late String _password;
  late String _password2;

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _dismissKeyboard = FocusNode();

  @override
  void initState() {
    super.initState();
    _errorMessage = '';
    _isLoading = false;
    _isLoginForm = true;
    _email = '';
    _password = '';
    _password2 = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_dismissKeyboard),
      child: Stack(
        children: <Widget>[
          showForm(),
          if (_isLoading) ...{
            Container(
              color: Colors.white.withOpacity(0.7),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    CircularProgressIndicator(
                      strokeWidth: 5,
                      backgroundColor: Colors.blue,
                      valueColor: AlwaysStoppedAnimation(Colors.cyanAccent),
                    ),
                  ],
                ),
              ),
            )
          }
        ],
      ),
    ));
  }

  Widget showForm() {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      padding: const EdgeInsets.only(top: 25, left: 20, right: 20, bottom: 15),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              showLogo(),
              showAppName(),
              emailInputField(),
              passwordInputField(),
              if (!_isLoginForm) ...{
                passwordConfirmationField(),
              },
              loginSignUpButton(),
              secondaryButton(),
              showErrorMessage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget showLogo() {
    return Hero(
      tag: 'hero',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
        child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 80.0,
            child: Image.asset('assets/images/logo.png')),
      ),
    );
  }

  Widget showAppName() {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Center(
        child: Text(
          'UUM FYP Management',
          style: GoogleFonts.alexandria(
            fontSize: 28,
            color: Colors.blue[800],
          ),
        ),
      ),
    );
  }

  Widget emailInputField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 30, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Email',
          icon: Icon(
            Icons.email,
            color: Colors.blue[800],
          ),
        ),
        validator: (value) => value == null || value.isEmpty
            ? 'Email must not be empty'
            : EmailValidator.validate(_email)
                ? null
                : "Invalid email address",
        onSaved: (value) => _email = value ?? "",
        onChanged: (value) {
          setState(() => _email = value);
        },
      ),
    );
  }

  Widget passwordInputField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 30.0, 30, 0.0),
      child: TextFormField(
        maxLines: 1,
        autofocus: false,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'Password',
          icon: Icon(
            Icons.lock,
            color: Colors.blue[800],
          ),
        ),
        validator: (value) => value == null || value.isEmpty
            ? 'Password can\'t be empty'
            : value.length >= 8
                ? null
                : 'Password length must be 8 or more',
        onSaved: (value) => _password = value ?? "",
        onChanged: (value) {
          // get value everytime user change input
          setState(() => _password = value);
        },
      ),
    );
  }

  Widget passwordConfirmationField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 30.0, 30, 0.0),
      child: TextFormField(
        maxLines: 1,
        autofocus: false,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'Confirm Password',
          icon: Icon(
            Icons.lock_outline,
            color: Colors.blue[800],
          ),
        ),
        onChanged: (val) {
          setState(() => _password2 = val);
        },
        validator: (value) =>
            _password2 != _password ? 'Password does not match' : null,
      ),
    );
  }

  Widget loginSignUpButton() {
    return Consumer<UserNotifier>(
      builder: (context, notifier, widget) {
        return Padding(
          padding: const EdgeInsets.only(top: 45, left: 80, right: 80),
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            height: 40.0,
            child: ElevatedButton(
              clipBehavior: Clip.hardEdge,
              child: Text(
                _isLoginForm ? 'Login' : 'Create account',
                style: const TextStyle(fontSize: 18.0, color: Colors.white),
              ),
              onPressed: () {
                if (_isLoginForm) {
                  if (_formKey.currentState!.validate()) {
                    _isLoading = true;
                    continueToHome(notifier);
                  }
                } else {
                  if (_formKey.currentState!.validate()) {
                    dialogSignup();
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  dialogSignup() {
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              child: Consumer<UserNotifier>(
                builder: (context, notifier, widget) {
                  return SizedBox(
                    height: 200.0,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 10),
                        const SizedBox(
                          height: 20,
                          child: Text(
                            'Register as a ...',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          color: Colors.black,
                          height: 1,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                InkWell(
                                  splashColor: Colors.blue[800],
                                  onTap: () {
                                    notifier.setLecturerMode = false;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignUpPage(
                                          email: _email,
                                          password: _password,
                                          isLecturer: notifier.lecturerMode!,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 120,
                                        height: 100,
                                        child: Image.asset(
                                          'assets/images/user.png',
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      const Text(
                                        'Student',
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontFamily: 'Lexis',
                                            color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Container(
                                height: 159, width: 1, color: Colors.black),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                InkWell(
                                  splashColor: Colors.blue[800],
                                  onTap: () {
                                    notifier.setLecturerMode = true;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignUpPage(
                                          email: _email,
                                          password: _password,
                                          isLecturer: notifier.lecturerMode!,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 120,
                                        height: 100,
                                        child: Image.asset(
                                          'assets/images/admin.png',
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      const Text(
                                        'Lecturer',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontFamily: 'Lexis',
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 19)
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ));
  }

  Widget secondaryButton() {
    return TextButton(
      child: RichText(
        text: TextSpan(
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w300, color: Colors.black),
            children: <TextSpan>[
              _isLoginForm
                  ? TextSpan(children: <TextSpan>[
                      const TextSpan(text: 'Create an '),
                      TextSpan(
                          text: 'account',
                          style: TextStyle(color: Colors.blue[800]))
                    ])
                  : TextSpan(children: <TextSpan>[
                      const TextSpan(text: 'Have an account? '),
                      TextSpan(
                          text: 'Sign in',
                          style: TextStyle(color: Colors.blue[800]))
                    ])
            ]),
      ),
      onPressed: () => setState(() => _isLoginForm = !_isLoginForm),
    );
  }

  Widget showErrorMessage() {
    if (_errorMessage.isNotEmpty) {
      return Text(
        _errorMessage,
        style: const TextStyle(
          fontSize: 13.0,
          color: Colors.red,
          height: 1.0,
          fontWeight: FontWeight.w300,
        ),
      );
    } else {
      return Container(
        height: 0.0,
      );
    }
  }

  void continueToHome(UserNotifier notifier) async {
    if (_formKey.currentState!.validate()) {
      dynamic result = await _auth.signIn(_email, _password);

      if (result == AuthResultStatus.successful) {
        setState(() {
          _isLoading = false;
        });
      } else {
        final errorMessage =
            AuthExceptionHandler.generateExceptionMessage(result);
        _showErrorAlertDialog(errorMessage);
      }
    } else {
      print('not validate');
    }
  }

  _showErrorAlertDialog(error) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actionsPadding: const EdgeInsets.all(0),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: Center(
              child: Column(children: <Widget>[
                IconButton(
                    icon: Icon(Icons.error, size: 40, color: Colors.blue[800]),
                    onPressed: null),
                const SizedBox(height: 5),
                Text(
                  'Login Failed',
                  style: TextStyle(color: Colors.blue[800]),
                ),
              ]),
            ),
            content: Text(error),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  "Okay",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _isLoading = false;
                  });
                },
              )
            ],
          );
        });
  }
}
