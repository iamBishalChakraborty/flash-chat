import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';

final _firebaseAuth = FirebaseAuth.instance;
final loggedInUser = _firebaseAuth.currentUser;
final firestore = FirebaseFirestore.instance;

class ChatScreen extends StatefulWidget {
  static final id = 'chatScreen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String message;
  final textEditingController = TextEditingController();

  @override
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
                stream: firestore
                    .collection('messages')
                    .orderBy('time')
                    .snapshots(),
                builder: (context, snapshot) {
                  // ignore: deprecated_member_use
                  final messages = snapshot.data.documents.reversed;
                  List<ChatMessagesWidget> messageWidgets = [];
                  for (var message in messages) {
                    final text = message['message'];
                    final sender = message['sender'];
                    final messageWidget =
                        ChatMessagesWidget(sender: sender, message: text);
                    print(text);
                    messageWidgets.add(messageWidget);
                  }
                  return Expanded(
                    child: ListView(
                      reverse: true,
                      children: messageWidgets,
                    ),
                  );
                }),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      textEditingController.clear();
                      final sendData =
                          await firestore.collection('messages').add({
                        'message': message,
                        'sender': loggedInUser.email,
                        'time': Timestamp.now(),
                      });

                      //Implement send functionality.
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

class ChatMessagesWidget extends StatelessWidget {
  ChatMessagesWidget({this.sender, this.message});

  final String sender;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: sender == loggedInUser.email
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(color: Colors.white70, fontSize: 8),
          ),
          Material(
            borderRadius: sender == loggedInUser.email
                ? BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10))
                : BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
            color: sender == loggedInUser.email
                ? Color(0xFF266162)
                : Color(0xFF262d31),
            child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  message,
                  style: TextStyle(color: Colors.white),
                )),
          )
        ],
      ),
    );
  }
}
