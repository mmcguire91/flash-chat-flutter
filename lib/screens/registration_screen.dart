import 'package:flutter/material.dart';
import 'chat_screen.dart';
import '../components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
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
                //Do something with the user input.
                email =
                    value; //store the entry value of the email field as the variable email
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
                //Do something with the user input.
                password =
                    value; //store the entry value of the password field as the variable password
              },
              decoration: kTextFieldDecoration.copyWith(
                hintText: 'Password',
              ),
            ),
            SizedBox(
              height: 24.0,
            ),
            RoundedButton(
              buttonColor: Colors.blueAccent,
              buttonText: 'Register',
              onPressed: () async {
                try {
                  final newUser = await _auth.createUserWithEmailAndPassword(
                      email: email.trim(), password: password);
                  //_auth.createUserWithEmailAndPassword defines a future value. Stored as final newUser
                  //async & await because it is a future value we want to make sure the future value (the new user is created) before proceeding
                  if (newUser != null) {
                    Navigator.pushNamed(context, ChatScreen.id);
                    //if the newUser value is not empty proceed to the chat view
                  }
                } catch (e) {
                  print(e);
                  WarningAlertBoxCenter(
                    context: context,
                    messageText:
                        'Something went wrong. Password must be at least 6 characters',
                  );
                  //trigger warning box to alert user that something went wrong if authentication fails
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
