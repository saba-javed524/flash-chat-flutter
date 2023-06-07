import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat_flutter/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _fireStore = FirebaseFirestore.instance;
User? loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id = 'chat';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  late String text;
  final messageController = TextEditingController();
  bool? isMe;

  getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              messageStream(),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        style: TextStyle(color: Colors.black),
                        onChanged: (value) {
                          text = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        messageController.clear();
                        //Implement send functionality.
                        _fireStore.collection('messages').add({
                          'text': text,
                          'sender': loggedInUser!.email,
                        });
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
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.message, this.isMe});

  String? sender;
  String? message;
  bool? isMe;
  Radius rad = Radius.circular(30);
  Radius radNo = Radius.circular(0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        crossAxisAlignment:
            isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender!,
            style: TextStyle(color: Colors.black54, fontSize: 12.0),
          ),
          Material(
            color: isMe! ? Colors.lightBlueAccent : Colors.white,
            elevation: 5.0,
            borderRadius: BorderRadius.only(
                topLeft: isMe! ? rad : radNo,
                bottomRight: rad,
                bottomLeft: rad,
                topRight: isMe! ? radNo : rad),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Text(
                '$message',
                style: TextStyle(
                    color: isMe! ? Colors.white : Colors.black54, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class messageStream extends StatelessWidget {
  const messageStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        List<MessageBubble> messageWidgets = [];
        if (snapshot.hasData) {
          final messages = snapshot.data!.docs;
          for (var message in messages) {
            var messageText = message['text'];
            var messageSender = message['sender'];

            final currentUser = loggedInUser!.email;
            if (currentUser == messageSender) {
              //this is the logged in User
              print('this is the logged in User');
            }
            final singleMessageWidget = MessageBubble(
              sender: messageSender,
              message: messageText,
              isMe: currentUser == messageSender,
            );
            messageWidgets.add(singleMessageWidget);
          }
        }

        return Expanded(
          child: ListView(
            children: messageWidgets,
            reverse: true,
          ),
        );
      },
    );
  }
}
