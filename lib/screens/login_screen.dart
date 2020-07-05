import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import '../components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String email;
  String password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Container(
                  height: 145.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              //Email
              TextField(
                keyboardType: TextInputType
                    .emailAddress, //display specialty keyboard for entering email address
                onChanged: (value) {
                  email = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Email',
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              //Password
              TextField(
                obscureText: true, //hide the values that the user enters
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Password',
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                buttonColor: Colors.lightBlueAccent,
                buttonText: 'Login',
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    final user = await _auth.signInWithEmailAndPassword(
                        email: email.trim(), password: password);
                    if (user != null) {
                      Navigator.pushNamed(context, ChatScreen.id);
                      //if the newUser value is not empty proceed to the chat view
                    }
                    setState(() {
                      showSpinner = false;
                    });
                  } catch (e) {
                    print(e);
                    WarningAlertBoxCenter(
                      context: context,
                      messageText:
                          'Something went wrong. Password must be at least 6 characters',
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
