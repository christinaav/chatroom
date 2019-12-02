import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'dart:io';
import 'sign_in.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

BubbleStyle styleSomebody = BubbleStyle(
  nip: BubbleNip.leftTop,
  color: Colors.white,
  elevation: 1,
  margin: BubbleEdges.only(top: 8.0, right: 50.0),
  alignment: Alignment.topLeft,
);

BubbleStyle styleMe = BubbleStyle(
  nip: BubbleNip.rightTop,
  color: Color.fromARGB(255, 225, 255, 199),
  elevation: 1,
  margin: BubbleEdges.only(top: 8.0, left: 50.0),
  alignment: Alignment.topRight,
);

class _ChatPageState extends State<ChatPage> {
  ScrollController _scrollController = new ScrollController();
  final mycontroller = TextEditingController();
  String temp = '';
  bool connected = false;
  Socket socketino;
  String textfield = 'Join the chat!';
  List<String> messages = [];
  String nonmes;

  connect() {
    if (!connected)
      Socket.connect('192.168.1.195', 3000).then((Socket sock) {
        socketino = sock;
        print('mi sono connesso');
        socketino.write(name);
        socketino.listen(
          dataHandler,
        );
      });
  }

  dataHandler(data) {
    print(String.fromCharCodes(data).trim());
    temp = String.fromCharCodes(data).trim();
    setState(() {
      messages.add(temp);
    });
  }

  sendData() {
    if (mycontroller.text.toString() != null &&
        mycontroller.text.toString().isNotEmpty) socketino.write(nonmes);
    print(temp);
    mycontroller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Chat with your friends'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 1.3,
              child: ListView(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: <Widget>[
                  Bubble(
                    alignment: Alignment.center,
                    color: Color.fromARGB(255, 212, 234, 244),
                    elevation: 1,
                    margin: BubbleEdges.only(top: 8.0),
                    child: Text('TODAY', style: TextStyle(fontSize: 10)),
                  ),
                  //     if (temp != null && temp.isNotEmpty)
                  for (var message in messages)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Bubble(
                          style: styleMe,
                          nip: BubbleNip.no,
                          margin: BubbleEdges.only(top: 2.0),
                          child: Text('$message'),
                        ),
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            imageUrl,
                          ),
                          radius: 10.0,
                          backgroundColor: Colors.transparent,
                        )
                      ],
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 8.0),
                        Icon(Icons.insert_emoticon,
                            size: 30.0, color: Theme.of(context).hintColor),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            onChanged: (text) {
                              nonmes = text;
                            },
                            controller: mycontroller,
                            decoration: InputDecoration(
                              hintText: textfield,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 5.0,
                              ),
                              GestureDetector(
                                onTap: () {
                                  connect();
                                  connected = true;
                                  textfield = 'Type a message';
                                  sendData();
                                },
                                child: CircleAvatar(
                                  child: Icon(Icons.send),
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.0),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
