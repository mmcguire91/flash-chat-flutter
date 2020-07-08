import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _firestore = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    //retrieve the user credentials when screen is initialized
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      // if somebody is logged in this will display to the current user
      if (user != null) {
        //if we do have a signed in user
        loggedInUser = user;
        //save the [logged in] user to the loggedInUser variable
      }
    } catch (e) {
      print(e);
    }
  }

  void messagesStream() async {
    //stream listens & subscribes to the latest data housed in the firebase console and pushes when something new is added
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      //await the latest data added to the messages collection in firebase
      for (var message in snapshot.documents) {
        //save var message as the data collected and regularly pushed from firebase from documents added within the messages collection
        print(message.data);
        //print out all the data housed within messages collection: messages / documents / fields (sender, text)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                //sign user out
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              //StreamBuilder establishes the Stream of data pushed from Firebase console
              //QuerySnapshot is the data type requested from the firebase console --> Querying a snapshot of the data housed in Firebase
              stream: _firestore.collection('messages').snapshots(),
              //the source of the stream should consist of the messages collection. Snapshots() performs the queries of the location to determine if there is anything new to push
              builder: (context, snapshot) {
                //build the stream to consist of the context and the snapshot query of the stream
                if (!snapshot.hasData) {
                  //if the snapshot query returns null
                  return Center(
                    child: CircularProgressIndicator(),
                    //then display the circular progress indicator
                  );
                }
                final messages = snapshot.data.documents;
                //store in the messages variable the query of the latest data [documents] posted to Firebase
                List<Text> messageWidgets = [];
                //establish a list (messageWidgets) to store the contents of the documents
                for (var message in messages) {
                  //build for in loops to retrieve the data in messages storing to the variable message to call the data of each field within a document in the messages collection
                  final messageText = message.data['text'];
                  //retrieve the data stored in the text field and save to the variable messageText
                  final messageSender = message.data['sender'];
                  //retrieve the data stored in the sender field and save to the variable messageSender

                  final messageWidget =
                      Text('$messageText from $messageSender');
                  //store the data retrieved from the data stored in the messageText and messageSender variables within the messageWidget variable
                  messageWidgets.add(messageWidget);
                  //add each document data (messageWidget) retrieved and add it to the List messageWidgets
                }
                return Column(
                  children: messageWidgets,
                  //return the data stored in messageWidgets
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        messageText = value;
                        //store the entry value of the text entry field as the variable messageText
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //messageTex + loggedInUser.email
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                      });
                      //log the information and values according to those established within Firebase
                      //retrieved from database collection and fields established in Firebase
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
