import 'package:flutter/material.dart';

class LoginField extends StatelessWidget {
  LoginField({this.hintTextEntry});
  final String hintTextEntry;
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) {
        //Do something with the user input.
      },
      decoration: InputDecoration(
        hintText: hintTextEntry,
        hintStyle: TextStyle(
          color: Colors.grey[700],
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
      ),
    );
  }
}
