import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

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
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                        //store the entry value of the text entry field as the variable messageText
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      //clear the text field on button press
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                        'timestamp': Timestamp.now()
                        //add timestamp property to each message in order to display messages in chronological order
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

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      //StreamBuilder establishes the Stream of data pushed from Firebase console
      //QuerySnapshot is the data type requested from the firebase console --> Querying a snapshot of the data housed in Firebase

      stream: _firestore
          .collection('messages')
          .orderBy('timestamp',
              descending: true) //display in chronological order
          .snapshots(),
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

        List<MessageBubble> messageBubbles = [];
        //establish a list (messageWidgets) to store the contents of the documents

        for (var message in messages) {
          //build for in loops to retrieve the data in messages storing to the variable message to call the data of each field within a document in the messages collection

          final messageText = message.data['text'];
          //retrieve the data stored in the text field and save to the variable messageText
          final messageSender = message.data['sender'];
          //retrieve the data stored in the sender field and save to the variable messageSender

          final currentUser = loggedInUser.email;

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUser == messageSender,
          );
          //display the data retrieved from the data stored in the messageText and messageSender variables within the text and sender properties esatablished in the MessageBubble widget

          messageBubbles.add(messageBubble);
          //add each document data (messageWidget) retrieved and add it to the List messageWidgets
        }
        return Expanded(
          //Expanded - limit to available space
          child: ListView(
            //make the area where this content is housed scrollable
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
            //return the data stored in messageWidgets
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({
    this.sender,
    this.text,
    this.isMe,
  });

  final String sender;
  final String text;
  //establish sender and text properties to further clarify where the data housed in the messageText and messageSender variables will be displayed
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        //if I am the logged in user that sent the message display the text bubble on the right, otherwise display on the left
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(color: Colors.black54),
          ),
          Material(
            elevation: 5.0,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
            //change the orientation of the border radius
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            //if I am the logged in user that sent the message display the text bubble in light blue, otherwise display in white
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  color: isMe ? Colors.white : Colors.black,
                  //if I am the logged in user that sent the message display the text in white, otherwise display in black
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
